import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';

/// One named series in a time-series chart (one line / stack segment color).
class ChartSeriesDef {
  final String key;
  final String label;
  final Color color;

  /// Catalog icon key for tag/payment glyphs in the legend.
  final String? iconKey;

  /// ISO country or currency code for a flag glyph in the legend.
  final String? flagCode;

  /// When true, [flagCode] is a currency ISO (currency flag); otherwise country.
  final bool flagIsCurrency;

  const ChartSeriesDef({
    required this.key,
    required this.label,
    required this.color,
    this.iconKey,
    this.flagCode,
    this.flagIsCurrency = false,
  });
}

/// One X-axis bucket (day/week/month/year) with per-series amounts.
class ChartTimeSeriesPoint {
  final String dateKey;
  final String dateLabel;
  final Map<String, int> amountBySeriesKey;
  final int totalMinor;

  const ChartTimeSeriesPoint({
    required this.dateKey,
    required this.dateLabel,
    required this.amountBySeriesKey,
    required this.totalMinor,
  });
}

typedef ChartTimeSeriesAggregation = ({
  List<ChartSeriesDef> series,
  List<ChartTimeSeriesPoint> points,
  int missingRateCount,
});

/// Stable key used for the capped "Other" series.
const kChartOtherSeriesKey = '__other__';

/// Stable key used for the bold Total line (not a stack segment).
const kChartTotalSeriesKey = '__total__';

/// Picks day / week / month / year from the selected period length.
ExpenseChartBreakdown autoDateGranularityFor(DateTime from, DateTime to) {
  final days = to.difference(from).inDays.abs() + 1;
  if (days <= 31) return ExpenseChartBreakdown.day;
  if (days <= 92) return ExpenseChartBreakdown.week;
  if (days <= 730) return ExpenseChartBreakdown.month;
  return ExpenseChartBreakdown.year;
}

/// Caps [series] to the top [maxSeries] by total amount across [points],
/// rolling the rest into an "Other" series.
({
  List<ChartSeriesDef> series,
  List<ChartTimeSeriesPoint> points,
}) capChartSeries({
  required List<ChartSeriesDef> series,
  required List<ChartTimeSeriesPoint> points,
  required String otherLabel,
  required Color otherColor,
  int maxSeries = 5,
}) {
  if (series.length <= maxSeries) {
    return (series: series, points: points);
  }

  final totals = <String, int>{
    for (final s in series) s.key: 0,
  };
  for (final p in points) {
    for (final e in p.amountBySeriesKey.entries) {
      totals[e.key] = (totals[e.key] ?? 0) + e.value;
    }
  }
  final ranked = series.toList()
    ..sort((a, b) => (totals[b.key] ?? 0).compareTo(totals[a.key] ?? 0));
  final kept = ranked.take(maxSeries).toList();
  final keptKeys = {for (final s in kept) s.key};
  final droppedKeys = {
    for (final s in ranked.skip(maxSeries)) s.key,
  };

  final cappedSeries = [
    ...kept,
    ChartSeriesDef(
      key: kChartOtherSeriesKey,
      label: otherLabel,
      color: otherColor,
    ),
  ];

  final cappedPoints = [
    for (final p in points)
      () {
        final amounts = <String, int>{};
        var other = 0;
        for (final e in p.amountBySeriesKey.entries) {
          if (keptKeys.contains(e.key)) {
            amounts[e.key] = e.value;
          } else if (droppedKeys.contains(e.key)) {
            other += e.value;
          }
        }
        if (other > 0) amounts[kChartOtherSeriesKey] = other;
        return ChartTimeSeriesPoint(
          dateKey: p.dateKey,
          dateLabel: p.dateLabel,
          amountBySeriesKey: amounts,
          totalMinor: p.totalMinor,
        );
      }(),
  ];

  return (series: cappedSeries, points: cappedPoints);
}
