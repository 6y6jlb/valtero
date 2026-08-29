import 'package:valtero/entities/integrations/model/integration_test_result.dart';
import 'package:valtero/shared/settings/app_settings.dart';

/// Optional external service that can be connected from Settings → Integrations.
abstract class AppIntegration {
  /// Stable id, e.g. `telegram` or `exchangerate_api`.
  String get id;

  /// Whether credentials are present and the integration is enabled.
  bool isConfigured(AppSettings settings);

  /// Probe the remote service with the given (possibly unsaved) settings.
  Future<IntegrationTestResult> testConnection(AppSettings settings);
}
