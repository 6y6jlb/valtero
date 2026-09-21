import 'package:flutter/material.dart';
import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/entities/tag/model/tag_hierarchy.dart';
import 'package:valtero/features/expenses_list/model/chart_time_series.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/shared/consts/palette.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/currency_symbol.dart';
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
  required Map<String, String?> iconKeys,
  required int tagId,
  required int part,
  required Map<int, String> tagLabels,
  required Map<int, Tag> tagById,
  required String untaggedLabel,
}) {
  final key = 'tag_$tagId';
  amounts[key] = (amounts[key] ?? 0) + part;
  labels[key] = categoryTargetLabel(
    tagId: tagId,
    tagById: tagById,
    tagLabels: tagLabels,
    fallback: untaggedLabel,
  );
  final tag = tagById[tagId];
  colors[key] ??= colorFromValue(tag?.colorValue) ?? chartColorAt(tagId);
  iconKeys[key] ??= tag?.iconKey;
}

void _aggregateExpenseByTagKind({
  required int amount,
  required List<int> tagIds,
  required ExpenseChartBreakdown breakdown,
  required Map<int, Tag> tagById,
  required Map<String, int> amounts,
  required Map<String, String> labels,
  required Map<String, Color> colors,
  required Map<String, String?> iconKeys,
  required Map<int, String> tagLabels,
  required String untaggedLabel,
  bool includeSubcategories = false,
}) {
  final kind = tagKindFromChartBreakdown(breakdown);
  if (kind == null) return;
  final matching = resolveCategoryTargets(
    tagIds: tagIds,
    kind: kind,
    tagById: tagById,
    includeSubcategories: includeSubcategories,
  );

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
      iconKeys: iconKeys,
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
      iconKeys: iconKeys,
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
  required Map<String, String?> iconKeys,
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
  iconKeys[key] ??= method.iconKey;
}

void _aggregateExpenseByCountry({
  required int amount,
  required Expense expense,
  required Map<String, int> amounts,
  required Map<String, String> labels,
  required Map<String, Color> colors,
  required Map<String, String?> flagCodes,
  required String untaggedLabel,
  required String Function(String code) countryLabel,
}) {
  final code = expense.countryCode?.toUpperCase();
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
  flagCodes[key] ??= code;
}

typedef ExpenseChartAggregation = ({
  List<DonutChartSlice> slices,
  int missingRateCount,
});

Future<ExpenseChartAggregation> aggregateExpensesForChart({
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
  String Function(String code)? countryLabel,
  String timeZoneId = kSystemTimeZoneId,
  bool includeSubcategories = false,
}) async {
  final amounts = <String, int>{};
  final labels = <String, String>{};
  final colors = <String, Color>{};
  final iconKeys = <String, String?>{};
  final flagCodes = <String, String?>{};
  final flagIsCurrency = <String, bool>{};
  final sliceCurrencies = <String, String>{};
  final resolveCountry = countryLabel ?? (code) => code;
  var missingRateCount = 0;
  final target = primaryCurrency.toUpperCase();

  for (final expense in expenses) {
    final from = expense.storedCurrencyCode.toUpperCase();
    final rate = from == target
        ? 1.0
        : await resolver.getRate(expense.storedCurrencyCode, primaryCurrency);
    if (rate == null && from != target) missingRateCount++;
    final amount = rate == null
        ? expense.storedAmountMinor
        : Money.convertMinor(
            originalMinor: expense.storedAmountMinor,
            rate: rate,
          );
    if (amount <= 0) continue;

    switch (breakdown) {
      case ExpenseChartBreakdown.currency:
        final key = from;
        amounts[key] = (amounts[key] ?? 0) + expense.storedAmountMinor;
        labels[key] = currencySymbolFor(key);
        colors[key] ??= chartColorAt(key.hashCode);
        sliceCurrencies[key] = key;
        flagCodes[key] ??= key;
        flagIsCurrency[key] = true;
      case ExpenseChartBreakdown.day:
        final key = calendarDayKey(expense.occurredAt, timeZoneId);
        amounts[key] = (amounts[key] ?? 0) + amount;
        labels[key] = key;
        colors[key] ??= chartColorAt(amounts.length);
      case ExpenseChartBreakdown.week:
        final key = calendarWeekKey(expense.occurredAt, timeZoneId);
        amounts[key] = (amounts[key] ?? 0) + amount;
        labels[key] = key;
        colors[key] ??= chartColorAt(amounts.length);
      case ExpenseChartBreakdown.month:
        final key = calendarMonthKey(expense.occurredAt, timeZoneId);
        amounts[key] = (amounts[key] ?? 0) + amount;
        labels[key] = key;
        colors[key] ??= chartColorAt(amounts.length);
      case ExpenseChartBreakdown.year:
        final key = calendarYearKey(expense.occurredAt, timeZoneId);
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
          iconKeys: iconKeys,
          untaggedLabel: untaggedLabel,
        );
      case ExpenseChartBreakdown.country:
        _aggregateExpenseByCountry(
          amount: amount,
          expense: expense,
          amounts: amounts,
          labels: labels,
          colors: colors,
          flagCodes: flagCodes,
          untaggedLabel: untaggedLabel,
          countryLabel: resolveCountry,
        );
      case ExpenseChartBreakdown.tagCustom:
        _aggregateExpenseByTagKind(
          amount: amount,
          tagIds: expenseTags[expense.id] ?? const <int>[],
          breakdown: breakdown,
          tagById: tagById,
          amounts: amounts,
          labels: labels,
          colors: colors,
          iconKeys: iconKeys,
          tagLabels: tagLabels,
          untaggedLabel: untaggedLabel,
          includeSubcategories: includeSubcategories,
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
          iconKey: iconKeys[e.key],
          flagCode: flagCodes[e.key],
          flagIsCurrency: flagIsCurrency[e.key] ?? false,
        ),
    ],
    missingRateCount: missingRateCount,
  );
}

String _dateKeyForGranularity(
  DateTime occurredAt,
  ExpenseChartBreakdown granularity,
  String timeZoneId,
) {
  return switch (granularity) {
    ExpenseChartBreakdown.day => calendarDayKey(occurredAt, timeZoneId),
    ExpenseChartBreakdown.week => calendarWeekKey(occurredAt, timeZoneId),
    ExpenseChartBreakdown.month => calendarMonthKey(occurredAt, timeZoneId),
    ExpenseChartBreakdown.year => calendarYearKey(occurredAt, timeZoneId),
    _ => calendarMonthKey(occurredAt, timeZoneId),
  };
}

void _resolveExpenseTimeSeriesSeries({
  required int amount,
  required Expense expense,
  required ExpenseChartBreakdown targetBreakdown,
  required Map<int, List<int>> expenseTags,
  required Map<int, String> tagLabels,
  required Map<int, Tag> tagById,
  required String untaggedLabel,
  required Map<int, PaymentMethod> paymentById,
  required Map<int, String> paymentLabels,
  required String Function(String code) countryLabel,
  required bool includeSubcategories,
  required Map<String, int> amounts,
  required Map<String, String> labels,
  required Map<String, Color> colors,
  required Map<String, String?> iconKeys,
  required Map<String, String?> flagCodes,
  required Map<String, bool> flagIsCurrency,
}) {
  if (isDateChartBreakdown(targetBreakdown)) {
    const key = 'total';
    amounts[key] = amount;
    labels[key] = key;
    colors[key] ??= chartColorAt(0);
    return;
  }

  switch (targetBreakdown) {
    case ExpenseChartBreakdown.currency:
      final key = expense.storedCurrencyCode.toUpperCase();
      amounts[key] = amount;
      labels[key] = currencySymbolFor(key);
      colors[key] ??= chartColorAt(key.hashCode);
      flagCodes[key] ??= key;
      flagIsCurrency[key] = true;
    case ExpenseChartBreakdown.payment:
      _aggregateExpenseByPayment(
        amount: amount,
        expense: expense,
        paymentById: paymentById,
        paymentLabels: paymentLabels,
        amounts: amounts,
        labels: labels,
        colors: colors,
        iconKeys: iconKeys,
        untaggedLabel: untaggedLabel,
      );
    case ExpenseChartBreakdown.country:
      _aggregateExpenseByCountry(
        amount: amount,
        expense: expense,
        amounts: amounts,
        labels: labels,
        colors: colors,
        flagCodes: flagCodes,
        untaggedLabel: untaggedLabel,
        countryLabel: countryLabel,
      );
    case ExpenseChartBreakdown.tagCustom:
      _aggregateExpenseByTagKind(
        amount: amount,
        tagIds: expenseTags[expense.id] ?? const <int>[],
        breakdown: targetBreakdown,
        tagById: tagById,
        amounts: amounts,
        labels: labels,
        colors: colors,
        iconKeys: iconKeys,
        tagLabels: tagLabels,
        untaggedLabel: untaggedLabel,
        includeSubcategories: includeSubcategories,
      );
    case ExpenseChartBreakdown.day:
    case ExpenseChartBreakdown.week:
    case ExpenseChartBreakdown.month:
    case ExpenseChartBreakdown.year:
      break;
  }
}

Future<ChartTimeSeriesAggregation> aggregateExpensesForTimeSeries({
  required List<Expense> expenses,
  required String primaryCurrency,
  required RateResolver resolver,
  required ExpenseChartBreakdown targetBreakdown,
  required Map<int, List<int>> expenseTags,
  required Map<int, String> tagLabels,
  required Map<int, Tag> tagById,
  required String untaggedLabel,
  required String otherLabel,
  DateTime? periodFrom,
  DateTime? periodTo,
  Map<int, PaymentMethod> paymentById = const {},
  Map<int, String> paymentLabels = const {},
  String Function(String code)? countryLabel,
  String timeZoneId = kSystemTimeZoneId,
  bool includeSubcategories = false,
  int maxSeries = 5,
}) async {
  if (expenses.isEmpty) {
    return (
      series: const <ChartSeriesDef>[],
      points: const <ChartTimeSeriesPoint>[],
      missingRateCount: 0,
    );
  }

  final DateTime from;
  final DateTime to;
  if (periodFrom != null && periodTo != null) {
    from = periodFrom;
    to = periodTo;
  } else {
    from = expenses
        .map((e) => e.occurredAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    to = expenses
        .map((e) => e.occurredAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  final totalOnly = isDateChartBreakdown(targetBreakdown);
  // Date breakdown icons pick the bucket size; otherwise fit the range.
  final granularity = totalOnly
      ? targetBreakdown
      : autoDateGranularityFor(from, to);
  final byDate = <String, Map<String, int>>{};
  final dateTotals = <String, int>{};
  final seriesLabels = <String, String>{};
  final seriesColors = <String, Color>{};
  final seriesIconKeys = <String, String?>{};
  final seriesFlagCodes = <String, String?>{};
  final seriesFlagIsCurrency = <String, bool>{};
  final resolveCountry = countryLabel ?? (code) => code;
  var missingRateCount = 0;
  final target = primaryCurrency.toUpperCase();

  for (final expense in expenses) {
    final fromCurrency = expense.storedCurrencyCode.toUpperCase();
    final rate = fromCurrency == target
        ? 1.0
        : await resolver.getRate(expense.storedCurrencyCode, primaryCurrency);
    if (rate == null && fromCurrency != target) missingRateCount++;
    final amount = rate == null
        ? expense.storedAmountMinor
        : Money.convertMinor(
            originalMinor: expense.storedAmountMinor,
            rate: rate,
          );
    if (amount <= 0) continue;

    final dateKey = _dateKeyForGranularity(
      expense.occurredAt,
      granularity,
      timeZoneId,
    );

    if (totalOnly) {
      dateTotals[dateKey] = (dateTotals[dateKey] ?? 0) + amount;
      continue;
    }

    final sliceAmounts = <String, int>{};
    final sliceLabels = <String, String>{};
    final sliceColors = <String, Color>{};
    final sliceIconKeys = <String, String?>{};
    final sliceFlagCodes = <String, String?>{};
    final sliceFlagIsCurrency = <String, bool>{};

    if (targetBreakdown == ExpenseChartBreakdown.currency) {
      final key = fromCurrency;
      // Converted amount so series + totals share the display currency axis.
      sliceAmounts[key] = amount;
      sliceLabels[key] = currencySymbolFor(key);
      sliceColors[key] = chartColorAt(key.hashCode);
      sliceFlagCodes[key] = key;
      sliceFlagIsCurrency[key] = true;
    } else {
      _resolveExpenseTimeSeriesSeries(
        amount: amount,
        expense: expense,
        targetBreakdown: targetBreakdown,
        expenseTags: expenseTags,
        tagLabels: tagLabels,
        tagById: tagById,
        untaggedLabel: untaggedLabel,
        paymentById: paymentById,
        paymentLabels: paymentLabels,
        countryLabel: resolveCountry,
        includeSubcategories: includeSubcategories,
        amounts: sliceAmounts,
        labels: sliceLabels,
        colors: sliceColors,
        iconKeys: sliceIconKeys,
        flagCodes: sliceFlagCodes,
        flagIsCurrency: sliceFlagIsCurrency,
      );
    }

    final bucket = byDate.putIfAbsent(dateKey, () => <String, int>{});
    for (final e in sliceAmounts.entries) {
      bucket[e.key] = (bucket[e.key] ?? 0) + e.value;
      seriesLabels[e.key] = sliceLabels[e.key] ?? e.key;
      seriesColors[e.key] =
          sliceColors[e.key] ??
          seriesColors[e.key] ??
          chartColorAt(e.key.hashCode);
      seriesIconKeys[e.key] ??= sliceIconKeys[e.key];
      seriesFlagCodes[e.key] ??= sliceFlagCodes[e.key];
      if (sliceFlagIsCurrency[e.key] == true) {
        seriesFlagIsCurrency[e.key] = true;
      }
    }
  }

  final sortedDateKeys = totalOnly
      ? (dateTotals.keys.toList()..sort())
      : (byDate.keys.toList()..sort());
  final points = [
    for (final dateKey in sortedDateKeys)
      () {
        if (totalOnly) {
          final total = dateTotals[dateKey] ?? 0;
          return ChartTimeSeriesPoint(
            dateKey: dateKey,
            dateLabel: dateKey,
            amountBySeriesKey: const {},
            totalMinor: total,
          );
        }
        final amounts = byDate[dateKey]!;
        final total = amounts.values.fold<int>(0, (sum, v) => sum + v);
        return ChartTimeSeriesPoint(
          dateKey: dateKey,
          dateLabel: dateKey,
          amountBySeriesKey: Map<String, int>.from(amounts),
          totalMinor: total,
        );
      }(),
  ];

  final seriesTotals = <String, int>{};
  for (final point in points) {
    for (final e in point.amountBySeriesKey.entries) {
      seriesTotals[e.key] = (seriesTotals[e.key] ?? 0) + e.value;
    }
  }

  final rankedKeys = seriesTotals.keys.toList()
    ..sort((a, b) => (seriesTotals[b] ?? 0).compareTo(seriesTotals[a] ?? 0));
  var colorIndex = 0;
  final series = [
    for (final key in rankedKeys)
      ChartSeriesDef(
        key: key,
        label: seriesLabels[key] ?? key,
        color: seriesColors[key] ?? chartColorAt(colorIndex++),
        iconKey: seriesIconKeys[key],
        flagCode: seriesFlagCodes[key],
        flagIsCurrency: seriesFlagIsCurrency[key] ?? false,
      ),
  ];

  final capped = includeSubcategories
      ? (series: series, points: points)
      : capChartSeries(
          series: series,
          points: points,
          otherLabel: otherLabel,
          otherColor: chartColorAt(0),
          maxSeries: maxSeries,
        );

  return (
    series: capped.series,
    points: capped.points,
    missingRateCount: missingRateCount,
  );
}
