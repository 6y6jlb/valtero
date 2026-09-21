import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/grouping/cash_flow_grouper.dart';
import 'package:valtero/features/expenses_list/model/grouping/cash_flow_grouper_for.dart';
import 'package:valtero/features/expenses_list/model/recent_operation.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/app_timezone.dart';

Expense _expense({
  required int id,
  required int amountMinor,
  String currency = 'USD',
  DateTime? occurredAt,
  int? paymentMethodId,
  String? countryCode,
}) {
  final at = occurredAt ?? DateTime.utc(2026, 1, 15, 12);
  return Expense(
    kind: 'expense',
    id: id,
    syncId: 'sync-$id',
    occurredAt: at,
    originalAmountMinor: amountMinor,
    originalCurrencyCode: currency,
    storedAmountMinor: amountMinor,
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
  required int amountMinor,
  String currency = 'USD',
  DateTime? occurredAt,
  int? paymentMethodId,
  String? countryCode,
}) {
  final at = occurredAt ?? DateTime.utc(2026, 1, 15, 12);
  return Income(
    kind: 'income',
    id: id,
    syncId: 'sync-$id',
    occurredAt: at,
    originalAmountMinor: amountMinor,
    originalCurrencyCode: currency,
    storedAmountMinor: amountMinor,
    storedCurrencyCode: currency,
    paymentMethodId: paymentMethodId,
    countryCode: countryCode,
    createdAt: at,
    updatedAt: at,
    duplicateDismissed: false,
  );
}

const _context = CashFlowGroupingContext(
  paymentMethodLabels: {1: 'Card', 2: 'Cash'},
  unspecifiedCountryLabel: 'Unknown country',
  unspecifiedPaymentLabel: 'Unspecified payment',
  ascending: false,
  timeZoneId: 'UTC',
);

void main() {
  setUpAll(() {
    tzdata.initializeTimeZones();
  });

  group('cashFlowGrouperFor currency', () {
    test('buckets income and expense per currency without mixing', () {
      final ops = mergeRecentOperations(
        expenses: [
          _expense(id: 1, amountMinor: 1000, currency: 'USD'),
          _expense(id: 2, amountMinor: 400, currency: 'EUR'),
        ],
        incomes: [
          _income(id: 1, amountMinor: 2500, currency: 'USD'),
        ],
      );

      final rows = cashFlowGrouperFor(ExpenseListGroup.currency).aggregate(
        ops,
        _context,
      );

      expect(rows.length, 2);
      final usd = rows.firstWhere((r) => r.groupLabel == 'USD');
      expect(usd.currencyCode, 'USD');
      expect(usd.count, 2);
      expect(usd.incomeMinor, 2500);
      expect(usd.expenseMinor, 1000);
      expect(usd.netMinor, 1500);

      final eur = rows.firstWhere((r) => r.groupLabel == 'EUR');
      expect(eur.count, 1);
      expect(eur.incomeMinor, 0);
      expect(eur.expenseMinor, 400);
    });
  });

  group('cashFlowGrouperFor date', () {
    test('groups by calendar day in the selected timezone', () {
      final ops = mergeRecentOperations(
        expenses: [
          _expense(
            id: 1,
            amountMinor: 100,
            occurredAt: DateTime.utc(2026, 1, 15, 8),
          ),
          _expense(
            id: 2,
            amountMinor: 200,
            occurredAt: DateTime.utc(2026, 1, 16, 8),
          ),
        ],
        incomes: [
          _income(
            id: 1,
            amountMinor: 300,
            occurredAt: DateTime.utc(2026, 1, 15, 20),
          ),
        ],
      );

      final rows = cashFlowGrouperFor(ExpenseListGroup.date).aggregate(
        ops,
        _context,
      );

      expect(rows.length, 2);
      final jan15 = rows.firstWhere(
        (r) => r.groupLabel == calendarDayKey(DateTime.utc(2026, 1, 15), 'UTC'),
      );
      expect(jan15.count, 2);
      expect(jan15.incomeMinor, 300);
      expect(jan15.expenseMinor, 100);

      final jan16 = rows.firstWhere(
        (r) => r.groupLabel == calendarDayKey(DateTime.utc(2026, 1, 16), 'UTC'),
      );
      expect(jan16.count, 1);
      expect(jan16.expenseMinor, 200);
    });

    test('sorts date groups descending when ascending is false', () {
      final ops = mergeRecentOperations(
        expenses: [
          _expense(
            id: 1,
            amountMinor: 100,
            occurredAt: DateTime.utc(2026, 1, 10),
          ),
          _expense(
            id: 2,
            amountMinor: 100,
            occurredAt: DateTime.utc(2026, 1, 20),
          ),
        ],
        incomes: const [],
      );

      final rows = cashFlowGrouperFor(ExpenseListGroup.date).aggregate(
        ops,
        _context,
      );

      expect(rows.map((r) => r.groupLabel), ['2026-01-20', '2026-01-10']);
    });
  });

  group('cashFlowGrouperFor payment', () {
    test('uses payment labels and unspecified fallback', () {
      final ops = mergeRecentOperations(
        expenses: [
          _expense(id: 1, amountMinor: 500, paymentMethodId: 1),
          _expense(id: 2, amountMinor: 300),
        ],
        incomes: [
          _income(id: 1, amountMinor: 1000, paymentMethodId: 2),
        ],
      );

      final rows = cashFlowGrouperFor(ExpenseListGroup.payment).aggregate(
        ops,
        _context,
      );

      expect(rows.length, 3);
      final card = rows.firstWhere((r) => r.groupLabel == 'Card');
      expect(card.expenseMinor, 500);
      final cash = rows.firstWhere((r) => r.groupLabel == 'Cash');
      expect(cash.incomeMinor, 1000);
      final unspecified = rows.firstWhere(
        (r) => r.groupLabel == _context.unspecifiedPaymentLabel,
      );
      expect(unspecified.expenseMinor, 300);
    });
  });

  group('cashFlowGrouperFor country', () {
    test('uses country display names and unspecified fallback', () {
      final ops = mergeRecentOperations(
        expenses: [
          _expense(id: 1, amountMinor: 400, countryCode: 'US'),
          _expense(id: 2, amountMinor: 100),
        ],
        incomes: [
          _income(id: 1, amountMinor: 900, countryCode: 'AT'),
        ],
      );

      final rows = cashFlowGrouperFor(ExpenseListGroup.country).aggregate(
        ops,
        _context,
      );

      expect(rows.length, 3);
      final us = rows.firstWhere(
        (r) => r.groupLabel == countryDisplayName('US'),
      );
      expect(us.expenseMinor, 400);
      final at = rows.firstWhere(
        (r) => r.groupLabel == countryDisplayName('AT'),
      );
      expect(at.incomeMinor, 900);
      final unknown = rows.firstWhere(
        (r) => r.groupLabel == _context.unspecifiedCountryLabel,
      );
      expect(unknown.expenseMinor, 100);
    });
  });
}
