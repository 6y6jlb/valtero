import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_provider.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_store.dart';
import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/shared/settings/app_settings.dart';

class _FakeProvider implements ExchangeRateProvider {
  _FakeProvider(this.id, this.rates, {this.requiresApiKey = false});

  @override
  final String id;
  final Map<String, double> rates;

  @override
  final bool requiresApiKey;

  @override
  Future<Map<String, double>> fetchRates({
    required String base,
    required List<String> targets,
    String? apiKey,
  }) async {
    return {
      for (final t in targets)
        if (rates.containsKey(t)) t: rates[t]!,
    };
  }

  @override
  Future<Map<String, double>> fetchAllRates({
    required String base,
    String? apiKey,
  }) async {
    return Map<String, double>.from(rates);
  }

  @override
  Future<bool> validateApiKey(String apiKey) async => true;
}

void main() {
  late InMemoryExchangeRateStore store;
  late AppSettings settings;

  setUp(() {
    store = InMemoryExchangeRateStore();
    settings = AppSettings.initial();
  });

  test('RateResolver prefers manual when providers miss', () async {
    final resolver = RateResolver(
      store: store,
      exchangeRateApi: _FakeProvider('exchangerate_api', {}, requiresApiKey: true),
      frankfurter: _FakeProvider('frankfurter', {}),
      readSettings: () => settings,
      writeSettings: (s) async => settings = s,
    );

    await resolver.setManualRate(base: 'USD', target: 'RUB', rate: 90);
    final rate = await resolver.getRate('USD', 'RUB');
    expect(rate, 90);
  });

  test('RateResolver uses frankfurter when no api key', () async {
    final resolver = RateResolver(
      store: store,
      exchangeRateApi: _FakeProvider('exchangerate_api', {'RUB': 1}, requiresApiKey: true),
      frankfurter: _FakeProvider('frankfurter', {'RUB': 95}),
      readSettings: () => settings,
      writeSettings: (s) async => settings = s,
    );

    final rate = await resolver.getRate('USD', 'RUB');
    expect(rate, 95);
  });

  test('same currency returns 1.0', () async {
    final resolver = RateResolver(
      store: store,
      exchangeRateApi: _FakeProvider('exchangerate_api', {}),
      frankfurter: _FakeProvider('frankfurter', {}),
      readSettings: () => settings,
      writeSettings: (s) async => settings = s,
    );
    expect(await resolver.getRate('EUR', 'EUR'), 1.0);
  });

  test('refreshAllRates stores every pair from active provider', () async {
    final resolver = RateResolver(
      store: store,
      exchangeRateApi: _FakeProvider(
        'exchangerate_api',
        {'EUR': 0.9, 'GBP': 0.8},
        requiresApiKey: true,
      ),
      frankfurter: _FakeProvider('frankfurter', {'EUR': 0.92, 'JPY': 150}),
      readSettings: () => settings,
      writeSettings: (s) async => settings = s,
    );

    final count = await resolver.refreshAllRates(base: 'USD', force: true);
    expect(count, 2);
    expect(await store.getRateRow(base: 'USD', target: 'EUR', source: 'frankfurter'),
        isNotNull);
    expect(await store.getRateRow(base: 'USD', target: 'JPY', source: 'frankfurter'),
        isNotNull);
  });

  test('forceRefreshRate skips cache and writes new value', () async {
    await store.upsertRate(
      base: 'USD',
      target: 'RUB',
      source: 'frankfurter',
      rate: 10,
      fetchedAt: DateTime.now(),
    );
    final resolver = RateResolver(
      store: store,
      exchangeRateApi: _FakeProvider('exchangerate_api', {}, requiresApiKey: true),
      frankfurter: _FakeProvider('frankfurter', {'RUB': 99}),
      readSettings: () => settings,
      writeSettings: (s) async => settings = s,
    );

    final rate = await resolver.forceRefreshRate('USD', 'RUB', force: true);
    expect(rate, 99);
    final row =
        await store.getRateRow(base: 'USD', target: 'RUB', source: 'frankfurter');
    expect(row?.rate, 99);
  });

  test('refreshAllRates respects network cooldown', () async {
    settings = settings.copyWith(lastRateRefreshAt: DateTime.now());
    final resolver = RateResolver(
      store: store,
      exchangeRateApi: _FakeProvider('exchangerate_api', {}, requiresApiKey: true),
      frankfurter: _FakeProvider('frankfurter', {'EUR': 1}),
      readSettings: () => settings,
      writeSettings: (s) async => settings = s,
    );

    expect(resolver.rateFetchCooldownRemaining(), isNotNull);
    expect(
      () => resolver.refreshAllRates(base: 'USD'),
      throwsA(isA<RatesCooldownException>()),
    );
  });
}
