import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:valtero/features/export_expenses/model/export_readiness.dart';
import 'package:valtero/shared/consts/developer_contact.dart';
import 'package:valtero/shared/logging/logging_providers.dart';

/// How [DebugLogsController.shareOrCopyLogs] delivered the log.
enum DebugLogsShareResult {
  shared,
  emailed,
  emailFallback,
  copied,
}

class DebugLogsController {
  final Ref ref;

  DebugLogsController(this.ref);

  Future<String> readLogs() {
    return ref.read(appLoggerProvider).readAll();
  }

  Future<void> clearLogs() {
    return ref.read(appLoggerProvider).clear();
  }

  /// Shares / emails the log file when the platform allows it.
  ///
  /// - Android/iOS/Windows/macOS: system share sheet with the `.log` file.
  /// - Linux: `xdg-email --attach` to [DeveloperContact.email]; if that fails,
  ///   copies the file path and opens a mailto with a short body.
  /// - Last resort: copies log text to the clipboard.
  Future<DebugLogsShareResult?> shareOrCopyLogs() async {
    final logger = ref.read(appLoggerProvider);
    final content = await logger.readAllForExport();
    if (content.trim().isEmpty) return null;

    final exportFile = await _writeExportFile(content);

    if (isExportShareSupported) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(exportFile.path)],
          text:
              'Valtero debug log — please send to ${DeveloperContact.email}',
          subject: 'Valtero debug log',
        ),
      );
      return DebugLogsShareResult.shared;
    }

    if (Platform.isLinux) {
      final emailed = await _tryXdgEmailWithAttachment(exportFile.path);
      if (emailed) return DebugLogsShareResult.emailed;

      await Clipboard.setData(ClipboardData(text: exportFile.path));
      final subject = Uri.encodeComponent('Valtero debug log');
      final body = Uri.encodeComponent(
        'Please attach this log file:\n${exportFile.path}\n\n'
        '(Path also copied to the clipboard.)',
      );
      final mailto = Uri.parse(
        'mailto:${DeveloperContact.email}?subject=$subject&body=$body',
      );
      try {
        await launchUrl(mailto, mode: LaunchMode.externalApplication);
      } catch (_) {
        // Path is already on the clipboard.
      }
      return DebugLogsShareResult.emailFallback;
    }

    await Clipboard.setData(ClipboardData(text: content));
    return DebugLogsShareResult.copied;
  }

  Future<void> copyLogs() async {
    final content = await ref.read(appLoggerProvider).readAllForExport();
    await Clipboard.setData(ClipboardData(text: content));
  }

  Future<File> _writeExportFile(String content) async {
    final dir = await getTemporaryDirectory();
    final stamp =
        DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
    final exportFile = File(p.join(dir.path, 'valtero-app-$stamp.log'));
    await exportFile.writeAsString(content, flush: true);
    return exportFile;
  }

  /// Opens the desktop mailer with the log file attached (xdg-utils).
  Future<bool> _tryXdgEmailWithAttachment(String filePath) async {
    try {
      final result = await Process.run('xdg-email', [
        '--attach',
        filePath,
        '--subject',
        'Valtero debug log',
        '--body',
        'Debug log from Valtero is attached.',
        DeveloperContact.email,
      ]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}

final debugLogsControllerProvider = Provider<DebugLogsController>((ref) {
  return DebugLogsController(ref);
});
