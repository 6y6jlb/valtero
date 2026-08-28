import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/features/expenses_list/model/expense_summary_aggregator.dart';
import 'package:valtero/shared/database/app_database.dart';

Expense _expense({
  required int id,
  required String currency,
  required int amountMinor,
}) {
  final at = DateTime(2026, 1, 15);
  return Expense(
    id: id,
    occurredAt: at,
    originalAmountMinor: amountMinor,
    originalCurrencyCode: currency,
    storedAmountMinor: amountMinor,
    storedCurrencyCode: currency,
    createdAt: at,
  );
}

void main() {
  group('aggregateExpensesByCurrency', () {
    test('returns empty for no expenses', () {
      expect(aggregateExpensesByCurrency([]), isEmpty);
    });

    test('groups count and sum per currency sorted by total desc', () {
      final result = aggregateExpensesByCurrency([
        _expense(id: 1, currency: 'USD', amountMinor: 1000),
        _expense(id: 2, currency: 'EUR', amountMinor: 5000),
        _expense(id: 3, currency: 'USD', amountMinor: 2000),
      ]);
      expect(result.length, 2);
      expect(result[0].currency, 'EUR');
      expect(result[0].count, 1);
      expect(result[0].totalMinor, 5000);
      expect(result[1].currency, 'USD');
      expect(result[1].count, 2);
      expect(result[1].totalMinor, 3000);
    });
  });

  group('expensesSnapshotKey', () {
    test('changes when expense data changes', () {
      final a = [_expense(id: 1, currency: 'USD', amountMinor: 100)];
      final b = [_expense(id: 1, currency: 'USD', amountMinor: 200)];
      expect(expensesSnapshotKey(a), isNot(expensesSnapshotKey(b)));
    });
  });
}
