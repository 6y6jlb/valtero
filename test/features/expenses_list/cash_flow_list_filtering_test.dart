import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:valtero/features/expenses_list/model/cash_flow_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/recent_operation.dart';
import 'package:valtero/shared/database/app_database.dart';

Expense _expense({
  required int id,
  required DateTime at,
  int amount = 100,
  String currency = 'USD',
  int? paymentMethodId,
  String? countryCode,
}) {
  return Expense(
    kind: 'expense',
    id: id,
    syncId: 'sync-$id',
    occurredAt: at,
    originalAmountMinor: amount,
    originalCurrencyCode: currency,
    storedAmountMinor: amount,
    storedCurrencyCode: currency,
    paymentMethodId: paymentMethodId,
    countryCode: countryCode,
    createdAt: at,
    updatedAt: at,
    duplicateDismissed: false,
  );
}

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
    paymentMethodId: paymentMethodId,
    countryCode: countryCode,
    createdAt: at,
    updatedAt: at,
    duplicateDismissed: false,
  );
}

void main() {
  setUpAll(() {
    tzdata.initializeTimeZones();
  });

  group('cashFlowQueryOf', () {
    test('clears tagIds when set', () {
      const query = ExpenseListQuery(tagIds: {7, 8});
      final effective = cashFlowQueryOf(query);
      expect(effective.tagIds, isEmpty);
      expect(identical(effective, query), isFalse);
    });

    test('keeps query unchanged when tagIds empty', () {
      const query = ExpenseListQuery(
        paymentMethodIds: {1},
        countryCodes: {'US'},
        currencyCode: 'EUR',
      );
      final effective = cashFlowQueryOf(query);
      expect(effective.tagIds, isEmpty);
      expect(effective.paymentMethodIds, {1});
      expect(effective.countryCodes, {'US'});
      expect(effective.currencyCode, 'EUR');
    });
  });

  group('cashFlowChartQueryOf', () {
    test('clears tag, payment and country filters', () {
      final query = ExpenseListQuery(
        tagIds: {1},
        paymentMethodIds: {2},
        countryCodes: {'RU'},
        currencyCode: 'USD',
        from: DateTime(2026, 1, 1),
        to: DateTime(2026, 1, 31),
      );
      final chartQuery = cashFlowChartQueryOf(query);
      expect(chartQuery.tagIds, isEmpty);
      expect(chartQuery.paymentMethodIds, isEmpty);
      expect(chartQuery.countryCodes, isEmpty);
      expect(chartQuery.currencyCode, 'USD');
      expect(chartQuery.from, query.from);
      expect(chartQuery.to, query.to);
    });
  });

  group('filterCashFlowOperations', () {
    final expenses = [
      _expense(
        id: 1,
        at: DateTime(2026, 1, 10),
        currency: 'USD',
        paymentMethodId: 1,
        countryCode: 'US',
      ),
      _expense(
        id: 2,
        at: DateTime(2026, 1, 20),
        currency: 'EUR',
        paymentMethodId: 2,
        countryCode: 'AT',
      ),
    ];
    final incomes = [
      _income(
        id: 1,
        at: DateTime(2026, 1, 12),
        amount: 500,
        currency: 'USD',
        paymentMethodId: 1,
        countryCode: 'US',
      ),
      _income(
        id: 2,
        at: DateTime(2026, 1, 25),
        amount: 800,
        currency: 'EUR',
      ),
    ];
    const expenseTags = <int, List<int>>{
      1: [10],
      2: [20],
    };
    const incomeTags = <int, List<int>>{
      1: [30],
      2: [40],
    };

    test('merges both directions sorted by date desc', () {
      final merged = filterCashFlowOperations(
        expenses: expenses,
        incomes: incomes,
        query: const ExpenseListQuery(),
        expenseTags: expenseTags,
        incomeTags: incomeTags,
      );
      expect(merged.map((op) => (op.kind, op.id)), [
        (OperationKind.income, 2),
        (OperationKind.expense, 2),
        (OperationKind.income, 1),
        (OperationKind.expense, 1),
      ]);
    });

    test('ignores tag filter so opposite direction is kept', () {
      final merged = filterCashFlowOperations(
        expenses: expenses,
        incomes: incomes,
        query: const ExpenseListQuery(tagIds: {10}),
        expenseTags: expenseTags,
        incomeTags: incomeTags,
      );
      expect(merged.length, 4);
      expect(merged.any((op) => op.kind == OperationKind.income), isTrue);
      expect(merged.any((op) => op.kind == OperationKind.expense), isTrue);
    });

    test('applies currency and payment filters', () {
      final merged = filterCashFlowOperations(
        expenses: expenses,
        incomes: incomes,
        query: const ExpenseListQuery(
          currencyCode: 'USD',
          paymentMethodIds: {1},
        ),
        expenseTags: expenseTags,
        incomeTags: incomeTags,
      );
      expect(merged.map((op) => (op.kind, op.id)), [
        (OperationKind.income, 1),
        (OperationKind.expense, 1),
      ]);
    });

    test('marks possible duplicates from both sets', () {
      final merged = filterCashFlowOperations(
        expenses: expenses,
        incomes: incomes,
        query: const ExpenseListQuery(),
        expenseTags: expenseTags,
        incomeTags: incomeTags,
        possibleDuplicateExpenseIds: {2},
        possibleDuplicateIncomeIds: {1},
      );
      final expenseDup =
          merged.firstWhere((op) => op.kind == OperationKind.expense && op.id == 2);
      final incomeDup =
          merged.firstWhere((op) => op.kind == OperationKind.income && op.id == 1);
      expect(expenseDup.possibleDuplicate, isTrue);
      expect(incomeDup.possibleDuplicate, isTrue);
    });
  });

  group('sortCashFlowOperations', () {
    final ops = mergeRecentOperations(
      expenses: [
        _expense(id: 1, at: DateTime(2026, 1, 5), amount: 200, currency: 'EUR'),
        _expense(id: 2, at: DateTime(2026, 1, 20), amount: 100, currency: 'USD'),
      ],
      incomes: [
        _income(id: 1, at: DateTime(2026, 1, 10), amount: 500, currency: 'USD'),
      ],
    );

    test('sorts by date descending by default', () {
      final sorted = sortCashFlowOperations(
        list: ops,
        query: const ExpenseListQuery(sort: ExpenseListSortField.date),
      );
      expect(sorted.map((op) => op.id), [2, 1, 1]);
      expect(
        sorted.map((op) => op.kind),
        [
          OperationKind.expense,
          OperationKind.income,
          OperationKind.expense,
        ],
      );
    });

    test('sorts by amount using display rates when provided', () {
      final sorted = sortCashFlowOperations(
        list: ops,
        query: const ExpenseListQuery(sort: ExpenseListSortField.amount),
        displayCurrency: 'USD',
        displayRates: {'EUR': 2.0},
      );
      // EUR 200 * 2 = 400 USD > income 500? No 400 < 500. Order: 500, 400, 100.
      expect(
        sorted.map((op) => (op.kind, op.id, op.amountMinor, op.currencyCode)),
        [
          (OperationKind.income, 1, 500, 'USD'),
          (OperationKind.expense, 1, 200, 'EUR'),
          (OperationKind.expense, 2, 100, 'USD'),
        ],
      );
    });

    test('sorts by currency code ascending when requested', () {
      final sorted = sortCashFlowOperations(
        list: ops,
        query: const ExpenseListQuery(
          sort: ExpenseListSortField.currency,
          ascending: true,
        ),
      );
      expect(
        sorted.map((op) => op.currencyCode),
        ['EUR', 'USD', 'USD'],
      );
    });
  });

  group('cashFlowConvertedMinor', () {
    test('returns null without display currency or rates', () {
      final op = RecentOperation.fromExpense(
        _expense(id: 1, at: DateTime(2026, 1, 1), amount: 100),
      );
      expect(cashFlowConvertedMinor(op), isNull);
      expect(
        cashFlowConvertedMinor(op, displayCurrency: 'USD', displayRates: null),
        isNull,
      );
    });

    test('converts using per-currency rate map', () {
      final op = RecentOperation.fromExpense(
        _expense(id: 1, at: DateTime(2026, 1, 1), amount: 100, currency: 'EUR'),
      );
      expect(
        cashFlowConvertedMinor(
          op,
          displayCurrency: 'USD',
          displayRates: {'EUR': 1.5},
        ),
        150,
      );
    });
  });
}
