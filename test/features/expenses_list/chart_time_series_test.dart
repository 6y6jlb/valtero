import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/features/expenses_list/model/chart_time_series.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';

void main() {
  group('autoDateGranularityFor', () {
    test('uses day for periods up to 31 days', () {
      expect(
        autoDateGranularityFor(DateTime(2026, 1, 1), DateTime(2026, 1, 31)),
        ExpenseChartBreakdown.day,
      );
    });

    test('uses week for periods up to 92 days', () {
      expect(
        autoDateGranularityFor(DateTime(2026, 1, 1), DateTime(2026, 3, 31)),
        ExpenseChartBreakdown.week,
      );
    });

    test('uses month for periods up to ~2 years', () {
      expect(
        autoDateGranularityFor(DateTime(2026, 1, 1), DateTime(2027, 6, 1)),
        ExpenseChartBreakdown.month,
      );
    });

    test('uses year for longer periods', () {
      expect(
        autoDateGranularityFor(DateTime(2020, 1, 1), DateTime(2026, 1, 1)),
        ExpenseChartBreakdown.year,
      );
    });
  });

  group('capChartSeries', () {
    test('rolls excess series into Other', () {
      final series = [
        for (var i = 0; i < 7; i++)
          ChartSeriesDef(
            key: 's$i',
            label: 'S$i',
            color: Colors.blue,
          ),
      ];
      final points = [
        ChartTimeSeriesPoint(
          dateKey: '2026-01',
          dateLabel: '2026-01',
          amountBySeriesKey: {
            for (var i = 0; i < 7; i++) 's$i': (7 - i) * 100,
          },
          totalMinor: 2800,
        ),
      ];
      final capped = capChartSeries(
        series: series,
        points: points,
        otherLabel: 'Other',
        otherColor: Colors.grey,
        maxSeries: 5,
      );
      expect(capped.series.length, 6);
      expect(capped.series.last.key, kChartOtherSeriesKey);
      expect(
        capped.points.first.amountBySeriesKey[kChartOtherSeriesKey],
        100 + 200,
      );
    });

    test('leaves all series when caller skips cap for subcategories', () {
      final series = [
        for (var i = 0; i < 8; i++)
          ChartSeriesDef(
            key: 's$i',
            label: 'S$i',
            color: Colors.blue,
            iconKey: 'food',
          ),
      ];
      final points = [
        ChartTimeSeriesPoint(
          dateKey: '2026-01',
          dateLabel: '2026-01',
          amountBySeriesKey: {
            for (var i = 0; i < 8; i++) 's$i': 100,
          },
          totalMinor: 800,
        ),
      ];
      // Aggregators skip capChartSeries when includeSubcategories is true.
      expect(series.length, 8);
      expect(
        series.every((s) => s.key != kChartOtherSeriesKey),
        isTrue,
      );
      expect(points.first.amountBySeriesKey.length, 8);
      expect(series.first.iconKey, 'food');
    });
  });
}
