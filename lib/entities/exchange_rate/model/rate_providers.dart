import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/data/exchangerate_api_provider.dart';
import 'package:valtero/entities/exchange_rate/data/frankfurter_provider.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_provider.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_store.dart';
import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/logging/logging_providers.dart';
import 'package:valtero/shared/network/dio_provider.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

final exchangeRateApiProvider = Provider<ExchangeRateProvider>((ref) {
  return ExchangeRateApiProvider(ref.watch(dioProvider));
});

final frankfurterProvider = Provider<ExchangeRateProvider>((ref) {
  return FrankfurterProvider(ref.watch(dioProvider));
});

final rateResolverProvider = Provider<RateResolver>((ref) {
  return RateResolver(
    store: DriftExchangeRateStore(ref.watch(appDatabaseProvider)),
    exchangeRateApi: ref.watch(exchangeRateApiProvider),
    frankfurter: ref.watch(frankfurterProvider),
    readSettings: () => ref.read(appSettingsProvider).value,
    writeSettings: (settings) =>
        ref.read(appSettingsProvider.notifier).updateSettings(settings),
    logger: ref.watch(appLoggerProvider),
  );
});
