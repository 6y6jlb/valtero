/// Pluggable FX rate source (ExchangeRate-API, Frankfurter, ...).
abstract class ExchangeRateProvider {
  String get id;

  bool get requiresApiKey;

  /// Returns map of target currency code → rate (units of target per 1 base).
  Future<Map<String, double>> fetchRates({
    required String base,
    required List<String> targets,
    String? apiKey,
  });

  /// Returns every rate the provider offers for [base] (no target filter).
  Future<Map<String, double>> fetchAllRates({
    required String base,
    String? apiKey,
  });

  /// Returns true if the key works for a simple probe request.
  Future<bool> validateApiKey(String apiKey);
}
