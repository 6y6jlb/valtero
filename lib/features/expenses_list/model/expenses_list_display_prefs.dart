import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/shared/settings/app_settings.dart';

ExpenseListViewMode expensesViewModeFromSettings(AppSettings settings) {
  return ExpenseListViewMode.values.firstWhere(
    (v) => v.name == settings.expensesListView,
    orElse: () => ExpenseListViewMode.list,
  );
}

ExpenseListGroup expensesGroupFromSettings(AppSettings settings) {
  final group = ExpenseListGroup.values.firstWhere(
    (g) => g.name == settings.expensesListGroup,
    orElse: () => ExpenseListGroup.currency,
  );
  return group == ExpenseListGroup.none ? ExpenseListGroup.currency : group;
}

ExpenseChartBreakdown expensesChartBreakdownFromSettings(AppSettings settings) {
  return ExpenseChartBreakdown.values.firstWhere(
    (b) => b.name == settings.expensesChartBreakdown,
    orElse: () => ExpenseChartBreakdown.currency,
  );
}
