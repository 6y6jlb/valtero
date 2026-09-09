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
    id: id,
    occurredAt: at,
    originalAmountMinor: amount,
    originalCurrencyCode: currency,
    storedAmountMinor: amount,
    storedCurrencyCode: currency,
    createdAt: at,
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
}
