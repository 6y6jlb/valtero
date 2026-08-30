import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_drive_sync_integration.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_oauth_config.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/features/data_sync/model/passphrase_generator.dart';
import 'package:valtero/widgets/passphrase_text_field.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_engine.dart';
import 'package:valtero/features/google_drive_sync/ui/google_drive_join_sheet.dart';
import 'package:valtero/features/integrations/model/integration_ui_meta.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/widgets/app_toast.dart';

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
  bool _busy = false;
  String? _status;
  bool _statusOk = false;

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
    });
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

  String _syncMessage(AppLocalizations l10n, GoogleDriveSyncResult result) {
    final key = result.messageKey;
    final base = switch (key) {
      'syncOk' => l10n.googleDriveSyncOk,
      'connectionOk' => l10n.connectionOk,
      'connectionFailed' => l10n.connectionFailed,
      'connectionMissingFields' => l10n.connectionMissingFields,
      'connectionMissingClientId' => l10n.googleDriveMissingClientId,
      'connectionInvalidToken' => l10n.googleDriveReauthRequired,
      'wrong_passphrase' => l10n.googleDriveWrongPassphrase,
      'missing_client_id' => l10n.googleDriveMissingClientId,
      'missing_client_secret' ||
      'invalid_client' =>
        l10n.googleDriveMissingClientSecret,
      'invalid_grant' => l10n.googleDriveReauthRequired,
      'missing_refresh_token' => l10n.googleDriveReauthRequired,
      'not_configured' => l10n.connectionMissingFields,
      'network_error' => l10n.connectionNetwork,
      'auth_canceled' => l10n.googleDriveAuthCanceled,
      'auth_access_denied' => l10n.googleDriveAccessDenied,
      'sign_in_failed' ||
      'auth_timeout' ||
      'invalid_redirect_scheme' ||
      'token_exchange_failed' =>
        l10n.googleDriveSignInFailed,
      'share_failed' => l10n.googleDriveShareFailed,
      'invalid_email' => l10n.googleDriveInvalidEmail,
      'remote_newer_schema' => l10n.googleDriveRemoteNewerSchema(
          result.remoteSchemaVersion ?? 0,
          result.localSchemaVersion ?? 0,
          result.remoteAppVersion?.trim().isNotEmpty == true
              ? result.remoteAppVersion!
              : '—',
        ),
      'unsupported_format' => l10n.googleDriveUnsupportedFormat,
      _ => key != null && key.startsWith('auth_')
          ? l10n.googleDriveSignInFailed
          : connectionMessage(l10n, key ?? 'connectionFailed'),
    };
    if (!result.success &&
        Platform.isAndroid &&
        _isLikelyAndroidOAuthConfigFailure(key)) {
      return '$base\n\n${l10n.googleDriveAndroidCustomUriHint}';
    }
    return base;
  }

  bool _isLikelyAndroidOAuthConfigFailure(String? key) {
    if (key == null) return false;
    return key == 'sign_in_failed' ||
        key == 'auth_canceled' ||
        key == 'invalid_redirect_scheme' ||
        key.startsWith('auth_');
  }

  Future<void> _showResultFeedback(
    AppLocalizations l10n,
    GoogleDriveSyncResult result,
  ) async {
    final message = _syncMessage(l10n, result);
    setState(() {
      _statusOk = result.success;
      _status = message;
    });
    if (!result.success && result.messageKey == 'remote_newer_schema') {
      if (!mounted) return;
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
    if (result.success) {
      showAppToast(context, l10n.googleDriveSyncOk);
    }
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
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _signIn() async {
    final l10n = AppLocalizations.of(context)!;
    if (!isGoogleOAuthClientConfigured) {
      setState(() {
        _statusOk = false;
        _status = l10n.googleDriveMissingClientId;
      });
      return;
    }
    final passphrase = _passphraseController.text.trim();
    if (passphrase.length < 8) {
      setState(() {
        _statusOk = false;
        _status = l10n.googleDrivePassphraseTooShort;
      });
      return;
    }
    setState(() {
      _busy = true;
      _status = null;
    });
    final result = await ref.read(googleDriveSyncEngineProvider).connectAndSync(
          passphrase: passphrase,
          includeFileScope: false,
        );
    if (!mounted) return;
    setState(() => _busy = false);
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
      await ref.read(appSettingsProvider.notifier).setGoogleDriveSync(
            syncPassphrase: passphrase,
          );
    }
    setState(() {
      _busy = true;
      _status = null;
    });
    final result =
        await ref.read(googleDriveSyncControllerProvider.notifier).syncNow();
    if (!mounted) return;
    setState(() => _busy = false);
    await _showResultFeedback(l10n, result);
  }

  Future<void> _test() async {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.read(appSettingsProvider).value;
    if (current == null) return;
    setState(() {
      _busy = true;
      _status = null;
    });
    final result = await ref
        .read(googleDriveSyncIntegrationProvider)
        .testConnection(current);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _statusOk = result.success;
      _status = connectionMessage(l10n, result.messageKey);
    });
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
      _busy = true;
      _status = null;
    });
    final result = await ref
        .read(googleDriveSyncEngineProvider)
        .shareWithEmail(_shareEmailController.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _statusOk = result.success;
      _status = result.success
          ? l10n.googleDriveShareOk
          : _syncMessage(l10n, result);
    });
    if (result.success) {
      _shareEmailController.clear();
    }
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
    final connected = settings != null &&
        ref.watch(
          isIntegrationConfiguredProvider(kGoogleDriveSyncIntegrationId),
        );
    final isJoined =
        settings?.googleDriveSyncRole == kGoogleDriveSyncRoleJoined;
    final lastSynced = settings?.googleDriveLastSyncedAt;
    final sharedWith = settings?.googleDriveSharedWithEmails ?? const [];
    final syncState = ref.watch(googleDriveSyncControllerProvider);

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
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _syncMessage(
                  l10n,
                  GoogleDriveSyncResult.fail(
                    'remote_newer_schema',
                    remoteSchemaVersion: syncState.remoteSchemaVersion,
                    remoteAppVersion: syncState.remoteAppVersion,
                    localSchemaVersion: syncState.localSchemaVersion,
                  ),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (connected) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_circle_outline),
            title: Text(
              isJoined
                  ? l10n.googleDriveJoinedAs
                  : l10n.integrationConnected,
            ),
            subtitle: Text(
              settings.googleDriveAccountEmail.isNotEmpty
                  ? settings.googleDriveAccountEmail
                  : l10n.integrationConnected,
            ),
          ),
          if (lastSynced != null)
            Text(
              l10n.googleDriveLastSynced(lastSynced.toLocal().toString()),
              style: theme.textTheme.bodySmall,
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
          children: [
            if (!connected) ...[
              FilledButton(
                onPressed: _busy ||
                        !isGoogleOAuthClientConfigured ||
                        !_passphraseReady
                    ? null
                    : _signIn,
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.googleDriveSignIn),
              ),
              OutlinedButton(
                onPressed:
                    _busy || !isGoogleOAuthClientConfigured ? null : _joinShared,
                child: Text(l10n.googleDriveJoinShared),
              ),
            ],
            if (connected) ...[
              FilledButton(
                onPressed: _busy ? null : _syncNow,
                child: Text(l10n.googleDriveSyncNow),
              ),
              FilledButton.tonal(
                onPressed: _busy ? null : _test,
                child: Text(l10n.integrationTestConnection),
              ),
              OutlinedButton(
                onPressed: _busy ? null : _disconnect,
                child: Text(
                  isJoined
                      ? l10n.googleDriveLeaveShared
                      : l10n.integrationDisconnect,
                ),
              ),
            ],
          ],
        ),
        if (connected && !isJoined) ...[
          const SizedBox(height: 24),
          Text(
            l10n.googleDriveSharedTitle,
            style: theme.textTheme.titleMedium,
          ),
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
            decoration: InputDecoration(
              labelText: l10n.googleDriveShareEmail,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonal(
              onPressed: _busy || !_shareEmailReady ? null : _share,
              child: Text(l10n.googleDriveShareAdd),
            ),
          ),
          if (sharedWith.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final email in sharedWith) Chip(label: Text(email)),
              ],
            ),
          ],
        ],
        if (_status != null) ...[
          const SizedBox(height: 12),
          Text(
            _status!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _statusOk
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
