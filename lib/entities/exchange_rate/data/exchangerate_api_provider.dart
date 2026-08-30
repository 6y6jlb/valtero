import 'dart:io';

import 'package:dio/dio.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_provider.dart';

class ExchangeRateApiProvider implements ExchangeRateProvider {
  final Dio _dio;

  ExchangeRateApiProvider(this._dio);

  @override
  String get id => 'exchangerate_api';

  @override
  bool get requiresApiKey => true;

  @override
  Future<Map<String, double>> fetchRates({
    required String base,
    required List<String> targets,
    String? apiKey,
  }) async {
    final all = await fetchAllRates(base: base, apiKey: apiKey);
    final result = <String, double>{};
    for (final target in targets) {
      final value = all[target.toUpperCase()];
      if (value != null) {
        result[target.toUpperCase()] = value;
      }
    }
    return result;
  }

  @override
  Future<Map<String, double>> fetchAllRates({
    required String base,
    String? apiKey,
  }) async {
    final key = apiKey?.trim() ?? '';
    if (key.isEmpty) {
      throw StateError('ExchangeRate-API key is required');
    }
    final response = await _dio.get<Map<String, dynamic>>(
      'https://v6.exchangerate-api.com/v6/$key/latest/${base.toUpperCase()}',
    );
    final data = response.data;
    if (data == null || data['result'] != 'success') {
      throw StateError('ExchangeRate-API request failed');
    }
    final conversion = data['conversion_rates'] as Map<String, dynamic>? ?? {};
    final result = <String, double>{};
    for (final entry in conversion.entries) {
      if (entry.value is num) {
        result[entry.key.toUpperCase()] = (entry.value as num).toDouble();
      }
    }
    return result;
  }

  @override
  Future<bool> validateApiKey(String apiKey) async {
    final key = apiKey.trim();
    if (key.isEmpty) return false;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://v6.exchangerate-api.com/v6/$key/latest/USD',
      );
      return response.data?['result'] == 'success';
    } on DioException catch (e) {
      // Let callers distinguish DNS/offline from a rejected key.
      if (_isNetworkFailure(e)) rethrow;
      return false;
    }
  }

  static bool _isNetworkFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      default:
        return e.error is SocketException;
    }
  }
}
