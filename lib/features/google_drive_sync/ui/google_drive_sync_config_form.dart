import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_drive_sync_integration.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_oauth_config.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/features/data_sync/model/passphrase_generator.dart';
import 'package:valtero/widgets/passphrase_text_field.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_engine.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_messages.dart';
import 'package:valtero/features/google_drive_sync/ui/google_drive_join_sheet.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/widgets/app_toast.dart';
import 'package:valtero/widgets/action_success_status_icon.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';

class GoogleDriveSyncConfigForm extends ConsumerStatefulWidget {
  const GoogleDriveSyncConfigForm({super.key});

  @override
  ConsumerState<GoogleDriveSyncConfigForm> createState() =>
      _GoogleDriveSyncConfigFormState();
}

class _GoogleDriveSyncConfigFormState
    extends ConsumerState<GoogleDriveSyncConfigForm> {
  final _passphraseController = TextEditingController();
  final _shareEmailController = TextEditingController();
  String? _busyAction;
  String? _status;
  bool _autoPromptedReauth = false;

  bool get _busy => _busyAction != null;

  @override
  void initState() {
    super.initState();
    _passphraseController.addListener(_onFieldsChanged);
    _shareEmailController.addListener(_onFieldsChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(appSettingsProvider).value;
      if (s == null) return;
      if (s.googleDriveSyncPassphrase.isNotEmpty) {
        _passphraseController.text = s.googleDriveSyncPassphrase;
      }
      // A previous (possibly background) sync attempt already found the
      // stored credentials stale: surface it right away instead of waiting
      // for the user to press Sync now / Test connection and hit the same
      // error again.
      _maybeAutoPromptReauth();
    });
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
    setState(() => _status = message);
    // ignore: unawaited_futures
    _promptReauth(message);
  }

  @override
  void dispose() {
    _passphraseController.removeListener(_onFieldsChanged);
    _shareEmailController.removeListener(_onFieldsChanged);
    _passphraseController.dispose();
    _shareEmailController.dispose();
    super.dispose();
  }

  void _onFieldsChanged() => setState(() {});

  bool get _passphraseReady => _passphraseController.text.trim().length >= 8;

  bool get _shareEmailReady {
    final email = _shareEmailController.text.trim().toLowerCase();
    return email.isNotEmpty && email.contains('@');
  }

  Future<void> _showResultFeedback(
    AppLocalizations l10n,
    GoogleDriveSyncResult result,
  ) async {
    final message = googleDriveSyncResultMessage(
      l10n,
      result,
      includeAndroidOAuthHint: true,
    );
    if (result.success) {
      setState(() => _status = null);
      // Success / sync-progress toasts are owned by GoogleDriveSyncToastListener.
      return;
    }
    if (result.messageKey == 'remote_newer_schema') {
      // Schema dialog is owned by GoogleDriveSyncToastListener.
      return;
    }
    setState(() => _status = message);
    if (needsGoogleReauth(result.messageKey)) {
      await _promptReauth(message);
    }
  }

  /// The stored refresh token went stale (e.g. signed out on another
  /// device): offer an immediate re-login instead of leaving the user with
  /// only a "sign in again" message and no way to act on it.
  Future<void> _promptReauth(String message) async {
    if (!mounted) return;
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
    await _signIn();
  }

  /// Returns false if the user cancelled a passphrase-change confirmation.
  Future<bool> _confirmPassphraseChangeIfNeeded({
    required bool connected,
    required String savedPassphrase,
  }) async {
    final next = _passphraseController.text.trim();
    if (!connected) return true;
    if (next == savedPassphrase) return true;
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.googleDrivePassphraseChangeTitle),
        content: Text(l10n.googleDrivePassphraseChangeBody),
        actions: [
          AppCloseIconButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            label: l10n.cancel,
          ),
          AppFilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            destructive: true,
            icon: Icons.check,
            label: l10n.ok,
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _signIn() async {
    final l10n = AppLocalizations.of(context)!;
    if (!isGoogleOAuthClientConfigured) {
      setState(() => _status = l10n.googleDriveMissingClientId);
      return;
    }
    final passphrase = _passphraseController.text.trim();
    if (passphrase.length < 8) {
      setState(() => _status = l10n.googleDrivePassphraseTooShort);
      return;
    }
    setState(() {
      _busyAction = 'signIn';
      _status = null;
    });
    final result = await ref
        .read(googleDriveSyncControllerProvider.notifier)
        .connectAndSync(
          passphrase: passphrase,
          includeFileScope:
              ref.read(appSettingsProvider).value?.googleDriveSharedFileId
                      .trim()
                      .isNotEmpty ??
                  false,
        );
    if (!mounted) return;
    setState(() => _busyAction = null);
    await _showResultFeedback(l10n, result);
  }

  Future<void> _syncNow() async {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.read(appSettingsProvider).value;
    if (settings == null) return;
    final confirmed = await _confirmPassphraseChangeIfNeeded(
      connected: true,
      savedPassphrase: settings.googleDriveSyncPassphrase,
    );
    if (!confirmed || !mounted) return;
    final passphrase = _passphraseController.text.trim();
    if (passphrase.isNotEmpty) {
      await ref
          .read(appSettingsProvider.notifier)
          .setGoogleDriveSync(syncPassphrase: passphrase);
    }
    setState(() {
      _busyAction = 'sync';
      _status = null;
    });
    final result = await ref
        .read(googleDriveSyncControllerProvider.notifier)
        .syncNow();
    if (!mounted) return;
    setState(() => _busyAction = null);
    await _showResultFeedback(l10n, result);
  }

  Future<void> _test() async {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.read(appSettingsProvider).value;
    if (current == null) return;
    setState(() {
      _busyAction = 'test';
      _status = null;
    });
    final result = await ref
        .read(googleDriveSyncIntegrationProvider)
        .testConnection(current);
    if (!mounted) return;
    setState(() {
      _busyAction = null;
      if (result.success) {
        _status = null;
      }
    });
    if (result.success) {
      showAppToast(
        context,
        googleDriveConnectionMessage(l10n, result.messageKey),
      );
      return;
    }
    final message = googleDriveConnectionMessage(l10n, result.messageKey);
    setState(() => _status = message);
    if (needsGoogleReauth(result.messageKey)) {
      await _promptReauth(message);
    }
  }

  Future<void> _disconnect() async {
    final l10n = AppLocalizations.of(context)!;
    await ref.read(appSettingsProvider.notifier).clearGoogleDriveSync();
    if (!mounted) return;
    setState(() {
      _passphraseController.clear();
      _shareEmailController.clear();
      _status = null;
    });
    showAppToast(context, l10n.integrationDisconnect);
  }

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busyAction = 'share';
      _status = null;
    });
    final result = await ref
        .read(googleDriveSyncEngineProvider)
        .shareWithEmail(_shareEmailController.text);
    if (!mounted) return;
    setState(() {
      _busyAction = null;
      if (result.success) {
        _status = null;
        showAppToast(context, l10n.googleDriveShareOk);
      } else {
        _status = googleDriveSyncResultMessage(l10n, result);
      }
    });
    if (result.success) {
      _shareEmailController.clear();
    }
  }

  Future<void> _revokeShare(String email) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busyAction = 'revoke';
      _status = null;
    });
    final result =
        await ref.read(googleDriveSyncEngineProvider).revokeShare(email);
    if (!mounted) return;
    setState(() {
      _busyAction = null;
      if (result.success) {
        _status = null;
        showAppToast(context, l10n.googleDriveRevokeOk);
      } else {
        _status = googleDriveSyncResultMessage(l10n, result);
      }
    });
  }

  Future<void> _joinShared() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showJoinSharedSyncSheet(context);
    if (!mounted || result == null) return;
    await _showResultFeedback(l10n, result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider).value;
    final connected =
        settings != null &&
        ref.watch(
          isIntegrationConfiguredProvider(kGoogleDriveSyncIntegrationId),
        );
    final isJoined =
        settings?.googleDriveSyncRole == kGoogleDriveSyncRoleJoined;
    final lastSynced = isJoined
        ? settings?.googleDriveSharedLastSyncedAt
        : settings?.googleDriveLastSyncedAt;
    final sharedWith = settings?.googleDriveSharedWithEmails ?? const [];
    final syncState = ref.watch(googleDriveSyncControllerProvider);
    final needsReauth =
        connected &&
        syncState.status == GoogleDriveSyncStatus.error &&
        needsGoogleReauth(syncState.messageKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isGoogleOAuthClientConfigured) ...[
          Text(
            l10n.googleDriveMissingClientId,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (syncState.messageKey == 'remote_newer_schema') ...[
          Material(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                googleDriveSyncResultMessage(
                  l10n,
                  GoogleDriveSyncResult.fail(
                    'remote_newer_schema',
                    remoteSchemaVersion: syncState.remoteSchemaVersion,
                    remoteAppVersion: syncState.remoteAppVersion,
                    localSchemaVersion: syncState.localSchemaVersion,
                  ),
                ),
                softWrap: true,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  height: 1.35,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (connected) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              needsReauth
                  ? Icons.warning_amber_outlined
                  : Icons.check_circle_outline,
              color: needsReauth ? theme.colorScheme.error : null,
            ),
            title: Text(
              needsReauth
                  ? l10n.googleDriveSyncPaused
                  : (isJoined
                        ? l10n.googleDriveJoinedAs
                        : l10n.integrationConnected),
              style: needsReauth
                  ? TextStyle(color: theme.colorScheme.error)
                  : null,
            ),
            subtitle: Text(
              settings.googleDriveAccountEmail.isNotEmpty
                  ? settings.googleDriveAccountEmail
                  : l10n.integrationConnected,
            ),
          ),
          const SizedBox(height: 12),
        ],
        PassphraseTextField(
          controller: _passphraseController,
          labelText: l10n.googleDriveSyncPassphrase,
          helperText: l10n.googleDriveSyncPassphraseHint,
          enabled: !_busy,
          showGenerate: true,
          showCopy: true,
          onGenerate: () {
            setState(() {
              _passphraseController.text = generatePassphrase();
            });
          },
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (!connected) ...[
              AppFilledButton(
                label: l10n.googleDriveSignIn,
                busy: _busyAction == 'signIn',
                onPressed:
                    !_busy && isGoogleOAuthClientConfigured && _passphraseReady
                    ? _signIn
                    : null,
                icon: Icons.login,
              ),
              AppOutlinedButton(
                label: l10n.googleDriveJoinShared,
                onPressed: _busy || !isGoogleOAuthClientConfigured
                    ? null
                    : _joinShared,
                icon: Icons.group_add_outlined,
              ),
            ],
            if (connected) ...[
              AppFilledButton(
                label: l10n.googleDriveSyncNow,
                busy: _busyAction == 'sync',
                onPressed: _busy ? null : _syncNow,
                icon: Icons.sync_outlined,
              ),
              if (lastSynced != null && !_busy)
                ActionSuccessStatusIcon(
                  completedAt: lastSynced,
                  tooltip: l10n.googleDriveSyncStatusHint,
                ),
              AppFilledButton.tonal(
                label: l10n.integrationTestConnection,
                busy: _busyAction == 'test',
                onPressed: _busy ? null : _test,
                icon: Icons.verified_outlined,
              ),
              AppOutlinedButton(
                label: isJoined
                    ? l10n.googleDriveLeaveShared
                    : l10n.integrationDisconnect,
                onPressed: _busy ? null : _disconnect,
                destructive: true,
                icon: Icons.link_off_outlined,
              ),
            ],
          ],
        ),
        if (_status != null) ...[
          const SizedBox(height: 8),
          Text(
            _status!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        if (connected && !isJoined) ...[
          const SizedBox(height: 24),
          Text(l10n.googleDriveSharedTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l10n.googleDriveSharedDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _shareEmailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !_busy,
            decoration: InputDecoration(labelText: l10n.googleDriveShareEmail),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: AppFilledButton.tonal(
              label: l10n.googleDriveShareAdd,
              busy: _busyAction == 'share',
              onPressed: _busy || !_shareEmailReady ? null : _share,
              icon: Icons.person_add_alt_outlined,
            ),
          ),
          if (sharedWith.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final email in sharedWith)
                  Chip(
                    label: Text(email),
                    onDeleted: _busy ? null : () => _revokeShare(email),
                    deleteIcon: const Icon(Icons.close, size: 18),
                  ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}
