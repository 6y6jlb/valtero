import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:valtero/entities/expense/model/duplicate_matcher.dart';
import 'package:valtero/features/data_sync/model/backup_crypto.dart';
import 'package:valtero/features/data_sync/model/backup_format.dart';
import 'package:valtero/features/data_sync/model/backup_importer.dart';
import 'package:valtero/features/data_sync/model/backup_snapshot.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_version_provider.dart';

final backupCryptoProvider = Provider<BackupCrypto>((ref) => BackupCrypto());

final backupSnapshotBuilderProvider =
    Provider<BackupSnapshotBuilder>((ref) => BackupSnapshotBuilder());

final backupImporterProvider =
    Provider<BackupImporter>((ref) => BackupImporter());

/// One incoming backup expense that matches one or more local expenses.
class ImportConflict {
  final BackupExpenseData incoming;
  final List<Expense> existingMatches;

  const ImportConflict({
    required this.incoming,
    required this.existingMatches,
  });
}

class DataSyncController {
  final Ref ref;

  DataSyncController(this.ref);

  Future<BackupEnvelope> buildEnvelope() async {
    final settings = ref.read(appSettingsProvider).value;
    if (settings == null) throw StateError('no_settings');
    final versionLabel = ref.read(appVersionLabelProvider);
    final appVersion = versionLabel == null
        ? null
        : versionLabel.startsWith('v')
            ? versionLabel.substring(1)
            : versionLabel;
    return ref.read(backupSnapshotBuilderProvider).build(
          db: ref.read(appDatabaseProvider),
          settings: settings,
          appVersion: appVersion,
        );
  }

  Future<String> encryptEnvelopeToJson({
    required BackupEnvelope envelope,
    required String passphrase,
  }) async {
    final clear = utf8.encode(envelope.encode());
    final encrypted = await ref.read(backupCryptoProvider).encryptBytes(
          clearBytes: clear,
          passphrase: passphrase,
        );
    return BackupOuterFile.fromEncrypted(encrypted).encode();
  }

  Future<BackupEnvelope> decryptFileContent({
    required String fileContent,
    required String passphrase,
  }) async {
    final outer = BackupOuterFile.parse(fileContent);
    validateOuterForImport(outer);
    final clearBytes = await ref.read(backupCryptoProvider).decryptBytes(
          salt: decodeBase64(outer.saltBase64),
          nonce: decodeBase64(outer.nonceBase64),
          ciphertext: decodeBase64(outer.ciphertextBase64),
          passphrase: passphrase,
        );
    final envelope = BackupEnvelope.parse(utf8.decode(clearBytes));
    envelope.validateForImport();
    return envelope;
  }

  /// Writes encrypted backup bytes to a uniquely named temp file.
  Future<File> _writeTempBackupFile(String content) async {
    final dir = await getTemporaryDirectory();
    final name =
        'valtero_backup_${DateTime.now().millisecondsSinceEpoch}.$kBackupFileExtension';
    final file = File(p.join(dir.path, name));
    await file.writeAsString(content);
    return file;
  }

  /// Desktop: native save dialog. Android/iOS: write temp + system share
  /// (Save to Files / Downloads), since [getSaveLocation] is unsupported.
  Future<String?> exportToSaveDialog({required String passphrase}) async {
    final envelope = await buildEnvelope();
    final content = await encryptEnvelopeToJson(
      envelope: envelope,
      passphrase: passphrase,
    );

    if (Platform.isAndroid || Platform.isIOS) {
      final file = await _writeTempBackupFile(content);
      final shared = await shareBackupFile(file.path);
      // Dismissed share sheet — treat as cancel (no success toast / path).
      if (!shared) return null;
      return file.path;
    }

    final path = await getSaveLocation(
      suggestedName: 'valtero_backup.$kBackupFileExtension',
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'Backup',
          extensions: [kBackupFileExtension],
        ),
      ],
    );
    if (path == null) return null;
    final file = File(path.path);
    await file.writeAsString(content);
    return file.path;
  }

  Future<void> exportShare({required String passphrase}) async {
    final envelope = await buildEnvelope();
    final content = await encryptEnvelopeToJson(
      envelope: envelope,
      passphrase: passphrase,
    );
    final file = await _writeTempBackupFile(content);
    await shareBackupFile(file.path);
  }

  /// Returns `false` when the platform reports the share sheet was dismissed.
  Future<bool> shareBackupFile(String path) async {
    final result = await SharePlus.instance.share(
      ShareParams(files: [XFile(path)]),
    );
    return result.status != ShareResultStatus.dismissed;
  }

  Future<String?> pickBackupFilePath() async {
    final file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'Backup',
          extensions: [kBackupFileExtension, 'json'],
          // Android maps extensions via MimeTypeMap; `.valterobackup` is
          // unknown there, so without an explicit mime the picker greys out
          // the file. `*/*` lets the user select it; format is validated later.
          mimeTypes: ['*/*'],
        ),
      ],
    );
    return file?.path;
  }

  Future<BackupEnvelope> decryptFromPath({
    required String path,
    required String passphrase,
  }) async {
    final content = await File(path).readAsString();
    return decryptFileContent(
      fileContent: content,
      passphrase: passphrase,
    );
  }

  Future<List<ImportConflict>> findDuplicateConflicts(
    BackupEnvelope envelope,
  ) async {
    final local = await ref.read(appDatabaseProvider).getAllExpenses();
    final indexed = indexByFingerprint(local);
    final conflicts = <ImportConflict>[];
    for (final expense in envelope.data.expenses) {
      final key = fingerprintOf(
        occurredAt: expense.occurredAt,
        originalAmountMinor: expense.originalAmountMinor,
        originalCurrencyCode: expense.originalCurrencyCode,
      );
      final matches = indexed[key];
      if (matches == null || matches.isEmpty) continue;
      conflicts.add(
        ImportConflict(incoming: expense, existingMatches: matches),
      );
    }
    return conflicts;
  }

  Future<ImportReport> applyImport({
    required BackupEnvelope envelope,
    required bool applySettings,
    Set<String> skipClientIds = const {},
    Set<String> markUniqueClientIds = const {},
  }) async {
    final settings = ref.read(appSettingsProvider).value;
    if (settings == null) throw StateError('no_settings');
    final report = await ref.read(backupImporterProvider).importEnvelope(
          db: ref.read(appDatabaseProvider),
          envelope: envelope,
          currentSettings: settings,
          applySettings: applySettings,
          skipClientIds: skipClientIds,
          forceUniqueClientIds: markUniqueClientIds,
          saveSettings: (updated) =>
              ref.read(appSettingsProvider.notifier).updateSettings(updated),
        );
    ref.invalidate(appSettingsProvider);
    return report;
  }

  Future<ImportReport> importFromPath({
    required String path,
    required String passphrase,
    required bool applySettings,
    Set<String> skipClientIds = const {},
    Set<String> markUniqueClientIds = const {},
  }) async {
    final envelope = await decryptFromPath(
      path: path,
      passphrase: passphrase,
    );
    return applyImport(
      envelope: envelope,
      applySettings: applySettings,
      skipClientIds: skipClientIds,
      markUniqueClientIds: markUniqueClientIds,
    );
  }
}

final dataSyncControllerProvider = Provider<DataSyncController>((ref) {
  return DataSyncController(ref);
});
