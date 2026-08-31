import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_drive_sync_integration.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_engine.dart';
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
    final syncing = ref.watch(googleDriveSyncControllerProvider).status ==
        GoogleDriveSyncStatus.syncing;
    final meta = integrationUiMeta(kGoogleDriveSyncIntegrationId);
    final color = connected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.38);

    return IconButton(
      tooltip: meta.title(l10n),
      onPressed: () => showGoogleDriveSyncSheet(context),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: syncing
            ? SizedBox(
                key: const ValueKey('syncing'),
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: color,
                ),
              )
            : Icon(
                Icons.cloud_sync_outlined,
                key: const ValueKey('idle'),
                color: color,
              ),
      ),
    );
  }
}
