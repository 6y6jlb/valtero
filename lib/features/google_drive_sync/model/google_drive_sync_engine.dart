import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_drive_rest_client.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_oauth_config.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_oauth_service.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_oauth_tokens.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/features/data_sync/model/backup_crypto.dart';
import 'package:valtero/features/data_sync/model/backup_format.dart';
import 'package:valtero/features/data_sync/model/data_sync_controller.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/database/schema_version.dart';
import 'package:valtero/shared/logging/logging_providers.dart';
import 'package:valtero/shared/settings/app_settings.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_version_provider.dart';

const kGoogleDriveSyncRoleOwner = 'owner';
const kGoogleDriveSyncRoleJoined = 'joined';

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
      final isJoined =
          settings.googleDriveSyncRole == kGoogleDriveSyncRoleJoined;

      _logDebug(
        'GDrive sync start role=${isJoined ? 'joined' : 'owner'} '
        'pushOnly=$pushOnly '
        'appDataFileId=${settings.googleDriveAppDataFileId} '
        'sharedFileId=${settings.googleDriveSharedFileId}',
      );

      if (isJoined) {
        final sharedId = settings.googleDriveSharedFileId.trim();
        if (sharedId.isEmpty) {
          return const GoogleDriveSyncResult.fail('not_configured');
        }
        final now = await _syncAgainstFile(
          drive: drive,
          accessToken: accessToken,
          settings: settings,
          passphrase: passphrase,
          fileId: sharedId,
          storeAsAppDataFileId: false,
          pushOnly: pushOnly,
          applySettings: applySettings,
        );
        return GoogleDriveSyncResult.ok(syncedAt: now);
      }

      // Owner: personal appDataFolder first.
      final personal = pushOnly
          ? null
          : await _resolvePersonalFile(drive, accessToken, settings);
      final personalId = personal?.id ??
          (settings.googleDriveAppDataFileId.trim().isEmpty
              ? null
              : settings.googleDriveAppDataFileId.trim());

      final now = await _syncAgainstFile(
        drive: drive,
        accessToken: accessToken,
        settings: settings,
        passphrase: passphrase,
        fileId: personalId,
        remoteMeta: personal,
        storeAsAppDataFileId: true,
        pushOnly: pushOnly,
        applySettings: applySettings,
        createInAppDataIfMissing: true,
      );

      // Then pull-merge-push the shared file when configured (two-way).
      final sharedId = (ref.read(appSettingsProvider).value ?? settings)
          .googleDriveSharedFileId
          .trim();
      if (sharedId.isNotEmpty) {
        try {
          final fresh =
              ref.read(appSettingsProvider).value ?? settings;
          await _syncAgainstFile(
            drive: drive,
            accessToken: accessToken,
            settings: fresh,
            passphrase: passphrase,
            fileId: sharedId,
            storeAsAppDataFileId: false,
            pushOnly: pushOnly,
            applySettings: false,
            createInAppDataIfMissing: false,
          );
        } on DioException catch (e, st) {
          // Shared sync is best-effort after personal succeeded.
          _logWarning(
            'GDrive shared sync failed (best-effort) fileId=$sharedId',
            error: e,
            stackTrace: st,
          );
        }
      }

      return GoogleDriveSyncResult.ok(syncedAt: now);
    } on BackupWrongPassphraseException {
      return const GoogleDriveSyncResult.fail('wrong_passphrase');
    } on BackupNewerSchemaException catch (e) {
      return GoogleDriveSyncResult.fail(
        'remote_newer_schema',
        remoteSchemaVersion: e.schemaVersion,
        remoteAppVersion: e.appVersion,
        localSchemaVersion: e.localSchemaVersion ?? kAppSchemaVersion,
      );
    } on BackupUnsupportedFormatException {
      return const GoogleDriveSyncResult.fail('unsupported_format');
    } on GoogleOAuthException catch (e, st) {
      _logError(
        'Google Drive sync OAuth failed code=${e.code}',
        error: e,
        stackTrace: st,
      );
      return GoogleDriveSyncResult.fail(e.code);
    } on DioException catch (e, st) {
      _logError('Google Drive sync network failed', error: e, stackTrace: st);
      return const GoogleDriveSyncResult.fail('network_error');
    } catch (e, st) {
      _logError('Google Drive sync failed', error: e, stackTrace: st);
      return const GoogleDriveSyncResult.fail('sync_failed');
    }
  }

  /// Pull (when needed) → merge → push encrypted snapshot for one Drive file.
  Future<DateTime> _syncAgainstFile({
    required GoogleDriveRestClient drive,
    required String accessToken,
    required AppSettings settings,
    required String passphrase,
    required String? fileId,
    GoogleDriveFileMeta? remoteMeta,
    required bool storeAsAppDataFileId,
    required bool pushOnly,
    required bool applySettings,
    bool createInAppDataIfMissing = false,
  }) async {
    var resolvedId = fileId?.trim();
    if (resolvedId != null && resolvedId.isEmpty) resolvedId = null;
    final target = storeAsAppDataFileId ? 'personal' : 'shared';
    final lastSyncedAt = storeAsAppDataFileId
        ? settings.googleDriveLastSyncedAt
        : settings.googleDriveSharedLastSyncedAt;

    if (!pushOnly && resolvedId != null) {
      final meta = remoteMeta ??
          await drive.getFileMeta(
            accessToken: accessToken,
            fileId: resolvedId,
          );
      if (meta != null) {
        _logDebug(
          'GDrive fetch meta target=$target fileId=${meta.id} '
          'modified=${meta.modifiedTime?.toUtc().toIso8601String()} '
          'size=${meta.size} owner=${meta.ownerEmail}',
        );
        final bytes = await drive.downloadFile(
          accessToken: accessToken,
          fileId: meta.id,
        );
        final content = utf8.decode(bytes);
        final envelope = await ref
            .read(dataSyncControllerProvider)
            .decryptFileContent(
              fileContent: content,
              passphrase: passphrase,
            );

        _logDebug(
          'GDrive decrypted target=$target fileId=${meta.id} '
          'schema=${envelope.schemaVersion} '
          'expenses=${envelope.data.expenses.length} '
          'tags=${envelope.data.tags.length} '
          'payments=${envelope.data.paymentMethods.length} '
          'rates=${envelope.data.exchangeRateOverrides.length}',
        );

        final shouldPull = lastSyncedAt == null ||
            (meta.modifiedTime != null &&
                lastSyncedAt.isBefore(meta.modifiedTime!));

        _logDebug(
          'GDrive pull decision target=$target shouldPull=$shouldPull '
          'lastSyncedAt=${lastSyncedAt?.toUtc().toIso8601String()} '
          'modified=${meta.modifiedTime?.toUtc().toIso8601String()}',
        );

        if (shouldPull) {
          final conflicts = await ref
              .read(dataSyncControllerProvider)
              .findDuplicateConflicts(envelope);
          final skipIds = {
            for (final c in conflicts) c.incoming.clientId,
          };
          _logDebug(
            'GDrive merge plan target=$target '
            'conflicts=${conflicts.length} skipIds=${skipIds.length}',
          );
          final report = await ref.read(backupImporterProvider).importEnvelope(
                db: ref.read(appDatabaseProvider),
                envelope: envelope,
                currentSettings: settings,
                applySettings: applySettings,
                skipClientIds: skipIds,
                saveSettings: (updated) => ref
                    .read(appSettingsProvider.notifier)
                    .updateSettings(updated),
              );
          _logDebug(
            'GDrive import done target=$target '
            'expensesAdded=${report.expensesAdded} '
            'tagsAdded=${report.tagsAdded} '
            'paymentsAdded=${report.paymentsAdded} '
            'skippedDup=${report.expensesSkippedDuplicate}',
          );
          await _mergeGoogleDriveMetadataFromEnvelope(
            envelope: envelope,
            settings: ref.read(appSettingsProvider).value ?? settings,
          );
          ref.invalidate(appSettingsProvider);
        }

        if (storeAsAppDataFileId &&
            settings.googleDriveAppDataFileId != meta.id) {
          await ref.read(appSettingsProvider.notifier).setGoogleDriveSync(
                appDataFileId: meta.id,
              );
        }
        resolvedId = meta.id;
      }
    }

    final freshSettings = ref.read(appSettingsProvider).value ?? settings;
    _logDebug('GDrive push start target=$target fileId=$resolvedId');
    final content =
        await _buildEncryptedSnapshot(freshSettings, passphrase);

    final GoogleDriveFileMeta uploaded;
    if (createInAppDataIfMissing ||
        (storeAsAppDataFileId &&
            (resolvedId == null || resolvedId.isEmpty))) {
      uploaded = await drive.uploadAppDataSyncFile(
        accessToken: accessToken,
        content: content,
        existingFileId: resolvedId,
      );
    } else if (resolvedId != null && resolvedId.isNotEmpty) {
      uploaded = await drive.updateFileContent(
        accessToken: accessToken,
        fileId: resolvedId,
        content: content,
      );
    } else {
      throw const GoogleDriveException('missing_file_id');
    }

    final now = DateTime.now();
    if (storeAsAppDataFileId) {
      await ref.read(appSettingsProvider.notifier).setGoogleDriveSync(
            appDataFileId: uploaded.id,
            lastSyncedAt: now,
          );
    } else {
      await ref.read(appSettingsProvider.notifier).setGoogleDriveSync(
            sharedLastSyncedAt: now,
          );
    }
    _logDebug(
      'GDrive push done target=$target fileId=${uploaded.id} '
      'syncedAt=${now.toUtc().toIso8601String()}',
    );
    return now;
  }

  /// Signs in, stores refresh token + passphrase, optionally does first sync.
  Future<GoogleDriveSyncResult> connectAndSync({
    required String passphrase,
    required bool includeFileScope,
  }) async {
    final integration = ref.read(googleDriveSyncIntegrationProvider);
    // ignore: unawaited_futures
    ref.read(appLoggerProvider).debug(
          'Google Drive sign-in starting '
          'platform=${_oauthPlatformLabel()} '
          'useWebview=${GoogleOAuthRedirect.forPlatform().useWebview}',
        );
    try {
      final result = await integration.oauth.signIn(
        includeFileScope: includeFileScope,
        scopeMode: GoogleDriveOAuthScopeMode.personal,
      );
      final refresh = result.tokens.refreshToken?.trim() ?? '';
      if (refresh.isEmpty) {
        _logError('Google Drive sign-in missing refresh token');
        return const GoogleDriveSyncResult.fail('missing_refresh_token');
      }
      _cachedTokens = result.tokens;
      await ref.read(appSettingsProvider.notifier).setGoogleDriveSync(
            enabled: true,
            accountEmail: result.email ?? '',
            refreshToken: refresh,
            syncPassphrase: passphrase.trim(),
            syncRole: kGoogleDriveSyncRoleOwner,
          );
      return syncNow();
    } on GoogleOAuthException catch (e, st) {
      _logError(
        'Google Drive sign-in failed code=${e.code}',
        error: e,
        stackTrace: st,
      );
      return GoogleDriveSyncResult.fail(e.code);
    } catch (e, st) {
      _logError('Google Drive sign-in failed', error: e, stackTrace: st);
      return const GoogleDriveSyncResult.fail('sign_in_failed');
    }
  }

  /// Discovers sync files shared with this Google account (needs full drive).
  Future<List<GoogleDriveFileMeta>> discoverSharedSyncFiles() async {
    final integration = ref.read(googleDriveSyncIntegrationProvider);
    final result = await integration.oauth.signIn(
      includeFileScope: false,
      scopeMode: GoogleDriveOAuthScopeMode.join,
    );
    final refresh = result.tokens.refreshToken?.trim();
    _cachedTokens = result.tokens;
    if (refresh != null && refresh.isNotEmpty) {
      await ref.read(appSettingsProvider.notifier).setGoogleDriveSync(
            accountEmail: result.email ?? '',
            refreshToken: refresh,
          );
    }
    return integration.drive.listSharedSyncFiles(result.tokens.accessToken);
  }

  /// Joins a sync file someone shared; uses the owner's passphrase.
  Future<GoogleDriveSyncResult> joinSharedSync({
    required String fileId,
    required String passphrase,
  }) async {
    final id = fileId.trim();
    if (id.isEmpty) {
      return const GoogleDriveSyncResult.fail('not_configured');
    }
    final phrase = passphrase.trim();
    if (phrase.length < 8) {
      return const GoogleDriveSyncResult.fail('connectionMissingFields');
    }
    try {
      final integration = ref.read(googleDriveSyncIntegrationProvider);
      // Prefer cached token from discover; otherwise re-auth with full drive.
      if (_cachedTokens == null || _cachedTokens!.isExpired) {
        final result = await integration.oauth.signIn(
          includeFileScope: false,
          scopeMode: GoogleDriveOAuthScopeMode.join,
        );
        final refresh = result.tokens.refreshToken?.trim() ?? '';
        if (refresh.isEmpty) {
          return const GoogleDriveSyncResult.fail('missing_refresh_token');
        }
        _cachedTokens = result.tokens;
        await ref.read(appSettingsProvider.notifier).setGoogleDriveSync(
              accountEmail: result.email ?? '',
              refreshToken: refresh,
            );
      }

      await ref.read(appSettingsProvider.notifier).setGoogleDriveSync(
            enabled: true,
            syncPassphrase: phrase,
            sharedFileId: id,
            syncRole: kGoogleDriveSyncRoleJoined,
            appDataFileId: '',
            clearSharedLastSyncedAt: true,
          );
      return syncNow(applySettings: false);
    } on GoogleOAuthException catch (e, st) {
      _logError(
        'Google Drive join OAuth failed code=${e.code}',
        error: e,
        stackTrace: st,
      );
      return GoogleDriveSyncResult.fail(e.code);
    } on BackupWrongPassphraseException {
      return const GoogleDriveSyncResult.fail('wrong_passphrase');
    } catch (e, st) {
      _logError('Google Drive join failed', error: e, stackTrace: st);
      return const GoogleDriveSyncResult.fail('sign_in_failed');
    }
  }

  void _logDebug(String message) {
    // ignore: unawaited_futures
    ref.read(appLoggerProvider).debug(message);
  }

  void _logWarning(String message, {Object? error, StackTrace? stackTrace}) {
    // ignore: unawaited_futures
    ref.read(appLoggerProvider).warning(
          message,
          error: error,
          stackTrace: stackTrace,
        );
  }

  void _logError(String message, {Object? error, StackTrace? stackTrace}) {
    // ignore: unawaited_futures
    ref.read(appLoggerProvider).error(
          message,
          error: error,
          stackTrace: stackTrace,
        );
  }

  String _oauthPlatformLabel() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isLinux) return 'linux';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isIOS) return 'ios';
    return 'other';
  }

  Future<GoogleDriveSyncResult> shareWithEmail(String email) async {
    final settings = ref.read(appSettingsProvider).value;
    if (settings == null) {
      return const GoogleDriveSyncResult.fail('no_settings');
    }
    if (settings.googleDriveSyncRole == kGoogleDriveSyncRoleJoined) {
      return const GoogleDriveSyncResult.fail('share_failed');
    }
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      return const GoogleDriveSyncResult.fail('invalid_email');
    }
    final integration = ref.read(googleDriveSyncIntegrationProvider);
    try {
      final result = await integration.oauth.signIn(
        includeFileScope: true,
        scopeMode: GoogleDriveOAuthScopeMode.share,
      );
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
            syncRole: kGoogleDriveSyncRoleOwner,
          );
      return const GoogleDriveSyncResult.ok(messageKey: 'shareOk');
    } on GoogleOAuthException catch (e, st) {
      _logError(
        'Google Drive share OAuth failed code=${e.code}',
        error: e,
        stackTrace: st,
      );
      return GoogleDriveSyncResult.fail(e.code);
    } on DioException catch (e, st) {
      _logError('Google Drive share network failed', error: e, stackTrace: st);
      return const GoogleDriveSyncResult.fail('share_failed');
    } catch (e, st) {
      _logError('Google Drive share failed', error: e, stackTrace: st);
      return const GoogleDriveSyncResult.fail('share_failed');
    }
  }

  /// Revokes writer access for [email] on the shared sync file.
  Future<GoogleDriveSyncResult> revokeShare(String email) async {
    final settings = ref.read(appSettingsProvider).value;
    if (settings == null) {
      return const GoogleDriveSyncResult.fail('no_settings');
    }
    if (settings.googleDriveSyncRole == kGoogleDriveSyncRoleJoined) {
      return const GoogleDriveSyncResult.fail('revoke_failed');
    }
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      return const GoogleDriveSyncResult.fail('invalid_email');
    }
    final sharedId = settings.googleDriveSharedFileId.trim();
    if (sharedId.isEmpty) {
      return const GoogleDriveSyncResult.fail('revoke_failed');
    }
    final known = settings.googleDriveSharedWithEmails
        .map((e) => e.toLowerCase())
        .contains(trimmed);
    if (!known) {
      return const GoogleDriveSyncResult.fail('revoke_failed');
    }

    final integration = ref.read(googleDriveSyncIntegrationProvider);
    try {
      final result = await integration.oauth.signIn(
        includeFileScope: true,
        scopeMode: GoogleDriveOAuthScopeMode.share,
      );
      final refresh = result.tokens.refreshToken?.trim();
      _cachedTokens = result.tokens;
      if (refresh != null && refresh.isNotEmpty) {
        await ref.read(appSettingsProvider.notifier).setGoogleDriveSync(
              refreshToken: refresh,
              accountEmail: result.email ?? settings.googleDriveAccountEmail,
            );
      }

      final accessToken = result.tokens.accessToken;
      final permissions = await integration.drive.listPermissions(
        accessToken: accessToken,
        fileId: sharedId,
      );
      GoogleDrivePermission? match;
      for (final p in permissions) {
        final addr = p.emailAddress?.trim().toLowerCase();
        if (addr != null && addr == trimmed) {
          match = p;
          break;
        }
      }
      if (match != null) {
        await integration.drive.deletePermission(
          accessToken: accessToken,
          fileId: sharedId,
          permissionId: match.id,
        );
      } else {
        _logDebug(
          'GDrive revoke: no Drive permission for $trimmed on $sharedId; '
          'cleaning local list only',
        );
      }

      final emails = settings.googleDriveSharedWithEmails
          .where((e) => e.toLowerCase() != trimmed)
          .toList()
        ..sort();
      await ref.read(appSettingsProvider.notifier).setGoogleDriveSync(
            sharedWithEmails: emails,
          );
      return const GoogleDriveSyncResult.ok(messageKey: 'revokeOk');
    } on GoogleOAuthException catch (e, st) {
      _logError(
        'Google Drive revoke OAuth failed code=${e.code}',
        error: e,
        stackTrace: st,
      );
      return GoogleDriveSyncResult.fail(e.code);
    } on DioException catch (e, st) {
      _logError('Google Drive revoke network failed', error: e, stackTrace: st);
      return const GoogleDriveSyncResult.fail('revoke_failed');
    } catch (e, st) {
      _logError('Google Drive revoke failed', error: e, stackTrace: st);
      return const GoogleDriveSyncResult.fail('revoke_failed');
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
    return drive.findAppDataSyncFile(accessToken);
  }

  /// Merges non-secret Google Drive sync metadata from a pulled snapshot.
  Future<void> _mergeGoogleDriveMetadataFromEnvelope({
    required BackupEnvelope envelope,
    required AppSettings settings,
  }) async {
    if (settings.googleDriveSyncRole == kGoogleDriveSyncRoleJoined) {
      return;
    }

    final remote = envelope.data.settings;
    final remoteEmails = remote.googleDriveSharedWithEmails
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty && e.contains('@'));
    final remoteSharedId = remote.googleDriveSharedFileId.trim();

    final mergedEmails = {
      ...settings.googleDriveSharedWithEmails.map((e) => e.toLowerCase()),
      ...remoteEmails,
    }.toList()
      ..sort();

    final localSharedId = settings.googleDriveSharedFileId.trim();
    final mergedSharedId =
        localSharedId.isNotEmpty ? localSharedId : remoteSharedId;

    final emailsChanged = mergedEmails.length !=
            settings.googleDriveSharedWithEmails.length ||
        !mergedEmails.every(
          settings.googleDriveSharedWithEmails
              .map((e) => e.toLowerCase())
              .contains,
        );
    final sharedIdChanged =
        mergedSharedId.isNotEmpty && mergedSharedId != localSharedId;

    if (!emailsChanged && !sharedIdChanged) return;

    await ref.read(appSettingsProvider.notifier).setGoogleDriveSync(
          sharedWithEmails: mergedEmails,
          sharedFileId: sharedIdChanged ? mergedSharedId : null,
        );
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
    final lastSynced = settings == null
        ? null
        : (settings.googleDriveSyncRole == kGoogleDriveSyncRoleJoined
            ? settings.googleDriveSharedLastSyncedAt
            : settings.googleDriveLastSyncedAt);
    return GoogleDriveSyncState(
      lastSyncedAt: lastSynced,
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
