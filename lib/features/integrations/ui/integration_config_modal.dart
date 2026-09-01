import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/exchange_rate_api/model/exchange_rate_api_integration.dart';
import 'package:valtero/entities/integrations/frankfurter/model/frankfurter_integration.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_drive_sync_integration.dart';
import 'package:valtero/entities/integrations/model/app_integration.dart';
import 'package:valtero/entities/integrations/telegram/model/telegram_integration.dart';
import 'package:valtero/features/google_drive_sync/ui/google_drive_sync_config_form.dart';
import 'package:valtero/features/google_drive_sync/ui/google_drive_sync_help_sheet.dart';
import 'package:valtero/features/integrations/model/integration_ui_meta.dart';
import 'package:valtero/features/integrations/ui/forms/exchange_rate_api_config_form.dart';
import 'package:valtero/features/integrations/ui/forms/frankfurter_config_form.dart';
import 'package:valtero/features/integrations/ui/forms/telegram_config_form.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_header.dart';

Future<void> showIntegrationConfigSheet(
  BuildContext context, {
  required AppIntegration integration,
}) {
  return showAppModalSheet(
    context: context,
    child: IntegrationConfigModal(integration: integration),
  );
}

class IntegrationConfigModal extends ConsumerWidget {
  final AppIntegration integration;

  const IntegrationConfigModal({super.key, required this.integration});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final meta = integrationUiMeta(integration.id);
    final scrollController = PrimaryScrollController.maybeOf(context);
    final theme = Theme.of(context);
    final descriptionStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final showDriveHelp = integration.id == kGoogleDriveSyncIntegrationId;

    return ListView(
      controller: scrollController,
      padding: appModalScrollPadding(context),
      children: [
        AppSheetHeader(title: meta.title(l10n), trailing: Icon(meta.icon)),
        const SizedBox(height: 8),
        if (showDriveHelp)
          Text.rich(
            TextSpan(
              style: descriptionStyle,
              children: [
                TextSpan(text: meta.description(l10n)),
                const TextSpan(text: ' '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: IconButton(
                    tooltip: l10n.googleDriveHelpTitle,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () => showGoogleDriveSyncHelpSheet(context),
                    icon: Icon(
                      Icons.help_outline,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Text(meta.description(l10n), style: descriptionStyle),
        const SizedBox(height: 20),
        switch (integration.id) {
          kTelegramIntegrationId => const TelegramConfigForm(),
          kFrankfurterIntegrationId => const FrankfurterConfigForm(),
          kExchangeRateApiIntegrationId => const ExchangeRateApiConfigForm(),
          kGoogleDriveSyncIntegrationId => const GoogleDriveSyncConfigForm(),
          _ => Text(integration.id),
        },
      ],
    );
  }
}
