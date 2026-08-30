import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:valtero/features/expenses_list/model/expense_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/shared/database/app_database.dart';

Expense _expense({
  required int id,
  String currency = 'USD',
  int? paymentMethodId,
  String? countryCode,
  DateTime? occurredAt,
}) {
  final at = occurredAt ?? DateTime(2026, 1, 15);
  return Expense(
    id: id,
    occurredAt: at,
    originalAmountMinor: 1000,
    originalCurrencyCode: currency,
    storedAmountMinor: 1000,
    storedCurrencyCode: currency,
    paymentMethodId: paymentMethodId,
    countryCode: countryCode,
    createdAt: at,
    duplicateDismissed: false,
  );
}

void main() {
  setUpAll(() {
    tzdata.initializeTimeZones();
  });

  group('filterExpenses', () {
    final all = [
      _expense(id: 1, currency: 'USD', paymentMethodId: 1, countryCode: 'US'),
      _expense(id: 2, currency: 'EUR', paymentMethodId: 2, countryCode: 'AT'),
      _expense(id: 3, currency: 'USD', countryCode: 'RU'),
    ];
    final tags = <int, List<int>>{
      1: [10],
      2: [20],
      3: [10, 20],
    };

    test('filters by countryCodes', () {
      final result = filterExpenses(
        all: all,
        query: const ExpenseListQuery(countryCodes: {'RU'}),
        expenseTags: tags,
      );
      expect(result.map((e) => e.id), [3]);
    });

    test('filters by paymentMethodIds', () {
      final result = filterExpenses(
        all: all,
        query: const ExpenseListQuery(paymentMethodIds: {2}),
        expenseTags: tags,
      );
      expect(result.map((e) => e.id), [2]);
    });

    test('filters by tagIds (any match)', () {
      final result = filterExpenses(
        all: all,
        query: const ExpenseListQuery(tagIds: {10}),
        expenseTags: tags,
      );
      expect(result.map((e) => e.id), [1, 3]);
    });

    test('country filter is case-insensitive', () {
      final result = filterExpenses(
        all: all,
        query: const ExpenseListQuery(countryCodes: {'us'}),
        expenseTags: tags,
      );
      expect(result.map((e) => e.id), [1]);
    });

    test('date range uses wall-clock day in selected timezone', () {
      // 2026-01-15 02:00 UTC is still Jan 14 in America/Los_Angeles.
      final expenses = [
        _expense(id: 10, occurredAt: DateTime.utc(2026, 1, 15, 2)),
        _expense(id: 11, occurredAt: DateTime.utc(2026, 1, 15, 20)),
      ];
      final onJan15Utc = filterExpenses(
        all: expenses,
        query: ExpenseListQuery(
          from: DateTime(2026, 1, 15),
          to: DateTime(2026, 1, 15),
        ),
        expenseTags: const {},
        timeZoneId: 'UTC',
      );
      expect(onJan15Utc.map((e) => e.id), [10, 11]);

      final onJan15Pacific = filterExpenses(
        all: expenses,
        query: ExpenseListQuery(
          from: DateTime(2026, 1, 15),
          to: DateTime(2026, 1, 15),
        ),
        expenseTags: const {},
        timeZoneId: 'America/Los_Angeles',
      );
      // Only 20:00 UTC (= noon Pacific) falls on Jan 15 Pacific.
      expect(onJan15Pacific.map((e) => e.id), [11]);
    });
  });
}
