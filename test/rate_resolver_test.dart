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
}
