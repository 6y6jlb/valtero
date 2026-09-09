import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:valtero/entities/exchange_rate/model/exchange_rate_provider.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_store.dart';
import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_aggregator.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/settings/app_settings.dart';

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

Expense _expense(int id, DateTime at, int amount, String currency) {
  return Expense(
    id: id,
    occurredAt: at,
    originalAmountMinor: amount,
    originalCurrencyCode: currency,
    storedAmountMinor: amount,
    storedCurrencyCode: currency,
    createdAt: at,
    duplicateDismissed: false,
  );
}

Income _income(int id, DateTime at, int amount, String currency) {
  return Income(
    id: id,
    occurredAt: at,
    originalAmountMinor: amount,
    originalCurrencyCode: currency,
    storedAmountMinor: amount,
    storedCurrencyCode: currency,
    createdAt: at,
    duplicateDismissed: false,
  );
}

void main() {
  late RateResolver resolver;

  setUpAll(() {
    tzdata.initializeTimeZones();
  });

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

  test('aggregateCashFlow buckets income and expense by month', () async {
    final result = await aggregateCashFlow(
      expenses: [
        _expense(1, DateTime(2026, 1, 5), 1000, 'USD'),
        _expense(2, DateTime(2026, 2, 5), 500, 'USD'),
      ],
      incomes: [
        _income(1, DateTime(2026, 1, 10), 3000, 'USD'),
      ],
      primaryCurrency: 'USD',
      resolver: resolver,
      breakdown: ExpenseChartBreakdown.month,
    );
    expect(result.missingRateCount, 0);
    expect(result.buckets.length, 2);
    final jan = result.buckets.firstWhere((b) => b.key == '2026-01');
    expect(jan.incomeTotalMinor, 3000);
    expect(jan.expenseTotalMinor, 1000);
    expect(jan.netMinor, 2000);
  });
}
