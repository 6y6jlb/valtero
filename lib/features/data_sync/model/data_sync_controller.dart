import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:valtero/features/data_sync/model/backup_crypto.dart';
import 'package:valtero/features/data_sync/model/backup_format.dart';
import 'package:valtero/features/data_sync/model/backup_importer.dart';
import 'package:valtero/features/data_sync/model/backup_snapshot.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_version_provider.dart';

final backupCryptoProvider = Provider<BackupCrypto>((ref) => BackupCrypto());

final backupSnapshotBuilderProvider =
    Provider<BackupSnapshotBuilder>((ref) => BackupSnapshotBuilder());

final backupImporterProvider =
    Provider<BackupImporter>((ref) => BackupImporter());

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

  Future<String?> exportToSaveDialog({required String passphrase}) async {
    final envelope = await buildEnvelope();
    final content = await encryptEnvelopeToJson(
      envelope: envelope,
      passphrase: passphrase,
    );
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
    final dir = await getTemporaryDirectory();
    final name =
        'valtero_backup_${DateTime.now().millisecondsSinceEpoch}.$kBackupFileExtension';
    final file = File(p.join(dir.path, name));
    await file.writeAsString(content);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)]),
    );
  }

  Future<String?> pickBackupFilePath() async {
    final file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'Backup',
          extensions: [kBackupFileExtension, 'json'],
        ),
      ],
    );
    return file?.path;
  }

  Future<ImportReport> importFromPath({
    required String path,
    required String passphrase,
    required bool applySettings,
  }) async {
    final content = await File(path).readAsString();
    final envelope = await decryptFileContent(
      fileContent: content,
      passphrase: passphrase,
    );
    final settings = ref.read(appSettingsProvider).value;
    if (settings == null) throw StateError('no_settings');
    final report = await ref.read(backupImporterProvider).importEnvelope(
          db: ref.read(appDatabaseProvider),
          envelope: envelope,
          currentSettings: settings,
          applySettings: applySettings,
          saveSettings: (updated) =>
              ref.read(appSettingsProvider.notifier).updateSettings(updated),
        );
    // Nudge providers that read streams / async settings.
    ref.invalidate(appSettingsProvider);
    return report;
  }
}

final dataSyncControllerProvider = Provider<DataSyncController>((ref) {
  return DataSyncController(ref);
});
