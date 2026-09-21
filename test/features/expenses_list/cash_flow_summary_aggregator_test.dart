import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_provider.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_store.dart';
import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_summary_aggregator.dart';
import 'package:valtero/features/expenses_list/model/recent_operation.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/settings/app_settings.dart';

Expense _expense({
  required int id,
  required int amountMinor,
  String currency = 'USD',
  DateTime? occurredAt,
}) {
  final at = occurredAt ?? DateTime(2026, 1, 15);
  return Expense(
    kind: 'expense',
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

Income _income({
  required int id,
  required int amountMinor,
  String currency = 'USD',
  DateTime? occurredAt,
}) {
  final at = occurredAt ?? DateTime(2026, 1, 15);
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

class _FakeProvider implements ExchangeRateProvider {
  @override
  String get id => 'fake';

  @override
  bool get requiresApiKey => false;

  @override
  Future<Map<String, double>> fetchRates({
    required String base,
    required List<String> targets,
    String? apiKey,
  }) async =>
      {};

  @override
  Future<Map<String, double>> fetchAllRates({
    required String base,
    String? apiKey,
  }) async =>
      {};

  @override
  Future<bool> validateApiKey(String apiKey) async => true;
}

void main() {
  group('aggregateCashFlowByCurrency', () {
    test('returns empty for no operations', () {
      expect(aggregateCashFlowByCurrency([]), isEmpty);
    });

    test('groups income, expense, count and net per currency', () {
      final ops = mergeRecentOperations(
        expenses: [
          _expense(id: 1, amountMinor: 1000, currency: 'usd'),
          _expense(id: 2, amountMinor: 500, currency: 'EUR'),
        ],
        incomes: [
          _income(id: 1, amountMinor: 3000, currency: 'USD'),
          _income(id: 2, amountMinor: 200, currency: 'EUR'),
        ],
      );

      final rows = aggregateCashFlowByCurrency(ops);
      expect(rows.length, 2);

      final usd = rows.firstWhere((r) => r.currency == 'USD');
      expect(usd.count, 2);
      expect(usd.incomeMinor, 3000);
      expect(usd.expenseMinor, 1000);
      expect(usd.netMinor, 2000);
      expect(usd.grossMinor, 4000);

      final eur = rows.firstWhere((r) => r.currency == 'EUR');
      expect(eur.count, 2);
      expect(eur.incomeMinor, 200);
      expect(eur.expenseMinor, 500);
      expect(eur.netMinor, -300);
    });

    test('sorts by gross activity desc then currency code', () {
      final ops = mergeRecentOperations(
        expenses: [
          _expense(id: 1, amountMinor: 100, currency: 'USD'),
          _expense(id: 2, amountMinor: 900, currency: 'EUR'),
        ],
        incomes: [
          _income(id: 1, amountMinor: 50, currency: 'USD'),
        ],
      );

      final rows = aggregateCashFlowByCurrency(ops);
      expect(rows.map((r) => r.currency), ['EUR', 'USD']);
    });
  });

  group('cashFlowSnapshotKey', () {
    test('includes kind prefix and sorts tokens', () {
      final ops = mergeRecentOperations(
        expenses: [_expense(id: 2, amountMinor: 100)],
        incomes: [_income(id: 1, amountMinor: 200)],
      );
      expect(cashFlowSnapshotKey(ops), 'e2,i1');
    });

    test('changes when operation ids change', () {
      final a = mergeRecentOperations(
        expenses: [_expense(id: 1, amountMinor: 100)],
        incomes: const [],
      );
      final b = mergeRecentOperations(
        expenses: [_expense(id: 2, amountMinor: 100)],
        incomes: const [],
      );
      expect(cashFlowSnapshotKey(a), isNot(cashFlowSnapshotKey(b)));
    });
  });

  group('sumCashFlowInCurrency', () {
    late RateResolver resolver;

    setUp(() {
      var settings = AppSettings.initial();
      resolver = RateResolver(
        store: InMemoryExchangeRateStore(),
        exchangeRateApi: _FakeProvider(),
        frankfurter: _FakeProvider(),
        readSettings: () => settings,
        writeSettings: (s) async => settings = s,
      );
    });

    test('converts mixed currencies into target totals', () async {
      await resolver.setManualRate(base: 'EUR', target: 'USD', rate: 2);

      final ops = mergeRecentOperations(
        expenses: [
          _expense(id: 1, amountMinor: 1000, currency: 'USD'),
          _expense(id: 2, amountMinor: 500, currency: 'EUR'),
        ],
        incomes: [
          _income(id: 1, amountMinor: 3000, currency: 'USD'),
        ],
      );

      final totals = await sumCashFlowInCurrency(
        operations: ops,
        targetCurrency: 'USD',
        resolver: resolver,
      );

      expect(totals.convertibleCount, 3);
      expect(totals.incomeMinor, 3000);
      expect(totals.expenseMinor, 2000);
      expect(totals.netMinor, 1000);
    });

    test('skips operations without a rate', () async {
      final ops = mergeRecentOperations(
        expenses: [_expense(id: 1, amountMinor: 100, currency: 'JPY')],
        incomes: [_income(id: 1, amountMinor: 200, currency: 'USD')],
      );

      final totals = await sumCashFlowInCurrency(
        operations: ops,
        targetCurrency: 'USD',
        resolver: resolver,
      );

      expect(totals.convertibleCount, 1);
      expect(totals.incomeMinor, 200);
      expect(totals.expenseMinor, 0);
    });
  });
}
