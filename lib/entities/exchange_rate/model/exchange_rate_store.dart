import 'package:valtero/shared/database/app_database.dart';

/// Persistence surface used by [RateResolver] (real DB or in-memory fake).
abstract class ExchangeRateStore {
  Future<ExchangeRate?> getRateRow({
    required String base,
    required String target,
    required String source,
  });

  Future<void> upsertRate({
    required String base,
    required String target,
    required String source,
    required double rate,
    required DateTime fetchedAt,
  });
}

class DriftExchangeRateStore implements ExchangeRateStore {
  DriftExchangeRateStore(this.db);

  final AppDatabase db;

  @override
  Future<ExchangeRate?> getRateRow({
    required String base,
    required String target,
    required String source,
  }) {
    return db.getRateRow(base: base, target: target, source: source);
  }

  @override
  Future<void> upsertRate({
    required String base,
    required String target,
    required String source,
    required double rate,
    required DateTime fetchedAt,
  }) {
    return db.upsertRate(
      base: base,
      target: target,
      source: source,
      rate: rate,
      fetchedAt: fetchedAt,
    );
  }
}

class InMemoryExchangeRateStore implements ExchangeRateStore {
  final Map<String, ({double rate, DateTime fetchedAt})> _rows = {};

  String _key(String base, String target, String source) =>
      '${base.toUpperCase()}|${target.toUpperCase()}|$source';

  @override
  Future<ExchangeRate?> getRateRow({
    required String base,
    required String target,
    required String source,
  }) async {
    final row = _rows[_key(base, target, source)];
    if (row == null) return null;
    return ExchangeRate(
      id: 0,
      baseCurrencyCode: base.toUpperCase(),
      targetCurrencyCode: target.toUpperCase(),
      source: source,
      rate: row.rate,
      fetchedAt: row.fetchedAt,
    );
  }

  @override
  Future<void> upsertRate({
    required String base,
    required String target,
    required String source,
    required double rate,
    required DateTime fetchedAt,
  }) async {
    _rows[_key(base, target, source)] = (rate: rate, fetchedAt: fetchedAt);
  }
}
