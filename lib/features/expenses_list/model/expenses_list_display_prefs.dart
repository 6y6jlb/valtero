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

ExpenseChartBreakdown expensesChartDatePeriodFromSettings(AppSettings settings) {
  return expenseChartDatePeriodFromName(settings.expensesChartDatePeriod);
}


/// Resolves the values to persist for expenses-list display settings.
({
  String view,
  String group,
  String chartBreakdown,
  String chartType,
  String chartDatePeriod,
}) expensesListDisplayPersistValues({
  required ExpenseListViewMode view,
  required ExpenseListGroup appliedGroup,
  required ExpenseChartBreakdown chartBreakdown,
  required ExpenseChartType chartType,
  required ExpenseChartBreakdown chartDatePeriod,
}) {
  final nextGroup = appliedGroup == ExpenseListGroup.none
      ? ExpenseListGroup.currency
      : appliedGroup;
  final nextDatePeriod = isDateChartBreakdown(chartBreakdown)
      ? chartBreakdown
      : chartDatePeriod;
  return (
    view: view.name,
    group: nextGroup.name,
    chartBreakdown: chartBreakdown.name,
    chartType: chartType.name,
    chartDatePeriod: nextDatePeriod.name,
  );
}

ExpenseListViewMode incomeViewModeFromSettings(AppSettings settings) {
  return ExpenseListViewMode.values.firstWhere(
    (v) => v.name == settings.incomeListView,
    orElse: () => ExpenseListViewMode.list,
  );
}

ExpenseListGroup incomeGroupFromSettings(AppSettings settings) {
  final name = settings.incomeListGroup;
  if (name == 'tag') return ExpenseListGroup.tagCustom;
  final group = ExpenseListGroup.values.firstWhere(
    (g) => g.name == name,
    orElse: () => ExpenseListGroup.currency,
  );
  return group == ExpenseListGroup.none ? ExpenseListGroup.currency : group;
}

ExpenseChartBreakdown incomeChartBreakdownFromSettings(AppSettings settings) {
  return expenseChartBreakdownFromName(settings.incomeChartBreakdown);
}

ExpenseChartType incomeChartTypeFromSettings(AppSettings settings) {
  return expenseChartTypeFromName(settings.incomeChartType);
}

ExpenseChartBreakdown incomeChartDatePeriodFromSettings(AppSettings settings) {
  return expenseChartDatePeriodFromName(settings.incomeChartDatePeriod);
}

/// Same shape as [expensesListDisplayPersistValues] for income prefs.
({
  String view,
  String group,
  String chartBreakdown,
  String chartType,
  String chartDatePeriod,
}) incomeListDisplayPersistValues({
  required ExpenseListViewMode view,
  required ExpenseListGroup appliedGroup,
  required ExpenseChartBreakdown chartBreakdown,
  required ExpenseChartType chartType,
  required ExpenseChartBreakdown chartDatePeriod,
}) =>
    expensesListDisplayPersistValues(
      view: view,
      appliedGroup: appliedGroup,
      chartBreakdown: chartBreakdown,
      chartType: chartType,
      chartDatePeriod: chartDatePeriod,
    );
