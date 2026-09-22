import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/features/expenses_list/model/income_summary_aggregator.dart';
import 'package:valtero/shared/database/app_database.dart';

Income _income({
  required int id,
  required String currency,
  required int amountMinor,
}) {
  final at = DateTime(2026, 1, 15);
  return Income(
    kind: 'income',
    id: id,
    syncId: 'sync-$id',
    occurredAt: at,
    originalAmountMinor: amountMinor,
    originalCurrencyCode: currency,
    storedAmountMinor: amountMinor,
    storedCurrencyCode: currency,
    createdAt: at,
    updatedAt: at,
    duplicateDismissed: false,
  );
}

void main() {
  group('aggregateIncomesByCurrency', () {
    test('returns empty for no incomes', () {
      expect(aggregateIncomesByCurrency([]), isEmpty);
    });

    test('groups count and sum per currency sorted by total desc', () {
      final result = aggregateIncomesByCurrency([
        _income(id: 1, currency: 'USD', amountMinor: 1000),
        _income(id: 2, currency: 'EUR', amountMinor: 5000),
        _income(id: 3, currency: 'USD', amountMinor: 2000),
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

  group('incomesSnapshotKey', () {
    test('changes when income amount changes', () {
      final a = [_income(id: 1, currency: 'USD', amountMinor: 100)];
      final b = [_income(id: 1, currency: 'USD', amountMinor: 200)];
      expect(incomesSnapshotKey(a), isNot(incomesSnapshotKey(b)));
    });
  });
}
