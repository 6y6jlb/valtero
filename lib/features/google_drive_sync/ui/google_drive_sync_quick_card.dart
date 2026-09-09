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
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_ok_button.dart';
import 'package:valtero/widgets/app_toast.dart';

/// Google Drive sync status + Sync now / setup actions (Backup & sync card).
class GoogleDriveSyncQuickCard extends ConsumerStatefulWidget {
  /// When false (e.g. backup export/import running), all card actions are disabled.
  final bool actionsEnabled;

  const GoogleDriveSyncQuickCard({super.key, this.actionsEnabled = true});

  @override
  ConsumerState<GoogleDriveSyncQuickCard> createState() =>
      _GoogleDriveSyncQuickCardState();
}

class _GoogleDriveSyncQuickCardState
    extends ConsumerState<GoogleDriveSyncQuickCard> {
  bool _openingIntegration = false;
  bool _autoPromptedReauth = false;

  @override
  void initState() {
    super.initState();
    // If a previous (possibly background) sync already found the stored
    // credentials stale, surface it as soon as this card is opened instead
    // of waiting for the user to press "Sync now" and get the same error —
    // they shouldn't be left assuming everything is already in sync.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _maybeAutoPromptReauth(),
    );
  }

  void _maybeAutoPromptReauth() {
    if (!mounted || _autoPromptedReauth) return;
    final connected = ref.read(
      isIntegrationConfiguredProvider(kGoogleDriveSyncIntegrationId),
    );
    if (!connected) return;
    final state = ref.read(googleDriveSyncControllerProvider);
    if (state.status != GoogleDriveSyncStatus.error) return;
    if (!needsGoogleReauth(state.messageKey)) return;
    _autoPromptedReauth = true;
    final l10n = AppLocalizations.of(context)!;
    final message = googleDriveSyncResultMessage(
      l10n,
      GoogleDriveSyncResult.fail(state.messageKey),
    );
    // ignore: unawaited_futures
    _promptReauth(message);
  }

  bool _isBlocked({required bool syncing}) {
    return !widget.actionsEnabled || _openingIntegration || syncing;
  }

  Future<void> _syncGoogleDrive() async {
    final syncing =
        ref.read(googleDriveSyncControllerProvider).status ==
        GoogleDriveSyncStatus.syncing;
    if (_isBlocked(syncing: syncing)) return;
    final l10n = AppLocalizations.of(context)!;
    final result = await ref
        .read(googleDriveSyncControllerProvider.notifier)
        .syncNow();
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
          actions: [const AppOkButton()],
        ),
      );
      return;
    }
    if (needsGoogleReauth(result.messageKey)) {
      await _promptReauth(message);
      return;
    }
    showAppToast(context, message);
  }

  /// Shown when the stored Google credentials went stale (e.g. the user was
  /// signed out on another device): offers an immediate re-login instead of
  /// leaving the user stuck with a "sign in again" message and no action.
  Future<void> _promptReauth(String message) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldSignIn = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.googleDriveReauthRequired),
        content: Text(message),
        actions: [
          AppCloseIconButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            label: l10n.cancel,
          ),
          AppFilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: Icons.login,
            label: l10n.googleDriveSignIn,
          ),
        ],
      ),
    );
    if (shouldSignIn != true || !mounted) return;
    await _reauthAndSync();
  }

  Future<void> _reauthAndSync() async {
    final l10n = AppLocalizations.of(context)!;
    final passphrase =
        ref.read(appSettingsProvider).value?.googleDriveSyncPassphrase.trim() ??
        '';
    if (passphrase.isEmpty) {
      // No stored passphrase to reuse (shouldn't normally happen while
      // connected) — fall back to the full setup sheet.
      await _openGoogleDriveIntegration();
      return;
    }
    setState(() => _openingIntegration = true);
    final result = await ref
        .read(googleDriveSyncEngineProvider)
        .connectAndSync(
          passphrase: passphrase,
          includeFileScope:
              ref.read(appSettingsProvider).value?.googleDriveSharedFileId
                      .trim()
                      .isNotEmpty ??
                  false,
        );
    if (!mounted) return;
    setState(() => _openingIntegration = false);
    if (result.success) {
      setState(() {});
      return;
    }
    showAppToast(context, googleDriveSyncResultMessage(l10n, result));
  }

  Future<void> _openGoogleDriveIntegration() async {
    final syncing =
        ref.read(googleDriveSyncControllerProvider).status ==
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
    final settingsAsync = ref.watch(appSettingsProvider);
    final settings = settingsAsync.value;
    final connected =
        settings != null &&
        ref.watch(
          isIntegrationConfiguredProvider(kGoogleDriveSyncIntegrationId),
        );
    final meta = integrationUiMeta(kGoogleDriveSyncIntegrationId);
    final lastSynced = settings?.googleDriveLastSyncedAt;
    final syncState = ref.watch(googleDriveSyncControllerProvider);
    final syncing = syncState.status == GoogleDriveSyncStatus.syncing;
    final needsReauth =
        connected &&
        syncState.status == GoogleDriveSyncStatus.error &&
        needsGoogleReauth(syncState.messageKey);

    if (settingsAsync.isLoading && settings == null) {
      return Card(
        margin: EdgeInsets.zero,
        child: SizedBox(
          height: 132,
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    }

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
                if (syncing)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
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
              if (needsReauth)
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      size: 16,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.googleDriveSyncPaused,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                )
              else if (settings.googleDriveAccountEmail.isNotEmpty)
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
                  AppFilledButton(
                    label: l10n.googleDriveSyncNow,
                    busy: syncing,
                    onPressed: widget.actionsEnabled && !_openingIntegration
                        ? _syncGoogleDrive
                        : null,
                    icon: Icons.sync_outlined,
                  ),
                  if (lastSynced != null && !syncing)
                    ActionSuccessStatusIcon(
                      completedAt: lastSynced,
                      tooltip: l10n.googleDriveSyncStatusHint,
                    ),
                  AppTextButton(
                    label: l10n.dataSyncGoogleDriveManage,
                    busy: _openingIntegration,
                    onPressed: widget.actionsEnabled && !syncing
                        ? _openGoogleDriveIntegration
                        : null,
                    icon: Icons.settings_outlined,
                  ),
                ],
              ),
            ] else
              Align(
                alignment: Alignment.centerLeft,
                child: AppTextButton(
                  label: l10n.dataSyncGoogleDriveSetup,
                  busy: _openingIntegration,
                  onPressed: widget.actionsEnabled && !syncing
                      ? _openGoogleDriveIntegration
                      : null,
                  icon: Icons.settings_outlined,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
