import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_drive_sync_integration.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_oauth_config.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/features/data_sync/model/passphrase_generator.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_engine.dart';
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
  bool _obscurePassphrase = true;
  bool _busy = false;
  String? _status;
  bool _statusOk = false;

  @override
  void initState() {
    super.initState();
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
    _passphraseController.dispose();
    _shareEmailController.dispose();
    super.dispose();
  }

  String _syncMessage(AppLocalizations l10n, GoogleDriveSyncResult result) {
    return switch (result.messageKey) {
      'syncOk' => l10n.googleDriveSyncOk,
      'connectionOk' => l10n.connectionOk,
      'connectionFailed' => l10n.connectionFailed,
      'connectionMissingFields' => l10n.connectionMissingFields,
      'connectionMissingClientId' => l10n.googleDriveMissingClientId,
      'connectionInvalidToken' => l10n.googleDriveReauthRequired,
      'wrong_passphrase' => l10n.googleDriveWrongPassphrase,
      'missing_client_id' => l10n.googleDriveMissingClientId,
      'missing_refresh_token' => l10n.googleDriveReauthRequired,
      'not_configured' => l10n.connectionMissingFields,
      'network_error' => l10n.connectionFailed,
      'sign_in_failed' => l10n.googleDriveSignInFailed,
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
      _ => connectionMessage(l10n, result.messageKey ?? 'connectionFailed'),
    };
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider).value;
    final connected = settings != null &&
        ref.watch(
          isIntegrationConfiguredProvider(kGoogleDriveSyncIntegrationId),
        );
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
            title: Text(l10n.integrationConnected),
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
        TextField(
          controller: _passphraseController,
          obscureText: _obscurePassphrase,
          decoration: InputDecoration(
            labelText: l10n.googleDriveSyncPassphrase,
            helperText: l10n.googleDriveSyncPassphraseHint,
            suffixIcon: IconButton(
              tooltip: _obscurePassphrase
                  ? l10n.dataSyncShowPassphrase
                  : l10n.dataSyncHidePassphrase,
              onPressed: () =>
                  setState(() => _obscurePassphrase = !_obscurePassphrase),
              icon: Icon(
                _obscurePassphrase ? Icons.visibility : Icons.visibility_off,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () {
                      final phrase = generatePassphrase();
                      setState(() => _passphraseController.text = phrase);
                    },
              child: Text(l10n.dataSyncGenerateShort),
            ),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () async {
                      final text = _passphraseController.text;
                      if (text.isEmpty) return;
                      await Clipboard.setData(ClipboardData(text: text));
                      if (!context.mounted) return;
                      showAppToast(context, l10n.copiedToClipboard);
                    },
              child: Text(l10n.dataSyncCopyShort),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (!connected)
              FilledButton(
                onPressed: _busy ? null : _signIn,
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.googleDriveSignIn),
              ),
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
                child: Text(l10n.integrationDisconnect),
              ),
            ],
          ],
        ),
        if (connected) ...[
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
            decoration: InputDecoration(
              labelText: l10n.googleDriveShareEmail,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonal(
              onPressed: _busy ? null : _share,
              child: Text(l10n.googleDriveShareAdd),
            ),
          ),
          if (sharedWith.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final email in sharedWith)
                  Chip(label: Text(email)),
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
