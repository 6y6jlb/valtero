import 'dart:io';

import 'package:valtero/features/google_drive_sync/model/google_drive_sync_engine.dart';
import 'package:valtero/features/integrations/model/integration_ui_meta.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// User-facing label for a [GoogleDriveSyncResult.messageKey].
String googleDriveSyncResultMessage(
  AppLocalizations l10n,
  GoogleDriveSyncResult result, {
  bool includeAndroidOAuthHint = false,
}) {
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
      includeAndroidOAuthHint &&
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
