import 'package:valtero/features/expenses_list/model/expense_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/income_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/recent_operation.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/money.dart';

/// Cash flow spans both directions, whose category tags are separate tag
/// kinds, so a tag filter picked on the Expenses or Income tab would drop the
/// whole opposite direction. Date / currency / payment / country still apply.
ExpenseListQuery cashFlowQueryOf(ExpenseListQuery query) =>
    query.tagIds.isEmpty ? query : query.copyWith(tagIds: {});

/// Temporal cash-flow chart aggregation only respects date and currency;
/// payment / country filters stay on the Expenses or Income tabs.
ExpenseListQuery cashFlowChartQueryOf(ExpenseListQuery query) =>
    cashFlowQueryOf(query).copyWith(
      paymentMethodIds: {},
      countryCodes: {},
    );

/// Filters both directions with the shared query and merges them into one
/// date-sorted list of [RecentOperation].
List<RecentOperation> filterCashFlowOperations({
  required List<Expense> expenses,
  required List<Income> incomes,
  required ExpenseListQuery query,
  required Map<int, List<int>> expenseTags,
  required Map<int, List<int>> incomeTags,
  Set<int> possibleDuplicateExpenseIds = const {},
  Set<int> possibleDuplicateIncomeIds = const {},
  String timeZoneId = kSystemTimeZoneId,
}) {
  final effective = cashFlowQueryOf(query);
  return mergeRecentOperations(
    expenses: filterExpenses(
      all: expenses,
      query: effective,
      expenseTags: expenseTags,
      timeZoneId: timeZoneId,
    ),
    incomes: filterIncomes(
      all: incomes,
      query: effective,
      incomeTags: incomeTags,
      timeZoneId: timeZoneId,
    ),
    possibleDuplicateExpenseIds: possibleDuplicateExpenseIds,
    possibleDuplicateIncomeIds: possibleDuplicateIncomeIds,
  );
}

int? cashFlowConvertedMinor(
  RecentOperation op, {
  Map<String, double>? displayRates,
  String? displayCurrency,
}) {
  if (displayCurrency == null || displayRates == null) return null;
  final rate = displayRates[op.currencyCode.toUpperCase()];
  if (rate == null) return null;
  return Money.convertMinor(originalMinor: op.amountMinor, rate: rate);
}

int cashFlowSortAmountMinor(
  RecentOperation op, {
  Map<String, double>? displayRates,
  String? displayCurrency,
}) =>
    cashFlowConvertedMinor(
      op,
      displayRates: displayRates,
      displayCurrency: displayCurrency,
    ) ??
    op.amountMinor;

List<RecentOperation> sortCashFlowOperations({
  required List<RecentOperation> list,
  required ExpenseListQuery query,
  Map<String, double>? displayRates,
  String? displayCurrency,
}) {
  final sorted = [...list];
  int compare(RecentOperation a, RecentOperation b) {
    final raw = switch (query.sort) {
      ExpenseListSortField.date => a.occurredAt.compareTo(b.occurredAt),
      ExpenseListSortField.amount => cashFlowSortAmountMinor(
          a,
          displayRates: displayRates,
          displayCurrency: displayCurrency,
        ).compareTo(
          cashFlowSortAmountMinor(
            b,
            displayRates: displayRates,
            displayCurrency: displayCurrency,
          ),
        ),
      ExpenseListSortField.currency =>
        a.currencyCode.compareTo(b.currencyCode),
    };
    return query.ascending ? raw : -raw;
  }

  sorted.sort(compare);
  return sorted;
}
