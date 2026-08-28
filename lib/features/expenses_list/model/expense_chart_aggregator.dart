import 'package:flutter/material.dart';
import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/shared/consts/palette.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/money.dart';

Future<({int totalMinor, int convertibleCount})> sumExpensesInCurrency({
  required List<Expense> expenses,
  required String targetCurrency,
  required RateResolver resolver,
}) async {
  final target = targetCurrency.toUpperCase();
  var total = 0;
  var convertible = 0;
  for (final expense in expenses) {
    final from = expense.storedCurrencyCode.toUpperCase();
    if (from == target) {
      total += expense.storedAmountMinor;
      convertible++;
      continue;
    }
    final rate = await resolver.getRate(from, target);
    if (rate == null) continue;
    total += Money.convertMinor(
      originalMinor: expense.storedAmountMinor,
      rate: rate,
    );
    convertible++;
  }
  return (totalMinor: total, convertibleCount: convertible);
}

void _addAmountToTagSlice({
  required Map<String, int> amounts,
  required Map<String, String> labels,
  required Map<String, Color> colors,
  required int tagId,
  required int part,
  required Map<int, String> tagLabels,
  required Map<int, Tag> tagById,
  required String untaggedLabel,
}) {
  final key = 'tag_$tagId';
  amounts[key] = (amounts[key] ?? 0) + part;
  labels[key] = tagLabels[tagId] ?? untaggedLabel;
  final tag = tagById[tagId];
  colors[key] ??= colorFromValue(tag?.colorValue) ?? chartColorAt(tagId);
}

void _aggregateExpenseByTagKind({
  required int amount,
  required List<int> tagIds,
  required ExpenseChartBreakdown breakdown,
  required Map<int, Tag> tagById,
  required Map<String, int> amounts,
  required Map<String, String> labels,
  required Map<String, Color> colors,
  required Map<int, String> tagLabels,
  required String untaggedLabel,
}) {
  final matching = <int>[
    for (final id in tagIds)
      if (tagById[id] != null &&
          tagMatchesChartBreakdown(tagById[id]!, breakdown))
        id,
  ];

  if (matching.isEmpty) {
    const key = '__untagged__';
    amounts[key] = (amounts[key] ?? 0) + amount;
    labels[key] = untaggedLabel;
    colors[key] ??= chartColorAt(0);
    return;
  }

  if (matching.length == 1) {
    _addAmountToTagSlice(
      amounts: amounts,
      labels: labels,
      colors: colors,
      tagId: matching.first,
      part: amount,
      tagLabels: tagLabels,
      tagById: tagById,
      untaggedLabel: untaggedLabel,
    );
    return;
  }

  final share = amount ~/ matching.length;
  var remainder = amount - share * matching.length;
  for (final tagId in matching) {
    final part = share + (remainder > 0 ? 1 : 0);
    if (remainder > 0) remainder--;
    _addAmountToTagSlice(
      amounts: amounts,
      labels: labels,
      colors: colors,
      tagId: tagId,
      part: part,
      tagLabels: tagLabels,
      tagById: tagById,
      untaggedLabel: untaggedLabel,
    );
  }
}

void _aggregateExpenseByPayment({
  required int amount,
  required Expense expense,
  required Map<int, PaymentMethod> paymentById,
  required Map<int, String> paymentLabels,
  required Map<String, int> amounts,
  required Map<String, String> labels,
  required Map<String, Color> colors,
  required String untaggedLabel,
}) {
  final id = expense.paymentMethodId;
  if (id == null || paymentById[id] == null) {
    const key = '__untagged__';
    amounts[key] = (amounts[key] ?? 0) + amount;
    labels[key] = untaggedLabel;
    colors[key] ??= chartColorAt(0);
    return;
  }
  final key = 'pay_$id';
  amounts[key] = (amounts[key] ?? 0) + amount;
  labels[key] = paymentLabels[id] ?? untaggedLabel;
  final method = paymentById[id]!;
  colors[key] ??= colorFromValue(method.colorValue) ?? chartColorAt(id);
}

Future<List<DonutChartSlice>> aggregateExpensesForChart({
  required List<Expense> expenses,
  required String primaryCurrency,
  required RateResolver resolver,
  required ExpenseChartBreakdown breakdown,
  required Map<int, List<int>> expenseTags,
  required Map<int, String> tagLabels,
  required Map<int, Tag> tagById,
  required String untaggedLabel,
  Map<int, PaymentMethod> paymentById = const {},
  Map<int, String> paymentLabels = const {},
}) async {
  final amounts = <String, int>{};
  final labels = <String, String>{};
  final colors = <String, Color>{};

  for (final expense in expenses) {
    final rate = await resolver.getRate(
      expense.storedCurrencyCode,
      primaryCurrency,
    );
    final amount = rate == null
        ? (expense.storedCurrencyCode.toUpperCase() ==
                primaryCurrency.toUpperCase()
            ? expense.storedAmountMinor
            : 0)
        : Money.convertMinor(
            originalMinor: expense.storedAmountMinor,
            rate: rate,
          );
    if (amount <= 0) continue;

    switch (breakdown) {
      case ExpenseChartBreakdown.currency:
        final key = expense.storedCurrencyCode.toUpperCase();
        amounts[key] = (amounts[key] ?? 0) + amount;
        labels[key] = key;
        colors[key] ??= chartColorAt(key.hashCode);
      case ExpenseChartBreakdown.month:
        final key =
            '${expense.occurredAt.year}-'
            '${expense.occurredAt.month.toString().padLeft(2, '0')}';
        amounts[key] = (amounts[key] ?? 0) + amount;
        labels[key] = key;
        colors[key] ??= chartColorAt(amounts.length);
      case ExpenseChartBreakdown.year:
        final key = '${expense.occurredAt.year}';
        amounts[key] = (amounts[key] ?? 0) + amount;
        labels[key] = key;
        colors[key] ??= chartColorAt(key.hashCode);
      case ExpenseChartBreakdown.payment:
        _aggregateExpenseByPayment(
          amount: amount,
          expense: expense,
          paymentById: paymentById,
          paymentLabels: paymentLabels,
          amounts: amounts,
          labels: labels,
          colors: colors,
          untaggedLabel: untaggedLabel,
        );
      case ExpenseChartBreakdown.tagCountry:
      case ExpenseChartBreakdown.tagTrip:
      case ExpenseChartBreakdown.tagCustom:
        _aggregateExpenseByTagKind(
          amount: amount,
          tagIds: expenseTags[expense.id] ?? const <int>[],
          breakdown: breakdown,
          tagById: tagById,
          amounts: amounts,
          labels: labels,
          colors: colors,
          tagLabels: tagLabels,
          untaggedLabel: untaggedLabel,
        );
    }
  }

  final entries = amounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  var i = 0;
  return [
    for (final e in entries)
      DonutChartSlice(
        key: e.key,
        label: labels[e.key] ?? e.key,
        amountMinor: e.value,
        color: colors[e.key] ?? chartColorAt(i++),
      ),
  ];
}
