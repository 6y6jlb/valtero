import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_drive_sync_integration.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_engine.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_messages.dart';
import 'package:valtero/features/google_drive_sync/ui/google_drive_sync_sheet.dart';
import 'package:valtero/features/integrations/model/integration_ui_meta.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// AppBar sync affordance: active when Google Drive Sync is connected, and
/// tinted as a warning when the stored credentials went stale (signed out
/// on another device) — visible without the user having to attempt a sync
/// first, so they don't assume everything is up to date when it isn't.
class GoogleDriveSyncAppBarButton extends ConsumerWidget {
  const GoogleDriveSyncAppBarButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final connected = ref.watch(
      isIntegrationConfiguredProvider(kGoogleDriveSyncIntegrationId),
    );
    final syncState = ref.watch(googleDriveSyncControllerProvider);
    final syncing = syncState.status == GoogleDriveSyncStatus.syncing;
    final needsReauth =
        connected &&
        syncState.status == GoogleDriveSyncStatus.error &&
        needsGoogleReauth(syncState.messageKey);
    final meta = integrationUiMeta(kGoogleDriveSyncIntegrationId);
    final color = needsReauth
        ? theme.colorScheme.error
        : connected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.38);

    return IconButton(
      tooltip: needsReauth ? l10n.googleDriveReauthRequired : meta.title(l10n),
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
                needsReauth
                    ? Icons.cloud_off_outlined
                    : Icons.cloud_sync_outlined,
                key: ValueKey(needsReauth ? 'needs-reauth' : 'idle'),
                color: color,
              ),
      ),
    );
  }
}
