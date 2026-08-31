import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_drive_sync_integration.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_engine.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_messages.dart';
import 'package:valtero/features/integrations/model/integration_ui_meta.dart';
import 'package:valtero/features/integrations/ui/integration_config_modal.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/widgets/action_success_status_icon.dart';
import 'package:valtero/widgets/app_toast.dart';

/// Google Drive sync status + Sync now / setup actions (Backup & sync card).
class GoogleDriveSyncQuickCard extends ConsumerStatefulWidget {
  /// When false (e.g. backup export/import running), all card actions are disabled.
  final bool actionsEnabled;

  const GoogleDriveSyncQuickCard({
    super.key,
    this.actionsEnabled = true,
  });

  @override
  ConsumerState<GoogleDriveSyncQuickCard> createState() =>
      _GoogleDriveSyncQuickCardState();
}

class _GoogleDriveSyncQuickCardState
    extends ConsumerState<GoogleDriveSyncQuickCard> {
  bool _openingIntegration = false;

  bool _isBlocked({required bool syncing}) {
    return !widget.actionsEnabled || _openingIntegration || syncing;
  }

  Future<void> _syncGoogleDrive() async {
    final syncing = ref.read(googleDriveSyncControllerProvider).status ==
        GoogleDriveSyncStatus.syncing;
    if (_isBlocked(syncing: syncing)) return;
    final l10n = AppLocalizations.of(context)!;
    final result =
        await ref.read(googleDriveSyncControllerProvider.notifier).syncNow();
    if (!mounted) return;
    if (result.success) {
      setState(() {});
      return;
    }
    final message = googleDriveSyncResultMessage(l10n, result);
    if (result.messageKey == 'remote_newer_schema') {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.googleDriveRemoteNewerSchemaTitle),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
            ),
          ],
        ),
      );
      return;
    }
    showAppToast(context, message);
  }

  Future<void> _openGoogleDriveIntegration() async {
    final syncing = ref.read(googleDriveSyncControllerProvider).status ==
        GoogleDriveSyncStatus.syncing;
    if (_isBlocked(syncing: syncing)) return;
    setState(() => _openingIntegration = true);
    try {
      final integrations = ref.read(integrationsProvider);
      final integration = integrations.firstWhere(
        (i) => i.id == kGoogleDriveSyncIntegrationId,
      );
      await showIntegrationConfigSheet(context, integration: integration);
    } finally {
      if (mounted) setState(() => _openingIntegration = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider).value;
    final connected = settings != null &&
        ref.watch(
          isIntegrationConfiguredProvider(kGoogleDriveSyncIntegrationId),
        );
    final meta = integrationUiMeta(kGoogleDriveSyncIntegrationId);
    final lastSynced = settings?.googleDriveLastSyncedAt;
    final syncing = ref.watch(googleDriveSyncControllerProvider).status ==
        GoogleDriveSyncStatus.syncing;
    final blocked = _isBlocked(syncing: syncing);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(meta.icon, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    meta.title(l10n),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.dataSyncGoogleDriveHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (connected) ...[
              if (settings.googleDriveAccountEmail.isNotEmpty)
                Text(
                  settings.googleDriveAccountEmail,
                  style: theme.textTheme.bodySmall,
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton(
                    onPressed: blocked ? null : _syncGoogleDrive,
                    child: Text(l10n.googleDriveSyncNow),
                  ),
                  if (lastSynced != null && !syncing)
                    ActionSuccessStatusIcon(
                      completedAt: lastSynced,
                      tooltip: l10n.googleDriveSyncStatusHint,
                    ),
                  TextButton(
                    onPressed: blocked ? null : _openGoogleDriveIntegration,
                    child: Text(l10n.dataSyncGoogleDriveManage),
                  ),
                ],
              ),
            ] else
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: blocked ? null : _openGoogleDriveIntegration,
                  child: Text(l10n.dataSyncGoogleDriveSetup),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
