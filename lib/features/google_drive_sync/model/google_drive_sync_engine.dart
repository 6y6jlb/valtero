import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_drive_rest_client.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_oauth_service.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_oauth_tokens.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/features/data_sync/model/backup_crypto.dart';
import 'package:valtero/features/data_sync/model/backup_format.dart';
import 'package:valtero/features/data_sync/model/data_sync_controller.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/database/schema_version.dart';
import 'package:valtero/shared/settings/app_settings.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_version_provider.dart';

enum GoogleDriveSyncStatus {
  idle,
  syncing,
  success,
  needsPassphrase,
  error,
}

class GoogleDriveSyncState {
  final GoogleDriveSyncStatus status;
  final String? messageKey;
  final DateTime? lastSyncedAt;
  final int? remoteSchemaVersion;
  final String? remoteAppVersion;
  final int? localSchemaVersion;

  const GoogleDriveSyncState({
    this.status = GoogleDriveSyncStatus.idle,
    this.messageKey,
    this.lastSyncedAt,
    this.remoteSchemaVersion,
    this.remoteAppVersion,
    this.localSchemaVersion,
  });

  GoogleDriveSyncState copyWith({
    GoogleDriveSyncStatus? status,
    String? messageKey,
    bool clearMessage = false,
    DateTime? lastSyncedAt,
    int? remoteSchemaVersion,
    String? remoteAppVersion,
    int? localSchemaVersion,
    bool clearVersionInfo = false,
  }) {
    return GoogleDriveSyncState(
      status: status ?? this.status,
      messageKey: clearMessage ? null : (messageKey ?? this.messageKey),
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      remoteSchemaVersion: clearVersionInfo
          ? null
          : (remoteSchemaVersion ?? this.remoteSchemaVersion),
      remoteAppVersion: clearVersionInfo
          ? null
          : (remoteAppVersion ?? this.remoteAppVersion),
      localSchemaVersion: clearVersionInfo
          ? null
          : (localSchemaVersion ?? this.localSchemaVersion),
    );
  }
}

/// Pull-merge-push sync over Google Drive using the encrypted backup format.
class GoogleDriveSyncEngine {
  GoogleDriveSyncEngine(this.ref);

  final Ref ref;

  GoogleOAuthTokens? _cachedTokens;

  Future<GoogleDriveSyncResult> syncNow({
    bool pushOnly = false,
    bool applySettings = false,
  }) async {
    final settings = ref.read(appSettingsProvider).value;
    if (settings == null) {
      return const GoogleDriveSyncResult.fail('no_settings');
    }
    final integration = ref.read(googleDriveSyncIntegrationProvider);
    if (!integration.isConfigured(settings)) {
      return const GoogleDriveSyncResult.fail('not_configured');
    }

    try {
      final accessToken = await _ensureAccessToken(settings);
      final drive = integration.drive;
      final passphrase = settings.googleDriveSyncPassphrase;

      if (!pushOnly) {
        final remote = await _resolvePersonalFile(drive, accessToken, settings);
        if (remote != null) {
          final bytes = await drive.downloadFile(
            accessToken: accessToken,
            fileId: remote.id,
          );
          final content = utf8.decode(bytes);
          final envelope = await ref
              .read(dataSyncControllerProvider)
              .decryptFileContent(
                fileContent: content,
                passphrase: passphrase,
              );

          final shouldPull = settings.googleDriveLastSyncedAt == null ||
              (remote.modifiedTime != null &&
                  (settings.googleDriveLastSyncedAt!
                      .isBefore(remote.modifiedTime!)));

          if (shouldPull) {
            // Older-or-equal schema already validated in decryptFileContent;
            // newer schema throws BackupNewerSchemaException (no push below).
            final conflicts = await ref
                .read(dataSyncControllerProvider)
                .findDuplicateConflicts(envelope);
            // Auto-skip soft duplicates on background sync; unique new rows merge.
            final skipIds = {
              for (final c in conflicts) c.incoming.clientId,
            };
            await ref.read(backupImporterProvider).importEnvelope(
                  db: ref.read(appDatabaseProvider),
                  envelope: envelope,
                  currentSettings: settings,
                  applySettings: applySettings,
                  skipClientIds: skipIds,
                  saveSettings: (updated) => ref
                      .read(appSettingsProvider.notifier)
                      .updateSettings(updated),
                );
            ref.invalidate(appSettingsProvider);
          }

          if (settings.googleDriveAppDataFileId != remote.id) {
            await ref.read(appSettingsProvider.notifier).setGoogleDriveSync(
                  appDataFileId: remote.id,
                );
          }
        }
      }

      // Always push current local snapshot after pull/merge.
      final freshSettings = ref.read(appSettingsProvider).value ?? settings;
      final content = await _buildEncryptedSnapshot(freshSettings, passphrase);
      final fileId = freshSettings.googleDriveAppDataFileId.trim();
      final uploaded = await drive.uploadAppDataSyncFile(
        accessToken: accessToken,
        content: content,
        existingFileId: fileId.isEmpty ? null : fileId,
      );
      final now = DateTime.now();
      await ref.read(appSettingsProvider.notifier).setGoogleDriveSync(
            appDataFileId: uploaded.id,
            lastSyncedAt: now,
          );

      // Shared file (phase 2): keep in sync when configured.
      final sharedId = freshSettings.googleDriveSharedFileId.trim();
      if (sharedId.isNotEmpty) {
        try {
          await drive.updateFileContent(
            accessToken: accessToken,
            fileId: sharedId,
            content: content,
          );
        } on DioException {
          // Shared push is best-effort; personal sync already succeeded.
        }
      }

      return GoogleDriveSyncResult.ok(syncedAt: now);
    } on BackupWrongPassphraseException {
      return const GoogleDriveSyncResult.fail('wrong_passphrase');
    } on BackupNewerSchemaException catch (e) {
      // Do not push — overwriting a newer cloud snapshot would lose data.
      return GoogleDriveSyncResult.fail(
        'remote_newer_schema',
        remoteSchemaVersion: e.schemaVersion,
        remoteAppVersion: e.appVersion,
        localSchemaVersion: e.localSchemaVersion ?? kAppSchemaVersion,
      );
    } on BackupUnsupportedFormatException {
      return const GoogleDriveSyncResult.fail('unsupported_format');
    } on GoogleOAuthException catch (e) {
      return GoogleDriveSyncResult.fail(e.code);
    } on DioException {
      return const GoogleDriveSyncResult.fail('network_error');
    } catch (_) {
      return const GoogleDriveSyncResult.fail('sync_failed');
    }
  }

  /// Signs in, stores refresh token + passphrase, optionally does first sync.
  Future<GoogleDriveSyncResult> connectAndSync({
    required String passphrase,
    required bool includeFileScope,
  }) async {
    final integration = ref.read(googleDriveSyncIntegrationProvider);
    try {
      final result = await integration.oauth.signIn(
        includeFileScope: includeFileScope,
      );
      final refresh = result.tokens.refreshToken?.trim() ?? '';
      if (refresh.isEmpty) {
        return const GoogleDriveSyncResult.fail('missing_refresh_token');
      }
      _cachedTokens = result.tokens;
      await ref.read(appSettingsProvider.notifier).setGoogleDriveSync(
            enabled: true,
            accountEmail: result.email ?? '',
            refreshToken: refresh,
            syncPassphrase: passphrase.trim(),
          );
      return syncNow();
    } on GoogleOAuthException catch (e) {
      return GoogleDriveSyncResult.fail(e.code);
    } catch (_) {
      return const GoogleDriveSyncResult.fail('sign_in_failed');
    }
  }

  Future<GoogleDriveSyncResult> shareWithEmail(String email) async {
    final settings = ref.read(appSettingsProvider).value;
    if (settings == null) {
      return const GoogleDriveSyncResult.fail('no_settings');
    }
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      return const GoogleDriveSyncResult.fail('invalid_email');
    }
    final integration = ref.read(googleDriveSyncIntegrationProvider);
    try {
      // Re-auth with drive.file if needed, then ensure shared file exists.
      final result = await integration.oauth.signIn(includeFileScope: true);
      final refresh = result.tokens.refreshToken?.trim();
      _cachedTokens = result.tokens;
      if (refresh != null && refresh.isNotEmpty) {
        await ref.read(appSettingsProvider.notifier).setGoogleDriveSync(
              refreshToken: refresh,
              accountEmail: result.email ?? settings.googleDriveAccountEmail,
            );
      }

      final accessToken = result.tokens.accessToken;
      final passphrase = settings.googleDriveSyncPassphrase;
      final content = await _buildEncryptedSnapshot(
        ref.read(appSettingsProvider).value ?? settings,
        passphrase,
      );

      var sharedId = settings.googleDriveSharedFileId.trim();
      if (sharedId.isEmpty) {
        final created = await integration.drive.createSharedSyncFile(
          accessToken: accessToken,
          content: content,
        );
        sharedId = created.id;
      } else {
        await integration.drive.updateFileContent(
          accessToken: accessToken,
          fileId: sharedId,
          content: content,
        );
      }

      await integration.drive.shareFileWithEmail(
        accessToken: accessToken,
        fileId: sharedId,
        email: trimmed,
      );

      final emails = {
        ...settings.googleDriveSharedWithEmails.map((e) => e.toLowerCase()),
        trimmed,
      }.toList()
        ..sort();
      await ref.read(appSettingsProvider.notifier).setGoogleDriveSync(
            sharedFileId: sharedId,
            sharedWithEmails: emails,
          );
      return const GoogleDriveSyncResult.ok(messageKey: 'shareOk');
    } on GoogleOAuthException catch (e) {
      return GoogleDriveSyncResult.fail(e.code);
    } on DioException {
      return const GoogleDriveSyncResult.fail('share_failed');
    } catch (_) {
      return const GoogleDriveSyncResult.fail('share_failed');
    }
  }

  Future<String> _ensureAccessToken(AppSettings settings) async {
    final cached = _cachedTokens;
    if (cached != null &&
        !cached.isExpired &&
        cached.accessToken.isNotEmpty) {
      return cached.accessToken;
    }
    final integration = ref.read(googleDriveSyncIntegrationProvider);
    final tokens = await integration.oauth.refreshAccessToken(
      refreshToken: settings.googleDriveRefreshToken,
    );
    _cachedTokens = tokens;
    return tokens.accessToken;
  }

  Future<GoogleDriveFileMeta?> _resolvePersonalFile(
    GoogleDriveRestClient drive,
    String accessToken,
    AppSettings settings,
  ) async {
    final knownId = settings.googleDriveAppDataFileId.trim();
    if (knownId.isNotEmpty) {
      try {
        // Probe via download size not needed — list is safer if id stale.
        final found = await drive.findAppDataSyncFile(accessToken);
        return found;
      } catch (_) {
        return drive.findAppDataSyncFile(accessToken);
      }
    }
    return drive.findAppDataSyncFile(accessToken);
  }

  Future<String> _buildEncryptedSnapshot(
    AppSettings settings,
    String passphrase,
  ) async {
    final versionLabel = ref.read(appVersionLabelProvider);
    final appVersion = versionLabel == null
        ? null
        : versionLabel.startsWith('v')
            ? versionLabel.substring(1)
            : versionLabel;
    final envelope = await ref.read(backupSnapshotBuilderProvider).build(
          db: ref.read(appDatabaseProvider),
          settings: settings,
          appVersion: appVersion,
        );
    final clear = utf8.encode(envelope.encode());
    final encrypted = await ref.read(backupCryptoProvider).encryptBytes(
          clearBytes: clear,
          passphrase: passphrase,
        );
    return BackupOuterFile.fromEncrypted(encrypted).encode();
  }
}

class GoogleDriveSyncResult {
  final bool success;
  final String? messageKey;
  final DateTime? syncedAt;
  final int? remoteSchemaVersion;
  final String? remoteAppVersion;
  final int? localSchemaVersion;

  const GoogleDriveSyncResult({
    required this.success,
    this.messageKey,
    this.syncedAt,
    this.remoteSchemaVersion,
    this.remoteAppVersion,
    this.localSchemaVersion,
  });

  const GoogleDriveSyncResult.ok({this.messageKey = 'syncOk', this.syncedAt})
      : success = true,
        remoteSchemaVersion = null,
        remoteAppVersion = null,
        localSchemaVersion = null;

  const GoogleDriveSyncResult.fail(
    this.messageKey, {
    this.remoteSchemaVersion,
    this.remoteAppVersion,
    this.localSchemaVersion,
  })  : success = false,
        syncedAt = null;
}

final googleDriveSyncEngineProvider = Provider<GoogleDriveSyncEngine>((ref) {
  return GoogleDriveSyncEngine(ref);
});

/// UI-facing sync status (manual Sync now / background runs).
class GoogleDriveSyncController extends Notifier<GoogleDriveSyncState> {
  @override
  GoogleDriveSyncState build() {
    final settings = ref.watch(appSettingsProvider).value;
    return GoogleDriveSyncState(
      lastSyncedAt: settings?.googleDriveLastSyncedAt,
    );
  }

  Future<GoogleDriveSyncResult> syncNow({bool pushOnly = false}) async {
    state = state.copyWith(
      status: GoogleDriveSyncStatus.syncing,
      clearMessage: true,
      clearVersionInfo: true,
    );
    final result =
        await ref.read(googleDriveSyncEngineProvider).syncNow(pushOnly: pushOnly);
    state = state.copyWith(
      status: result.success
          ? GoogleDriveSyncStatus.success
          : (result.messageKey == 'wrong_passphrase'
              ? GoogleDriveSyncStatus.needsPassphrase
              : GoogleDriveSyncStatus.error),
      messageKey: result.messageKey,
      lastSyncedAt: result.syncedAt ?? state.lastSyncedAt,
      remoteSchemaVersion: result.remoteSchemaVersion,
      remoteAppVersion: result.remoteAppVersion,
      localSchemaVersion: result.localSchemaVersion,
    );
    return result;
  }
}

final googleDriveSyncControllerProvider =
    NotifierProvider<GoogleDriveSyncController, GoogleDriveSyncState>(
  GoogleDriveSyncController.new,
);
