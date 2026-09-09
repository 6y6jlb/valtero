import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/money.dart';

/// Mirrors `filterExpenses` / `sortExpenses` for [Income] rows.
///
/// Reuses [ExpenseListQuery] as-is (same filter/sort shape) to avoid
/// duplicating the query model for v1.
List<Income> filterIncomes({
  required List<Income> all,
  required ExpenseListQuery query,
  required Map<int, List<int>> incomeTags,
  String timeZoneId = kSystemTimeZoneId,
}) {
  return all.where((income) {
    if (query.currencyCode != null &&
        income.storedCurrencyCode != query.currencyCode) {
      return false;
    }
    if (query.from != null &&
        income.occurredAt.isBefore(
          dayStartInTimeZone(query.from!, timeZoneId),
        )) {
      return false;
    }
    if (query.to != null &&
        income.occurredAt.isAfter(dayEndInTimeZone(query.to!, timeZoneId))) {
      return false;
    }
    if (query.tagIds.isNotEmpty) {
      final ids = incomeTags[income.id] ?? const <int>[];
      if (!query.tagIds.any(ids.contains)) return false;
    }
    if (query.paymentMethodIds.isNotEmpty) {
      final id = income.paymentMethodId;
      if (id == null || !query.paymentMethodIds.contains(id)) return false;
    }
    if (query.countryCodes.isNotEmpty) {
      final code = income.countryCode?.toUpperCase();
      if (code == null ||
          !query.countryCodes.map((c) => c.toUpperCase()).contains(code)) {
        return false;
      }
    }
    return true;
  }).toList();
}

int incomeSortAmountMinor(
  Income income, {
  Map<String, double>? displayRates,
  String? displayCurrency,
}) {
  if (displayCurrency == null || displayRates == null) {
    return income.storedAmountMinor;
  }
  final rate = displayRates[income.storedCurrencyCode.toUpperCase()];
  if (rate == null) return income.storedAmountMinor;
  return Money.convertMinor(
    originalMinor: income.storedAmountMinor,
    rate: rate,
  );
}

int? incomeConvertedMinor(
  Income income, {
  Map<String, double>? displayRates,
  String? displayCurrency,
}) {
  if (displayCurrency == null || displayRates == null) return null;
  final rate = displayRates[income.storedCurrencyCode.toUpperCase()];
  if (rate == null) return null;
  return Money.convertMinor(
    originalMinor: income.storedAmountMinor,
    rate: rate,
  );
}

List<Income> sortIncomes({
  required List<Income> list,
  required ExpenseListQuery query,
  Map<String, double>? displayRates,
  String? displayCurrency,
}) {
  final sorted = [...list];
  int compare(Income a, Income b) {
    final raw = switch (query.sort) {
      ExpenseListSortField.date => a.occurredAt.compareTo(b.occurredAt),
      ExpenseListSortField.amount => incomeSortAmountMinor(
          a,
          displayRates: displayRates,
          displayCurrency: displayCurrency,
        ).compareTo(
          incomeSortAmountMinor(
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
