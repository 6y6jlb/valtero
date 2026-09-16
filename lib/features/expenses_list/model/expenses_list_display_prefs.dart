import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/model/grouping/cash_flow_grouper_for.dart';
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

ExpenseListViewMode cashFlowViewModeFromSettings(AppSettings settings) {
  return ExpenseListViewMode.values.firstWhere(
    (v) => v.name == settings.cashFlowListView,
    orElse: () => ExpenseListViewMode.list,
  );
}

/// Cash flow groups by currency / date / country / payment only; anything
/// else (including the tag groups persisted by the other directions) falls
/// back to currency.
ExpenseListGroup cashFlowGroupFromSettings(AppSettings settings) {
  final group = ExpenseListGroup.values.firstWhere(
    (g) => g.name == settings.cashFlowListGroup,
    orElse: () => ExpenseListGroup.currency,
  );
  return cashFlowGroupOptions.contains(group)
      ? group
      : ExpenseListGroup.currency;
}

ExpenseChartBreakdown cashFlowChartDatePeriodFromSettings(
  AppSettings settings,
) {
  return expenseChartDatePeriodFromName(settings.cashFlowChartDatePeriod);
}

ExpenseChartType cashFlowChartTypeFromSettings(AppSettings settings) {
  return expenseChartTypeFromName(settings.cashFlowChartType);
}

/// Values to persist for the cash-flow list (temporal period + chart shape).
({
  String view,
  String group,
  String chartDatePeriod,
  String chartType,
}) cashFlowListDisplayPersistValues({
  required ExpenseListViewMode view,
  required ExpenseListGroup appliedGroup,
  required ExpenseChartBreakdown chartDatePeriod,
  required ExpenseChartType chartType,
}) {
  final nextGroup = cashFlowGroupOptions.contains(appliedGroup)
      ? appliedGroup
      : ExpenseListGroup.currency;
  return (
    view: view.name,
    group: nextGroup.name,
    chartDatePeriod: isDateChartBreakdown(chartDatePeriod)
        ? chartDatePeriod.name
        : ExpenseChartBreakdown.month.name,
    chartType: chartType.name,
  );
}
