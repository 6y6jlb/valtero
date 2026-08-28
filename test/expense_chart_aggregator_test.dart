import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_provider.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_store.dart';
import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_aggregator.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/settings/app_settings.dart';

class _FakeProvider implements ExchangeRateProvider {
  _FakeProvider(this.rates);

  final Map<String, double> rates;

  @override
  String get id => 'fake';

  @override
  bool get requiresApiKey => false;

  @override
  Future<Map<String, double>> fetchRates({
    required String base,
    required List<String> targets,
    String? apiKey,
  }) async => rates;

  @override
  Future<bool> validateApiKey(String apiKey) async => true;
}

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
  late RateResolver resolver;

  setUp(() {
    var settings = AppSettings.initial();
    resolver = RateResolver(
      store: InMemoryExchangeRateStore(),
      exchangeRateApi: _FakeProvider({}),
      frankfurter: _FakeProvider({}),
      readSettings: () => settings,
      writeSettings: (s) async => settings = s,
    );
  });

  test('includes expense without rate using native amount', () async {
    final result = await aggregateExpensesForChart(
      expenses: [
        _expense(id: 1, currency: 'USD', amountMinor: 1000),
        _expense(id: 2, currency: 'EUR', amountMinor: 2000),
      ],
      primaryCurrency: 'USD',
      resolver: resolver,
      breakdown: ExpenseChartBreakdown.currency,
      expenseTags: const {},
      tagLabels: const {},
      tagById: const {},
      untaggedLabel: '—',
    );

    expect(result.missingRateCount, 1);
    expect(result.slices.length, 2);
    final eur = result.slices.firstWhere((s) => s.key == 'EUR');
    expect(eur.amountMinor, 2000);
    expect(eur.currencyCode, 'EUR');
  });

  test('missingRateCount is zero when all rates exist', () async {
    await resolver.setManualRate(base: 'EUR', target: 'USD', rate: 1.1);
    final result = await aggregateExpensesForChart(
      expenses: [_expense(id: 1, currency: 'EUR', amountMinor: 1000)],
      primaryCurrency: 'USD',
      resolver: resolver,
      breakdown: ExpenseChartBreakdown.month,
      expenseTags: const {},
      tagLabels: const {},
      tagById: const {},
      untaggedLabel: '—',
    );
    expect(result.missingRateCount, 0);
    expect(result.slices, isNotEmpty);
  });
}
