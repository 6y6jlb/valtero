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

Future<List<DonutChartSlice>> aggregateExpensesForChart({
  required List<Expense> expenses,
  required String primaryCurrency,
  required RateResolver resolver,
  required ExpenseChartBreakdown breakdown,
  required Map<int, List<int>> expenseTags,
  required Map<int, String> tagLabels,
  required Map<int, Tag> tagById,
  required String untaggedLabel,
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
      case ExpenseChartBreakdown.tags:
        final ids = expenseTags[expense.id] ?? const <int>[];
        if (ids.isEmpty) {
          const key = '__untagged__';
          amounts[key] = (amounts[key] ?? 0) + amount;
          labels[key] = untaggedLabel;
          colors[key] ??= chartColorAt(0);
        } else {
          final share = amount ~/ ids.length;
          var remainder = amount - share * ids.length;
          for (final id in ids) {
            final key = 'tag_$id';
            final part = share + (remainder > 0 ? 1 : 0);
            if (remainder > 0) remainder--;
            amounts[key] = (amounts[key] ?? 0) + part;
            labels[key] = tagLabels[id] ?? untaggedLabel;
            final tag = tagById[id];
            colors[key] ??=
                colorFromValue(tag?.colorValue) ?? chartColorAt(id);
          }
        }
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
