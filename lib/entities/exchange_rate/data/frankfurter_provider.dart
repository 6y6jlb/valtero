import 'package:dio/dio.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_provider.dart';

/// ECB-based rates via Frankfurter (no API key). Limited currency set.
class FrankfurterProvider implements ExchangeRateProvider {
  final Dio _dio;

  FrankfurterProvider(this._dio);

  @override
  String get id => 'frankfurter';

  @override
  bool get requiresApiKey => false;

  @override
  Future<Map<String, double>> fetchRates({
    required String base,
    required List<String> targets,
    String? apiKey,
  }) async {
    final uniqueTargets = targets
        .map((t) => t.toUpperCase())
        .where((t) => t != base.toUpperCase())
        .toSet()
        .toList();
    if (uniqueTargets.isEmpty) {
      return {base.toUpperCase(): 1.0};
    }
    final response = await _dio.get<Map<String, dynamic>>(
      'https://api.frankfurter.dev/v1/latest',
      queryParameters: {
        'from': base.toUpperCase(),
        'to': uniqueTargets.join(','),
      },
    );
    return _parseRates(response.data);
  }

  @override
  Future<Map<String, double>> fetchAllRates({
    required String base,
    String? apiKey,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://api.frankfurter.dev/v1/latest',
      queryParameters: {
        'from': base.toUpperCase(),
      },
    );
    return _parseRates(response.data);
  }

  Map<String, double> _parseRates(Map<String, dynamic>? data) {
    if (data == null) {
      throw StateError('Frankfurter request failed');
    }
    final rates = data['rates'] as Map<String, dynamic>? ?? {};
    final result = <String, double>{};
    for (final entry in rates.entries) {
      if (entry.value is num) {
        result[entry.key.toUpperCase()] = (entry.value as num).toDouble();
      }
    }
    return result;
  }

  @override
  Future<bool> validateApiKey(String apiKey) async => true;
}
