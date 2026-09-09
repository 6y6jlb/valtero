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
    bool allowInteractiveReauth = true,
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
      var accessToken = await _ensureAccessToken(settings);
      final drive = integration.drive;
      final passphrase = settings.googleDriveSyncPassphrase;
      final isJoined =
          settings.googleDriveSyncRole == kGoogleDriveSyncRoleJoined;

      _logDebug(
        'GDrive sync start role=${isJoined ? 'joined' : 'owner'} '
        'pushOnly=$pushOnly allowInteractiveReauth=$allowInteractiveReauth '
        'tokenScopes=${_cachedTokens?.scope ?? '(unknown)'} '
        'appDataFileId=${settings.googleDriveAppDataFileId} '
        'sharedFileId=${settings.googleDriveSharedFileId} '
        'personalLastSynced=${settings.googleDriveLastSyncedAt?.toUtc().toIso8601String()} '
        'sharedLastSynced=${settings.googleDriveSharedLastSyncedAt?.toUtc().toIso8601String()}',
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
          accessToken = await _ensureSharedFileAccess(
            drive: drive,
            accessToken: accessToken,
            settings: fresh,
            fileId: sharedId,
            allowInteractiveReauth: allowInteractiveReauth,
          );
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
        } on GoogleDriveException catch (e, st) {
          _logError(
            'GDrive shared sync failed code=${e.code} fileId=$sharedId',
            error: e,
            stackTrace: st,
          );
          return GoogleDriveSyncResult.fail(e.code);
        } on DioException catch (e, st) {
          _logError(
            'GDrive shared sync failed fileId=$sharedId '
            '${googleDriveDioDebugSummary(e)}',
            error: e,
            stackTrace: st,
          );
          if (googleDriveDioIsNotFoundOrForbidden(e)) {
            return const GoogleDriveSyncResult.fail(
              'shared_file_inaccessible',
            );
          }
          // Transient network after personal succeeded — surface warning key.
          return const GoogleDriveSyncResult.fail('shared_sync_failed');
        } on GoogleOAuthException catch (e, st) {
          _logError(
            'GDrive shared sync OAuth failed code=${e.code} fileId=$sharedId',
            error: e,
            stackTrace: st,
          );
          return GoogleDriveSyncResult.fail(e.code);
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
      _logError(
        'Google Drive sync network failed ${googleDriveDioDebugSummary(e)}',
        error: e,
        stackTrace: st,
      );
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
      GoogleDriveFileMeta? meta = remoteMeta;
      if (meta == null) {
        try {
          meta = await drive.getFileMeta(
            accessToken: accessToken,
            fileId: resolvedId,
          );
        } on DioException catch (e) {
          _logWarning(
            'GDrive fetch meta failed target=$target fileId=$resolvedId '
            '${googleDriveDioDebugSummary(e)}',
            error: e,
          );
          // Shared file must be readable — rethrow so caller can upgrade
          // scopes or surface shared_file_inaccessible.
          if (!storeAsAppDataFileId) rethrow;
          meta = null;
        }
      }
      if (meta == null) {
        _logDebug(
          'GDrive fetch meta target=$target fileId=$resolvedId result=null '
          '(skip pull; will push if possible)',
        );
      } else {
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
          'incomes=${envelope.data.incomes.length} '
          'tags=${envelope.data.tags.length} '
          'payments=${envelope.data.paymentMethods.length} '
          'rates=${envelope.data.exchangeRateOverrides.length}',
        );

        final shouldPull = lastSyncedAt == null ||
            (meta.modifiedTime != null &&
                lastSyncedAt.isBefore(meta.modifiedTime!));
        final reason = lastSyncedAt == null
            ? 'no_local_shared_cursor'
            : (meta.modifiedTime == null
                ? 'remote_modified_unknown'
                : (shouldPull
                    ? 'remote_newer'
                    : 'local_cursor_on_or_after_remote'));

        _logDebug(
          'GDrive pull decision target=$target shouldPull=$shouldPull '
          'reason=$reason '
          'lastSyncedAt=${lastSyncedAt?.toUtc().toIso8601String()} '
          'modified=${meta.modifiedTime?.toUtc().toIso8601String()}',
        );

        if (shouldPull) {
          final conflicts = await ref
              .read(dataSyncControllerProvider)
              .findDuplicateConflicts(envelope);
          final skipIds = {
            for (final c in conflicts) c.clientId,
          };
          _logDebug(
            'GDrive merge plan target=$target '
            'conflicts=${conflicts.length} '
            'expenseConflicts=${conflicts.where((c) => !c.isIncome).length} '
            'incomeConflicts=${conflicts.where((c) => c.isIncome).length} '
            'skipIds=${skipIds.length}',
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
            'incomesAdded=${report.incomesAdded} '
            'tagsAdded=${report.tagsAdded} '
            'paymentsAdded=${report.paymentsAdded} '
            'skippedDup=${report.expensesSkippedDuplicate + report.incomesSkippedDuplicate}',
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
    final db = ref.read(appDatabaseProvider);
    final localExpenses = await db.getAllExpenses();
    final localIncomes = await db.getAllIncome();
    _logDebug(
      'GDrive push start target=$target fileId=$resolvedId '
      'localExpenses=${localExpenses.length} '
      'localIncomes=${localIncomes.length}',
    );
    final content =
        await _buildEncryptedSnapshot(freshSettings, passphrase);

    final GoogleDriveFileMeta uploaded;
    try {
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
    } on DioException catch (e) {
      _logError(
        'GDrive push failed target=$target fileId=$resolvedId '
        '${googleDriveDioDebugSummary(e)}',
        error: e,
      );
      rethrow;
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
      'syncedAt=${now.toUtc().toIso8601String()} '
      'remoteModified=${uploaded.modifiedTime?.toUtc().toIso8601String()} '
      'size=${uploaded.size}',
    );
    return now;
  }

  /// Signs in, stores refresh token + passphrase, optionally does first sync.
  Future<GoogleDriveSyncResult> connectAndSync({
    required String passphrase,
    required bool includeFileScope,
  }) async {
    final integration = ref.read(googleDriveSyncIntegrationProvider);
    final existing = ref.read(appSettingsProvider).value;
    // Re-sign-in must keep drive.file when a shared sync file is already
    // configured — personal-only scopes overwrite the refresh token and the
    // owner can no longer read/write the shared My Drive file (404).
    final needFileScope = includeFileScope ||
        (existing?.googleDriveSharedFileId.trim().isNotEmpty ?? false);
    // ignore: unawaited_futures
    ref.read(appLoggerProvider).debug(
          'Google Drive sign-in starting '
          'platform=${_oauthPlatformLabel()} '
          'useWebview=${GoogleOAuthRedirect.forPlatform().useWebview} '
          'needFileScope=$needFileScope',
        );
    try {
      final result = await integration.oauth.signIn(
        includeFileScope: needFileScope,
        scopeMode: needFileScope
            ? GoogleDriveOAuthScopeMode.share
            : GoogleDriveOAuthScopeMode.personal,
      );
      final refresh = result.tokens.refreshToken?.trim() ?? '';
      if (refresh.isEmpty) {
        _logError('Google Drive sign-in missing refresh token');
        return const GoogleDriveSyncResult.fail('missing_refresh_token');
      }
      _cachedTokens = result.tokens;
      _logDebug(
        'GDrive sign-in ok email=${result.email} '
        'scopes=${result.tokens.scope} '
        'refreshRotated=true',
      );
      await ref.read(appSettingsProvider.notifier).setGoogleDriveSync(
            enabled: true,
            accountEmail: result.email ?? '',
            refreshToken: refresh,
            syncPassphrase: passphrase.trim(),
            syncRole: kGoogleDriveSyncRoleOwner,
          );
      return syncNow(allowInteractiveReauth: true);
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
        _logDebug(
          'GDrive created shared sync file id=$sharedId '
          'size=${created.size}',
        );
      } else {
        await integration.drive.updateFileContent(
          accessToken: accessToken,
          fileId: sharedId,
          content: content,
        );
        _logDebug('GDrive updated shared sync file before share id=$sharedId');
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
            // Reset shared cursor so the next sync pulls any collaborator
            // writes instead of skipping on a stale personal-era timestamp.
            clearSharedLastSyncedAt: true,
          );

      // Verify the *refreshed* token (not just this session) can still see
      // the shared file — catches refresh tokens that stayed appdata-only.
      final storedRefresh =
          (ref.read(appSettingsProvider).value ?? settings)
              .googleDriveRefreshToken;
      try {
        final verified = await integration.oauth.refreshAccessToken(
          refreshToken: storedRefresh,
        );
        _cachedTokens = verified;
        _logDebug(
          'GDrive share verify refresh scopes=${verified.scope} '
          'allowsSharedFile=${googleOAuthScopeAllowsSharedFile(verified.scope)}',
        );
        final meta = await integration.drive.getFileMeta(
          accessToken: verified.accessToken,
          fileId: sharedId,
        );
        if (meta == null) {
          _logWarning(
            'GDrive share verify: refreshed token cannot read shared file '
            'id=$sharedId — next Sync now will prompt for drive.file',
          );
        } else {
          _logDebug(
            'GDrive share verify ok fileId=${meta.id} owner=${meta.ownerEmail}',
          );
        }
      } on DioException catch (e, st) {
        _logWarning(
          'GDrive share verify failed ${googleDriveDioDebugSummary(e)}',
          error: e,
          stackTrace: st,
        );
      }

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
      _logDebug(
        'GDrive using cached access token scopes=${cached.scope ?? '(unknown)'} '
        'expiresAt=${cached.expiresAt.toUtc().toIso8601String()}',
      );
      return cached.accessToken;
    }
    final integration = ref.read(googleDriveSyncIntegrationProvider);
    final tokens = await integration.oauth.refreshAccessToken(
      refreshToken: settings.googleDriveRefreshToken,
    );
    _cachedTokens = tokens;
    _logDebug(
      'GDrive token refreshed scopes=${tokens.scope ?? '(unknown)'} '
      'allowsSharedFile=${googleOAuthScopeAllowsSharedFile(tokens.scope)} '
      'expiresAt=${tokens.expiresAt.toUtc().toIso8601String()}',
    );
    return tokens.accessToken;
  }

  /// Ensures the access token can read the shared My Drive sync file.
  ///
  /// Owner personal sync only needs `drive.appdata`. The shared file lives in
  /// regular Drive and needs `drive.file`. After share, Google may not rotate
  /// the refresh token; a later refresh then yields appdata-only tokens and
  /// every shared fetch/push returns 404 — which previously looked like
  /// “sync ok” because personal still succeeded.
  Future<String> _ensureSharedFileAccess({
    required GoogleDriveRestClient drive,
    required String accessToken,
    required AppSettings settings,
    required String fileId,
    required bool allowInteractiveReauth,
  }) async {
    try {
      final meta = await drive.getFileMeta(
        accessToken: accessToken,
        fileId: fileId,
      );
      if (meta != null) {
        _logDebug(
          'GDrive shared file probe ok fileId=${meta.id} '
          'modified=${meta.modifiedTime?.toUtc().toIso8601String()} '
          'owner=${meta.ownerEmail} '
          'scopes=${_cachedTokens?.scope ?? '(unknown)'}',
        );
        return accessToken;
      }
      _logWarning(
        'GDrive shared file probe returned null fileId=$fileId '
        'scopes=${_cachedTokens?.scope ?? '(unknown)'}',
      );
    } on DioException catch (e) {
      _logWarning(
        'GDrive shared file probe failed fileId=$fileId '
        '${googleDriveDioDebugSummary(e)} '
        'scopes=${_cachedTokens?.scope ?? '(unknown)'} '
        'allowsSharedFile=${googleOAuthScopeAllowsSharedFile(_cachedTokens?.scope)}',
        error: e,
      );
      if (!googleDriveDioIsNotFoundOrForbidden(e)) rethrow;
    }

    if (!allowInteractiveReauth) {
      throw const GoogleDriveException('shared_file_inaccessible');
    }

    _logDebug(
      'GDrive upgrading OAuth to drive.file for shared fileId=$fileId',
    );
    final integration = ref.read(googleDriveSyncIntegrationProvider);
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
      _logDebug(
        'GDrive file-scope upgrade stored refresh scopes=${result.tokens.scope}',
      );
    } else {
      _logWarning(
        'GDrive file-scope upgrade returned no refresh token; '
        'scopes=${result.tokens.scope} — using session access token only',
      );
    }

    try {
      final meta = await drive.getFileMeta(
        accessToken: result.tokens.accessToken,
        fileId: fileId,
      );
      if (meta == null) {
        throw const GoogleDriveException('shared_file_inaccessible');
      }
      _logDebug(
        'GDrive shared file probe ok after upgrade fileId=${meta.id} '
        'owner=${meta.ownerEmail}',
      );
      return result.tokens.accessToken;
    } on DioException catch (e) {
      _logError(
        'GDrive shared file still inaccessible after upgrade '
        '${googleDriveDioDebugSummary(e)}',
        error: e,
      );
      throw const GoogleDriveException('shared_file_inaccessible');
    }
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

  Future<GoogleDriveSyncResult> syncNow({
    bool pushOnly = false,
    bool allowInteractiveReauth = true,
  }) async {
    state = state.copyWith(
      status: GoogleDriveSyncStatus.syncing,
      clearMessage: true,
      clearVersionInfo: true,
    );
    final result = await ref.read(googleDriveSyncEngineProvider).syncNow(
          pushOnly: pushOnly,
          allowInteractiveReauth: allowInteractiveReauth,
        );
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
