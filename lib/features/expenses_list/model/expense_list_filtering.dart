import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/money.dart';

DateTime expenseDayStart(DateTime date) =>
    DateTime(date.year, date.month, date.day);

DateTime expenseDayEnd(DateTime date) =>
    DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

List<Expense> filterExpenses({
  required List<Expense> all,
  required ExpenseListQuery query,
  required Map<int, List<int>> expenseTags,
}) {
  return all.where((expense) {
    if (query.currencyCode != null &&
        expense.storedCurrencyCode != query.currencyCode) {
      return false;
    }
    if (query.from != null &&
        expense.occurredAt.isBefore(expenseDayStart(query.from!))) {
      return false;
    }
    if (query.to != null &&
        expense.occurredAt.isAfter(expenseDayEnd(query.to!))) {
      return false;
    }
    if (query.tagIds.isNotEmpty) {
      final ids = expenseTags[expense.id] ?? const <int>[];
      if (!query.tagIds.any(ids.contains)) return false;
    }
    return true;
  }).toList();
}

int expenseSortAmountMinor(
  Expense expense, {
  Map<String, double>? displayRates,
  String? displayCurrency,
}) {
  if (displayCurrency == null || displayRates == null) {
    return expense.storedAmountMinor;
  }
  final rate = displayRates[expense.storedCurrencyCode.toUpperCase()];
  if (rate == null) return expense.storedAmountMinor;
  return Money.convertMinor(
    originalMinor: expense.storedAmountMinor,
    rate: rate,
  );
}

int? expenseConvertedMinor(
  Expense expense, {
  Map<String, double>? displayRates,
  String? displayCurrency,
}) {
  if (displayCurrency == null || displayRates == null) return null;
  final rate = displayRates[expense.storedCurrencyCode.toUpperCase()];
  if (rate == null) return null;
  return Money.convertMinor(
    originalMinor: expense.storedAmountMinor,
    rate: rate,
  );
}

List<Expense> sortExpenses({
  required List<Expense> list,
  required ExpenseListQuery query,
  Map<String, double>? displayRates,
  String? displayCurrency,
}) {
  final sorted = [...list];
  int compare(Expense a, Expense b) {
    final raw = switch (query.sort) {
      ExpenseListSortField.date => a.occurredAt.compareTo(b.occurredAt),
      ExpenseListSortField.amount => expenseSortAmountMinor(
          a,
          displayRates: displayRates,
          displayCurrency: displayCurrency,
        ).compareTo(
          expenseSortAmountMinor(
            b,
            displayRates: displayRates,
            displayCurrency: displayCurrency,
          ),
        ),
      ExpenseListSortField.currency =>
        a.storedCurrencyCode.compareTo(b.storedCurrencyCode),
    };
    return query.ascending ? raw : -raw;
  }

  sorted.sort(compare);
  return sorted;
}
