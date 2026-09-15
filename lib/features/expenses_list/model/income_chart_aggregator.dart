import 'package:flutter/material.dart';
import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/shared/consts/palette.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/currency_symbol.dart';
import 'package:valtero/shared/utils/money.dart';

/// Mirrors `sumExpensesInCurrency` for [Income] rows.
Future<({int totalMinor, int convertibleCount})> sumIncomesInCurrency({
  required List<Income> incomes,
  required String targetCurrency,
  required RateResolver resolver,
}) async {
  final target = targetCurrency.toUpperCase();
  var total = 0;
  var convertible = 0;
  for (final income in incomes) {
    final from = income.storedCurrencyCode.toUpperCase();
    if (from == target) {
      total += income.storedAmountMinor;
      convertible++;
      continue;
    }
    final rate = await resolver.getRate(from, target);
    if (rate == null) continue;
    total += Money.convertMinor(
      originalMinor: income.storedAmountMinor,
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

void _aggregateIncomeByTagKind({
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
          tagById[id]!.parentTagId == null &&
          _incomeTagMatchesBreakdown(tagById[id]!, breakdown))
        id,
  ];

  if (matching.isEmpty) {
    final rolled = <int>{};
    for (final id in tagIds) {
      final tag = tagById[id];
      if (tag == null || tag.parentTagId == null) continue;
      if (!_incomeTagMatchesBreakdown(tag, breakdown)) continue;
      final parent = tagById[tag.parentTagId!];
      if (parent != null &&
          parent.parentTagId == null &&
          _incomeTagMatchesBreakdown(parent, breakdown)) {
        rolled.add(parent.id);
      }
    }
    matching.addAll(rolled);
  }

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

void _aggregateIncomeByPayment({
  required int amount,
  required Income income,
  required Map<int, PaymentMethod> paymentById,
  required Map<int, String> paymentLabels,
  required Map<String, int> amounts,
  required Map<String, String> labels,
  required Map<String, Color> colors,
  required String untaggedLabel,
}) {
  final id = income.paymentMethodId;
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

void _aggregateIncomeByCountry({
  required int amount,
  required Income income,
  required Map<String, int> amounts,
  required Map<String, String> labels,
  required Map<String, Color> colors,
  required String untaggedLabel,
  required String Function(String code) countryLabel,
}) {
  final code = income.countryCode?.toUpperCase();
  if (code == null || code.isEmpty) {
    const key = '__untagged__';
    amounts[key] = (amounts[key] ?? 0) + amount;
    labels[key] = untaggedLabel;
    colors[key] ??= chartColorAt(0);
    return;
  }
  final key = 'country_$code';
  amounts[key] = (amounts[key] ?? 0) + amount;
  labels[key] = countryLabel(code);
  colors[key] ??= chartColorAt(code.hashCode);
}

typedef IncomeChartAggregation = ({
  List<DonutChartSlice> slices,
  int missingRateCount,
});

/// Mirrors `aggregateExpensesForChart` for [Income] rows.
Future<IncomeChartAggregation> aggregateIncomesForChart({
  required List<Income> incomes,
  required String primaryCurrency,
  required RateResolver resolver,
  required ExpenseChartBreakdown breakdown,
  required Map<int, List<int>> incomeTags,
  required Map<int, String> tagLabels,
  required Map<int, Tag> tagById,
  required String untaggedLabel,
  Map<int, PaymentMethod> paymentById = const {},
  Map<int, String> paymentLabels = const {},
  String Function(String code)? countryLabel,
  String timeZoneId = kSystemTimeZoneId,
}) async {
  final amounts = <String, int>{};
  final labels = <String, String>{};
  final colors = <String, Color>{};
  final sliceCurrencies = <String, String>{};
  final resolveCountry = countryLabel ?? (code) => code;
  var missingRateCount = 0;
  final target = primaryCurrency.toUpperCase();

  for (final income in incomes) {
    final from = income.storedCurrencyCode.toUpperCase();
    final rate = from == target
        ? 1.0
        : await resolver.getRate(income.storedCurrencyCode, primaryCurrency);
    if (rate == null && from != target) missingRateCount++;
    final amount = rate == null
        ? income.storedAmountMinor
        : Money.convertMinor(
            originalMinor: income.storedAmountMinor,
            rate: rate,
          );
    if (amount <= 0) continue;

    switch (breakdown) {
      case ExpenseChartBreakdown.currency:
        final key = from;
        amounts[key] = (amounts[key] ?? 0) + income.storedAmountMinor;
        labels[key] = currencySymbolFor(key);
        colors[key] ??= chartColorAt(key.hashCode);
        sliceCurrencies[key] = key;
      case ExpenseChartBreakdown.day:
        final key = calendarDayKey(income.occurredAt, timeZoneId);
        amounts[key] = (amounts[key] ?? 0) + amount;
        labels[key] = key;
        colors[key] ??= chartColorAt(amounts.length);
      case ExpenseChartBreakdown.week:
        final key = calendarWeekKey(income.occurredAt, timeZoneId);
        amounts[key] = (amounts[key] ?? 0) + amount;
        labels[key] = key;
        colors[key] ??= chartColorAt(amounts.length);
      case ExpenseChartBreakdown.month:
        final key = calendarMonthKey(income.occurredAt, timeZoneId);
        amounts[key] = (amounts[key] ?? 0) + amount;
        labels[key] = key;
        colors[key] ??= chartColorAt(amounts.length);
      case ExpenseChartBreakdown.year:
        final key = calendarYearKey(income.occurredAt, timeZoneId);
        amounts[key] = (amounts[key] ?? 0) + amount;
        labels[key] = key;
        colors[key] ??= chartColorAt(key.hashCode);
      case ExpenseChartBreakdown.payment:
        _aggregateIncomeByPayment(
          amount: amount,
          income: income,
          paymentById: paymentById,
          paymentLabels: paymentLabels,
          amounts: amounts,
          labels: labels,
          colors: colors,
          untaggedLabel: untaggedLabel,
        );
      case ExpenseChartBreakdown.country:
        _aggregateIncomeByCountry(
          amount: amount,
          income: income,
          amounts: amounts,
          labels: labels,
          colors: colors,
          untaggedLabel: untaggedLabel,
          countryLabel: resolveCountry,
        );
      case ExpenseChartBreakdown.tagCustom:
        _aggregateIncomeByTagKind(
          amount: amount,
          tagIds: incomeTags[income.id] ?? const <int>[],
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
  return (
    slices: [
      for (final e in entries)
        DonutChartSlice(
          key: e.key,
          label: labels[e.key] ?? e.key,
          amountMinor: e.value,
          color: colors[e.key] ?? chartColorAt(i++),
          currencyCode: sliceCurrencies[e.key],
        ),
    ],
    missingRateCount: missingRateCount,
  );
}

/// Income category tags use [TagKind.income]; expense chart matching maps
/// `tagCustom` to [TagKind.custom], so income charts need their own check.
bool _incomeTagMatchesBreakdown(Tag tag, ExpenseChartBreakdown breakdown) {
  if (breakdown == ExpenseChartBreakdown.tagCustom) {
    return tagMatchesKind(tag, TagKind.income);
  }
  return tagMatchesChartBreakdown(tag, breakdown);
}
