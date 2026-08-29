import 'package:valtero/entities/exchange_rate/model/exchange_rate_provider.dart';
import 'package:valtero/entities/integrations/model/app_integration.dart';
import 'package:valtero/entities/integrations/model/integration_test_result.dart';
import 'package:valtero/shared/settings/app_settings.dart';

const kExchangeRateApiIntegrationId = 'exchangerate_api';

class ExchangeRateApiIntegration implements AppIntegration {
  final ExchangeRateProvider _provider;

  ExchangeRateApiIntegration(this._provider);

  @override
  String get id => kExchangeRateApiIntegrationId;

  @override
  bool isConfigured(AppSettings settings) {
    final key = settings.exchangeRateApiKey?.trim();
    return key != null && key.isNotEmpty;
  }

  @override
  Future<IntegrationTestResult> testConnection(AppSettings settings) async {
    final key = settings.exchangeRateApiKey?.trim() ?? '';
    if (key.isEmpty) {
      return IntegrationTestResult.fail('connectionMissingFields');
    }
    final ok = await _provider.validateApiKey(key);
    return ok
        ? IntegrationTestResult.ok()
        : IntegrationTestResult.fail('connectionInvalidKey');
  }

  /// Probe with an unsaved key typed in the config form.
  Future<IntegrationTestResult> testApiKey(String apiKey) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      return IntegrationTestResult.fail('connectionMissingFields');
    }
    final ok = await _provider.validateApiKey(key);
    return ok
        ? IntegrationTestResult.ok()
        : IntegrationTestResult.fail('connectionInvalidKey');
  }
}
