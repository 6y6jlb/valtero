import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/integrations/exchange_rate_api/model/exchange_rate_api_integration.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_drive_sync_integration.dart';
import 'package:valtero/entities/integrations/model/app_integration.dart';
import 'package:valtero/entities/integrations/model/export_destination_integration.dart';
import 'package:valtero/entities/integrations/telegram/model/telegram_integration.dart';
import 'package:valtero/shared/logging/logging_providers.dart';
import 'package:valtero/shared/network/dio_provider.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

final telegramIntegrationProvider = Provider<TelegramIntegration>((ref) {
  return TelegramIntegration(
    ref.watch(dioProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final exchangeRateApiIntegrationProvider =
    Provider<ExchangeRateApiIntegration>((ref) {
  return ExchangeRateApiIntegration(ref.watch(exchangeRateApiProvider));
});

final googleDriveSyncIntegrationProvider =
    Provider<GoogleDriveSyncIntegration>((ref) {
  return GoogleDriveSyncIntegration.fromDio(
    ref.watch(dioProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

/// All optional integrations shown in Settings → Integrations.
final integrationsProvider = Provider<List<AppIntegration>>((ref) {
  return [
    ref.watch(telegramIntegrationProvider),
    ref.watch(exchangeRateApiIntegrationProvider),
    ref.watch(googleDriveSyncIntegrationProvider),
  ];
});

/// Export destinations that are currently connected.
final configuredExportIntegrationsProvider =
    Provider<List<ExportDestinationIntegration>>((ref) {
  final settings = ref.watch(appSettingsProvider).value;
  if (settings == null) return const [];
  return ref
      .watch(integrationsProvider)
      .whereType<ExportDestinationIntegration>()
      .where((i) => i.isConfigured(settings))
      .toList();
});

/// Whether a given integration id is currently configured.
final isIntegrationConfiguredProvider =
    Provider.family<bool, String>((ref, id) {
  final settings = ref.watch(appSettingsProvider).value;
  if (settings == null) return false;
  for (final integration in ref.watch(integrationsProvider)) {
    if (integration.id == id) {
      return integration.isConfigured(settings);
    }
  }
  return false;
});
