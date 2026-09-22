import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/income_list_filtering.dart';
import 'package:valtero/shared/database/app_database.dart';

Income _income({
  required int id,
  required DateTime at,
  int amount = 100,
  String currency = 'USD',
  int? paymentMethodId,
  String? countryCode,
}) {
  return Income(
    kind: 'income',
    id: id,
    syncId: 'sync-$id',
    occurredAt: at,
    originalAmountMinor: amount,
    originalCurrencyCode: currency,
    storedAmountMinor: amount,
    storedCurrencyCode: currency,
    createdAt: at,
    updatedAt: at,
    duplicateDismissed: false,
    paymentMethodId: paymentMethodId,
    countryCode: countryCode,
  );
}

void main() {
  setUpAll(() {
    tzdata.initializeTimeZones();
  });

  test('filterIncomes applies currency and date range', () {
    final all = [
      _income(id: 1, at: DateTime(2026, 1, 10), currency: 'USD'),
      _income(id: 2, at: DateTime(2026, 1, 20), currency: 'EUR'),
      _income(id: 3, at: DateTime(2026, 2, 1), currency: 'USD'),
    ];
    final filtered = filterIncomes(
      all: all,
      query: ExpenseListQuery(
        currencyCode: 'USD',
        from: DateTime(2026, 1, 1),
        to: DateTime(2026, 1, 15),
      ),
      incomeTags: const {},
    );
    expect(filtered.map((e) => e.id).toList(), [1]);
  });

  test('filterIncomes applies tag filter', () {
    final all = [
      _income(id: 1, at: DateTime(2026, 1, 10)),
      _income(id: 2, at: DateTime(2026, 1, 11)),
    ];
    final filtered = filterIncomes(
      all: all,
      query: const ExpenseListQuery(tagIds: {7}),
      incomeTags: {
        1: [7],
        2: [8],
      },
    );
    expect(filtered.map((e) => e.id).toList(), [1]);
  });

  test('filterIncomes matches country without case', () {
    final all = [
      _income(id: 1, at: DateTime(2026, 1, 10), countryCode: 'US'),
      _income(id: 2, at: DateTime(2026, 1, 11), countryCode: 'AT'),
    ];
    final filtered = filterIncomes(
      all: all,
      query: const ExpenseListQuery(countryCodes: {'us'}),
      incomeTags: const {},
    );
    expect(filtered.map((e) => e.id).toList(), [1]);
  });

  test('filterIncomes applies payment method', () {
    final all = [
      _income(id: 1, at: DateTime(2026, 1, 10), paymentMethodId: 2),
      _income(id: 2, at: DateTime(2026, 1, 11), paymentMethodId: 1),
    ];
    final filtered = filterIncomes(
      all: all,
      query: const ExpenseListQuery(paymentMethodIds: {2}),
      incomeTags: const {},
    );
    expect(filtered.map((e) => e.id).toList(), [1]);
  });

  test('filterIncomes date range uses wall-clock day in selected timezone', () {
    // 2026-01-15 02:00 UTC is still Jan 14 in America/Los_Angeles.
    final all = [
      _income(id: 10, at: DateTime.utc(2026, 1, 15, 2)),
      _income(id: 11, at: DateTime.utc(2026, 1, 15, 20)),
    ];
    final onJan15Pacific = filterIncomes(
      all: all,
      query: ExpenseListQuery(
        from: DateTime(2026, 1, 15),
        to: DateTime(2026, 1, 15),
      ),
      incomeTags: const {},
      timeZoneId: 'America/Los_Angeles',
    );
    expect(onJan15Pacific.map((e) => e.id).toList(), [11]);
  });

  test('sortIncomes orders by amount after display-currency conversion', () {
    final all = [
      _income(id: 1, at: DateTime(2026, 1, 1), amount: 1000, currency: 'EUR'),
      _income(id: 2, at: DateTime(2026, 1, 1), amount: 1000, currency: 'USD'),
    ];
    final sorted = sortIncomes(
      list: all,
      query: const ExpenseListQuery(
        sort: ExpenseListSortField.amount,
        ascending: true,
      ),
      displayCurrency: 'USD',
      displayRates: const {'EUR': 2, 'USD': 1},
    );
    expect(sorted.map((e) => e.id).toList(), [2, 1]);
  });
}
