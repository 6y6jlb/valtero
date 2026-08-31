import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:valtero/features/expenses_list/model/expense_chart_drill_down.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';

void main() {
  late ExpenseListQuery base;

  setUpAll(() {
    tzdata.initializeTimeZones();
  });

  setUp(() {
    base = ExpenseListQuery.sessionDefaults();
  });

  group('expenseChartDrillDownQuery', () {
    test('country slice sets countryCodes', () {
      final q = expenseChartDrillDownQuery(
        base: base,
        breakdown: ExpenseChartBreakdown.country,
        sliceKey: 'country_RU',
      );
      expect(q?.countryCodes, {'RU'});
    });

    test('day slice sets from/to to that calendar day', () {
      final q = expenseChartDrillDownQuery(
        base: base,
        breakdown: ExpenseChartBreakdown.day,
        sliceKey: '2026-03-15',
      );
      expect(q?.from, DateTime(2026, 3, 15));
      expect(q?.to, DateTime(2026, 3, 15));
    });

    test('week slice sets Monday through Sunday', () {
      final q = expenseChartDrillDownQuery(
        base: base,
        breakdown: ExpenseChartBreakdown.week,
        sliceKey: '2026-03-09',
      );
      expect(q?.from, DateTime(2026, 3, 9));
      expect(q?.to, DateTime(2026, 3, 15));
    });

    test('legacy tagCountry name maps to country breakdown', () {
      expect(
        expenseChartBreakdownFromName('tagCountry'),
        ExpenseChartBreakdown.country,
      );
      expect(
        expenseChartBreakdownFromName('tagTrip'),
        ExpenseChartBreakdown.currency,
      );
    });
  });
}
