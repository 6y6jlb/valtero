import 'package:valtero/entities/exchange_rate/model/exchange_rate_provider.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_store.dart';
import 'package:valtero/shared/logging/app_logger.dart';
import 'package:valtero/shared/settings/app_settings.dart';

typedef SettingsReader = AppSettings? Function();
typedef SettingsWriter = Future<void> Function(AppSettings settings);

/// Resolves FX rates: keyed API → Frankfurter → manual → null.
class RateResolver {
  final ExchangeRateStore store;
  final ExchangeRateProvider exchangeRateApi;
  final ExchangeRateProvider frankfurter;
  final SettingsReader readSettings;
  final SettingsWriter writeSettings;
  final AppLogger? logger;

  RateResolver({
    required this.store,
    required this.exchangeRateApi,
    required this.frankfurter,
    required this.readSettings,
    required this.writeSettings,
    this.logger,
  });

  Future<double?> getRate(String base, String target) async {
    final from = base.toUpperCase();
    final to = target.toUpperCase();
    if (from == to) return 1.0;

    final settings = readSettings();
    final apiKey = settings?.exchangeRateApiKey;

    if (apiKey != null && apiKey.trim().isNotEmpty) {
      final cached = await store.getRateRow(
        base: from,
        target: to,
        source: exchangeRateApi.id,
      );
      if (cached != null && !_isStale(cached.fetchedAt)) {
        return cached.rate;
      }
      try {
        final rates = await exchangeRateApi.fetchRates(
          base: from,
          targets: [to],
          apiKey: apiKey,
        );
        final rate = rates[to];
        if (rate != null) {
          await store.upsertRate(
            base: from,
            target: to,
            source: exchangeRateApi.id,
            rate: rate,
            fetchedAt: DateTime.now(),
          );
          return rate;
        }
      } catch (e, st) {
        // ignore: unawaited_futures
        logger?.warning(
          'Rate fetch failed via exchangerate_api for $from→$to',
          error: e,
          stackTrace: st,
        );
      }
    }

    final frankCached = await store.getRateRow(
      base: from,
      target: to,
      source: frankfurter.id,
    );
    if (frankCached != null && !_isStale(frankCached.fetchedAt)) {
      return frankCached.rate;
    }
    try {
      final rates = await frankfurter.fetchRates(
        base: from,
        targets: [to],
      );
      final rate = rates[to];
      if (rate != null) {
        await store.upsertRate(
          base: from,
          target: to,
          source: frankfurter.id,
          rate: rate,
          fetchedAt: DateTime.now(),
        );
        return rate;
      }
    } catch (e, st) {
      // ignore: unawaited_futures
      logger?.warning(
        'Rate fetch failed via frankfurter for $from→$to',
        error: e,
        stackTrace: st,
      );
    }

    final manual = await store.getRateRow(
      base: from,
      target: to,
      source: 'manual',
    );
    return manual?.rate;
  }

  Future<void> refreshIfStale({
    bool force = false,
    List<String>? currencies,
  }) async {
    final settings = readSettings();
    if (settings == null) return;

    final last = settings.lastRateRefreshAt;
    final stale = last == null || DateTime.now().difference(last) > const Duration(hours: 24);
    if (!force && !stale) return;

    final codes = currencies ??
        {
          ...settings.reportingCurrencies,
          settings.primaryCurrency,
        }.toList();
    if (codes.isEmpty) return;

    final base = settings.primaryCurrency;
    final targets = codes.where((c) => c != base).toList();
    if (targets.isEmpty) {
      await writeSettings(settings.copyWith(lastRateRefreshAt: DateTime.now()));
      return;
    }

    final apiKey = settings.exchangeRateApiKey;
    var usedProvider = frankfurter;
    String? key;
    if (apiKey != null && apiKey.trim().isNotEmpty) {
      usedProvider = exchangeRateApi;
      key = apiKey;
    }

    try {
      final rates = await usedProvider.fetchRates(
        base: base,
        targets: targets,
        apiKey: key,
      );
      final now = DateTime.now();
      for (final entry in rates.entries) {
        await store.upsertRate(
          base: base,
          target: entry.key,
          source: usedProvider.id,
          rate: entry.value,
          fetchedAt: now,
        );
      }
      await writeSettings(settings.copyWith(lastRateRefreshAt: now));
      // ignore: unawaited_futures
      logger?.debug(
        'Rates refreshed via ${usedProvider.id} base=$base targets=${targets.length}',
      );
    } catch (e, st) {
      // ignore: unawaited_futures
      logger?.error(
        'Rate refresh failed via ${usedProvider.id}',
        error: e,
        stackTrace: st,
      );
      if (usedProvider.id != frankfurter.id) {
        try {
          final rates = await frankfurter.fetchRates(
            base: base,
            targets: targets,
          );
          final now = DateTime.now();
          for (final entry in rates.entries) {
            await store.upsertRate(
              base: base,
              target: entry.key,
              source: frankfurter.id,
              rate: entry.value,
              fetchedAt: now,
            );
          }
          await writeSettings(settings.copyWith(lastRateRefreshAt: now));
          // ignore: unawaited_futures
          logger?.debug('Rates refreshed via frankfurter fallback');
        } catch (e2, st2) {
          // ignore: unawaited_futures
          logger?.error(
            'Rate refresh frankfurter fallback failed',
            error: e2,
            stackTrace: st2,
          );
        }
      }
    }
  }

  Future<void> setManualRate({
    required String base,
    required String target,
    required double rate,
  }) {
    return store.upsertRate(
      base: base.toUpperCase(),
      target: target.toUpperCase(),
      source: 'manual',
      rate: rate,
      fetchedAt: DateTime.now(),
    );
  }

  bool _isStale(DateTime fetchedAt) {
    return DateTime.now().difference(fetchedAt) > const Duration(hours: 24);
  }
}
