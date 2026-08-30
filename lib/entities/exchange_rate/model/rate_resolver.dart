import 'package:valtero/entities/exchange_rate/model/exchange_rate_provider.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_store.dart';
import 'package:valtero/shared/logging/app_logger.dart';
import 'package:valtero/shared/settings/app_settings.dart';

typedef SettingsReader = AppSettings? Function();
typedef SettingsWriter = Future<void> Function(AppSettings settings);

/// Minimum gap between network rate fetches (fetch-all / force pair).
/// Keeps ExchangeRate-API free tier (~1500/mo) safe at ≤1 request/hour.
const Duration kRateNetworkFetchCooldown = Duration(hours: 1);

/// Thrown when a network rate fetch is blocked by [kRateNetworkFetchCooldown].
class RatesCooldownException implements Exception {
  final Duration remaining;
  const RatesCooldownException(this.remaining);

  @override
  String toString() => 'RatesCooldownException($remaining)';
}

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

    final used = _selectProvider(settings);
    try {
      final rates = await used.provider.fetchRates(
        base: base,
        targets: targets,
        apiKey: used.apiKey,
      );
      await _storeRates(
        base: base,
        rates: rates,
        source: used.provider.id,
      );
      // ignore: unawaited_futures
      logger?.debug(
        'Rates refreshed via ${used.provider.id} base=$base targets=${targets.length}',
      );
    } catch (e, st) {
      // ignore: unawaited_futures
      logger?.error(
        'Rate refresh failed via ${used.provider.id}',
        error: e,
        stackTrace: st,
      );
      if (used.provider.id != frankfurter.id) {
        try {
          final rates = await frankfurter.fetchRates(
            base: base,
            targets: targets,
          );
          await _storeRates(
            base: base,
            rates: rates,
            source: frankfurter.id,
          );
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

  /// Time left until the next network fetch is allowed, or `null` if ready.
  Duration? rateFetchCooldownRemaining() {
    final settings = readSettings();
    final last = settings?.lastRateRefreshAt;
    if (last == null) return null;
    final elapsed = DateTime.now().difference(last);
    if (elapsed >= kRateNetworkFetchCooldown) return null;
    return kRateNetworkFetchCooldown - elapsed;
  }

  void _ensureNetworkFetchAllowed() {
    final remaining = rateFetchCooldownRemaining();
    if (remaining != null) {
      throw RatesCooldownException(remaining);
    }
  }

  /// Fetches every rate the active provider offers for [base] into Drift cache.
  ///
  /// Respects [kRateNetworkFetchCooldown] unless [force] is true (tests / debug).
  Future<int> refreshAllRates({String? base, bool force = false}) async {
    final settings = readSettings();
    if (settings == null) return 0;
    if (!force) _ensureNetworkFetchAllowed();
    final from = (base ?? settings.primaryCurrency).toUpperCase();
    final used = _selectProvider(settings);
    try {
      final rates = await used.provider.fetchAllRates(
        base: from,
        apiKey: used.apiKey,
      );
      await _storeRates(
        base: from,
        rates: rates,
        source: used.provider.id,
      );
      // ignore: unawaited_futures
      logger?.debug(
        'Fetched all rates via ${used.provider.id} base=$from count=${rates.length}',
      );
      return rates.length;
    } catch (e, st) {
      if (e is RatesCooldownException) rethrow;
      // ignore: unawaited_futures
      logger?.error(
        'Fetch-all rates failed via ${used.provider.id}',
        error: e,
        stackTrace: st,
      );
      if (used.provider.id != frankfurter.id) {
        final rates = await frankfurter.fetchAllRates(base: from);
        await _storeRates(
          base: from,
          rates: rates,
          source: frankfurter.id,
        );
        return rates.length;
      }
      rethrow;
    }
  }

  /// Force-refreshes one pair from the network (skips per-row cache staleness).
  /// Still respects [kRateNetworkFetchCooldown] (one latest call ≈ full quota unit).
  Future<double?> forceRefreshRate(
    String base,
    String target, {
    bool force = false,
  }) async {
    final from = base.toUpperCase();
    final to = target.toUpperCase();
    if (from == to) return 1.0;
    final settings = readSettings();
    if (settings == null) return null;
    if (!force) _ensureNetworkFetchAllowed();
    final used = _selectProvider(settings);
    try {
      final rates = await used.provider.fetchRates(
        base: from,
        targets: [to],
        apiKey: used.apiKey,
      );
      final rate = rates[to];
      if (rate == null) return null;
      final now = DateTime.now();
      await store.upsertRate(
        base: from,
        target: to,
        source: used.provider.id,
        rate: rate,
        fetchedAt: now,
      );
      await writeSettings(settings.copyWith(lastRateRefreshAt: now));
      return rate;
    } catch (e, st) {
      if (e is RatesCooldownException) rethrow;
      // ignore: unawaited_futures
      logger?.warning(
        'Force refresh failed via ${used.provider.id} for $from→$to',
        error: e,
        stackTrace: st,
      );
      if (used.provider.id != frankfurter.id) {
        try {
          final rates = await frankfurter.fetchRates(
            base: from,
            targets: [to],
          );
          final rate = rates[to];
          if (rate == null) return null;
          final now = DateTime.now();
          await store.upsertRate(
            base: from,
            target: to,
            source: frankfurter.id,
            rate: rate,
            fetchedAt: now,
          );
          await writeSettings(settings.copyWith(lastRateRefreshAt: now));
          return rate;
        } catch (_) {
          return null;
        }
      }
      return null;
    }
  }

  /// Active provider id for UI labels (`exchangerate_api` or `frankfurter`).
  String activeProviderId() {
    final settings = readSettings();
    if (settings == null) return frankfurter.id;
    return _selectProvider(settings).provider.id;
  }

  ({ExchangeRateProvider provider, String? apiKey}) _selectProvider(
    AppSettings settings,
  ) {
    final apiKey = settings.exchangeRateApiKey;
    if (apiKey != null && apiKey.trim().isNotEmpty) {
      return (provider: exchangeRateApi, apiKey: apiKey);
    }
    return (provider: frankfurter, apiKey: null);
  }

  Future<void> _storeRates({
    required String base,
    required Map<String, double> rates,
    required String source,
  }) async {
    final now = DateTime.now();
    for (final entry in rates.entries) {
      if (entry.key.toUpperCase() == base.toUpperCase()) continue;
      await store.upsertRate(
        base: base.toUpperCase(),
        target: entry.key.toUpperCase(),
        source: source,
        rate: entry.value,
        fetchedAt: now,
      );
    }
    final settings = readSettings();
    if (settings != null) {
      await writeSettings(settings.copyWith(lastRateRefreshAt: now));
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
