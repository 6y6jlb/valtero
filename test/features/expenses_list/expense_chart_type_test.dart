import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';

void main() {
  test('expenseChartTypeFromName defaults to donut', () {
    expect(expenseChartTypeFromName(null), ExpenseChartType.donut);
    expect(expenseChartTypeFromName(''), ExpenseChartType.donut);
    expect(expenseChartTypeFromName('nope'), ExpenseChartType.donut);
  });

  test('expenseChartTypeFromName parses donut and column', () {
    expect(expenseChartTypeFromName('donut'), ExpenseChartType.donut);
    expect(expenseChartTypeFromName('column'), ExpenseChartType.column);
  });
}
