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
