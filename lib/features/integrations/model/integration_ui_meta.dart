import 'package:flutter/material.dart';
import 'package:valtero/entities/integrations/exchange_rate_api/model/exchange_rate_api_integration.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_drive_sync_integration.dart';
import 'package:valtero/entities/integrations/telegram/model/telegram_integration.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

class IntegrationUiMeta {
  final IconData icon;
  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) description;

  const IntegrationUiMeta({
    required this.icon,
    required this.title,
    required this.description,
  });
}

IntegrationUiMeta integrationUiMeta(String id) {
  return switch (id) {
    kTelegramIntegrationId => IntegrationUiMeta(
        icon: Icons.send_outlined,
        title: (l10n) => l10n.integrationTelegramTitle,
        description: (l10n) => l10n.integrationTelegramDescription,
      ),
    kExchangeRateApiIntegrationId => IntegrationUiMeta(
        icon: Icons.currency_exchange,
        title: (l10n) => l10n.integrationExchangeRateApiTitle,
        description: (l10n) => l10n.integrationExchangeRateApiDescription,
      ),
    kGoogleDriveSyncIntegrationId => IntegrationUiMeta(
        icon: Icons.cloud_sync_outlined,
        title: (l10n) => l10n.integrationGoogleDriveSyncTitle,
        description: (l10n) => l10n.integrationGoogleDriveSyncDescription,
      ),
    _ => IntegrationUiMeta(
        icon: Icons.extension_outlined,
        title: (_) => id,
        description: (_) => '',
      ),
  };
}

String connectionMessage(AppLocalizations l10n, String messageKey) {
  return switch (messageKey) {
    'connectionOk' => l10n.connectionOk,
    'connectionFailed' => l10n.connectionFailed,
    'connectionNetwork' => l10n.connectionNetwork,
    'connectionMissingFields' => l10n.connectionMissingFields,
    'connectionInvalidToken' => l10n.connectionInvalidToken,
    'connectionInvalidChat' => l10n.connectionInvalidChat,
    'connectionInvalidKey' => l10n.connectionInvalidKey,
    'connectionMissingClientId' => l10n.googleDriveMissingClientId,
    _ => l10n.connectionFailed,
  };
}
