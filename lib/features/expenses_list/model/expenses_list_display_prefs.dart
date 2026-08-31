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
  final name = settings.expensesListGroup;
  if (name == 'tag') return ExpenseListGroup.tagCustom;
  if (name == 'tagResource') return ExpenseListGroup.payment;
  if (name == 'tagCountry') return ExpenseListGroup.country;
  if (name == 'tagTrip') return ExpenseListGroup.currency;
  final group = ExpenseListGroup.values.firstWhere(
    (g) => g.name == name,
    orElse: () => ExpenseListGroup.currency,
  );
  return group == ExpenseListGroup.none ? ExpenseListGroup.currency : group;
}

ExpenseChartBreakdown expensesChartBreakdownFromSettings(AppSettings settings) {
  return expenseChartBreakdownFromName(settings.expensesChartBreakdown);
}

ExpenseChartType expensesChartTypeFromSettings(AppSettings settings) {
  return expenseChartTypeFromName(settings.expensesChartType);
}
