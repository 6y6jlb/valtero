import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/network/dio_provider.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

class CountryDetectionResult {
  final String? countryCode;
  final String? currency;
  final String source;

  const CountryDetectionResult({
    this.countryCode,
    this.currency,
    required this.source,
  });
}

class CountryDetectionService {
  final Dio dio;

  CountryDetectionService(this.dio);

  Future<CountryDetectionResult> detect() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        'http://ip-api.com/json/',
        queryParameters: {
          'fields': 'status,countryCode,currency',
        },
      );
      final data = response.data;
      if (data != null && data['status'] == 'success') {
        return CountryDetectionResult(
          countryCode: data['countryCode'] as String?,
          currency: data['currency'] as String?,
          source: 'ip-api',
        );
      }
    } catch (_) {}

    return _fromLocale();
  }

  CountryDetectionResult _fromLocale() {
    final localeName = Platform.localeName; // e.g. ru_RU.UTF-8
    final cleaned = localeName.split('.').first.replaceAll('-', '_');
    final parts = cleaned.split('_');
    String? country;
    if (parts.length >= 2) {
      country = parts.last.toUpperCase();
      if (country.length != 2) country = null;
    }
    return CountryDetectionResult(
      countryCode: country,
      currency: null,
      source: 'locale',
    );
  }
}

final countryDetectionServiceProvider = Provider<CountryDetectionService>((ref) {
  return CountryDetectionService(ref.watch(dioProvider));
});

final detectCountryControllerProvider = Provider((ref) {
  return () async {
    final result = await ref.read(countryDetectionServiceProvider).detect();
    await ref.read(appSettingsProvider.notifier).setDetectedLocation(
          countryCode: result.countryCode,
          currency: result.currency,
        );
    return result;
  };
});
