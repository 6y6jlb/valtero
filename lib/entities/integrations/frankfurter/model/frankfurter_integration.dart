import 'dart:io';

import 'package:dio/dio.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_provider.dart';
import 'package:valtero/entities/integrations/model/app_integration.dart';
import 'package:valtero/entities/integrations/model/integration_test_result.dart';
import 'package:valtero/shared/logging/app_logger.dart';
import 'package:valtero/shared/settings/app_settings.dart';

const kFrankfurterIntegrationId = 'frankfurter';

/// Free ECB rates via [api.frankfurter.dev](https://api.frankfurter.dev).
/// Built-in fallback when ExchangeRate-API is not connected — no credentials.
class FrankfurterIntegration implements AppIntegration {
  FrankfurterIntegration(this._provider, {AppLogger? logger}) : _logger = logger;

  final ExchangeRateProvider _provider;
  final AppLogger? _logger;

  @override
  String get id => kFrankfurterIntegrationId;

  /// Always available — no opt-in credentials.
  @override
  bool isConfigured(AppSettings settings) => true;

  @override
  Future<IntegrationTestResult> testConnection(AppSettings settings) async {
    try {
      final rates = await _provider.fetchRates(
        base: 'EUR',
        targets: const ['USD'],
      );
      if (rates['USD'] == null) {
        // ignore: unawaited_futures
        _logger?.warning('Frankfurter testConnection: empty USD rate');
        return IntegrationTestResult.fail('connectionFailed');
      }
      return IntegrationTestResult.ok();
    } on DioException catch (e, st) {
      // ignore: unawaited_futures
      _logger?.error(
        'Frankfurter testConnection failed type=${e.type.name} '
        'host=api.frankfurter.dev',
        error: e.error ?? e.message,
        stackTrace: st,
      );
      return IntegrationTestResult.fail(_dioFailureKey(e));
    } catch (e, st) {
      // ignore: unawaited_futures
      _logger?.error(
        'Frankfurter testConnection failed',
        error: e,
        stackTrace: st,
      );
      return IntegrationTestResult.fail('connectionFailed');
    }
  }

  String _dioFailureKey(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'connectionNetwork';
      default:
        break;
    }
    if (e.error is SocketException) {
      return 'connectionNetwork';
    }
    return 'connectionFailed';
  }
}
