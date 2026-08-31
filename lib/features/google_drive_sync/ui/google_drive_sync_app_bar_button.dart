import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_drive_sync_integration.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/features/google_drive_sync/ui/google_drive_sync_sheet.dart';
import 'package:valtero/features/integrations/model/integration_ui_meta.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// AppBar sync affordance: active when Google Drive Sync is connected.
class GoogleDriveSyncAppBarButton extends ConsumerWidget {
  const GoogleDriveSyncAppBarButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final connected = ref.watch(
      isIntegrationConfiguredProvider(kGoogleDriveSyncIntegrationId),
    );
    final meta = integrationUiMeta(kGoogleDriveSyncIntegrationId);

    return IconButton(
      tooltip: meta.title(l10n),
      onPressed: () => showGoogleDriveSyncSheet(context),
      icon: Icon(
        Icons.cloud_sync_outlined,
        color: connected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.38),
      ),
    );
  }
}
