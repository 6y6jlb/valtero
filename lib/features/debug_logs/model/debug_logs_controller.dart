import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:valtero/shared/consts/developer_contact.dart';
import 'package:valtero/shared/logging/logging_providers.dart';
import 'package:valtero/shared/utils/share_platform.dart';

/// How a debug-log delivery action finished.
enum DebugLogsShareResult {
  /// System share sheet (any destination the user picks).
  shared,

  /// Mail client opened with the developer address and log attached.
  emailed,

  /// Mailto opened / path copied when attaching was not possible.
  emailFallback,

  /// Log text copied to the clipboard.
  copied,
}

const _emailChannel = MethodChannel('com.valtero.valtero/email');

class DebugLogsController {
  final Ref ref;

  DebugLogsController(this.ref);

  Future<String> readLogs() {
    return ref.read(appLoggerProvider).readAll();
  }

  Future<void> clearLogs() {
    return ref.read(appLoggerProvider).clear();
  }

  /// Opens the system share sheet with the `.log` file (any recipient).
  ///
  /// On Linux (no share UI) copies log text to the clipboard.
  Future<DebugLogsShareResult?> shareLogs() async {
    final content = await ref.read(appLoggerProvider).readAllForExport();
    if (content.trim().isEmpty) return null;

    final exportFile = await _writeExportFile(content);

    if (isFileShareSupported) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(exportFile.path)],
          text: 'Valtero debug log',
          subject: 'Valtero debug log',
        ),
      );
      return DebugLogsShareResult.shared;
    }

    await Clipboard.setData(ClipboardData(text: content));
    return DebugLogsShareResult.copied;
  }

  /// Opens email to [DeveloperContact.email] with the log file attached when
  /// the platform allows it.
  ///
  /// - Android: email Intent (`message/rfc822`) with attachment.
  /// - Linux: `xdg-email --attach`.
  /// - Otherwise: mailto + path copied (user attaches manually).
  Future<DebugLogsShareResult?> emailLogsToDeveloper() async {
    final content = await ref.read(appLoggerProvider).readAllForExport();
    if (content.trim().isEmpty) return null;

    final exportFile = await _writeExportFile(content);

    if (Platform.isAndroid) {
      final emailed = await _tryAndroidEmailWithAttachment(exportFile.path);
      if (emailed) return DebugLogsShareResult.emailed;
      return _mailtoWithPathFallback(exportFile.path);
    }

    if (Platform.isLinux) {
      final emailed = await _tryXdgEmailWithAttachment(exportFile.path);
      if (emailed) return DebugLogsShareResult.emailed;
      return _mailtoWithPathFallback(exportFile.path);
    }

    if (Platform.isMacOS) {
      final emailed = await _tryMacOsMailWithAttachment(exportFile.path);
      if (emailed) return DebugLogsShareResult.emailed;
    }

    return _mailtoWithPathFallback(exportFile.path);
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

  Future<bool> _tryAndroidEmailWithAttachment(String filePath) async {
    try {
      final ok = await _emailChannel.invokeMethod<bool>(
        'sendEmailWithAttachment',
        {
          'to': DeveloperContact.email,
          'subject': 'Valtero debug log',
          'body': 'Debug log from Valtero is attached.',
          'filePath': filePath,
        },
      );
      return ok == true;
    } catch (_) {
      return false;
    }
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

  /// Compose in Apple Mail with attachment (best-effort).
  Future<bool> _tryMacOsMailWithAttachment(String filePath) async {
    final escapedPath = filePath.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
    final script = '''
tell application "Mail"
  set newMessage to make new outgoing message with properties {subject:"Valtero debug log", content:"Debug log from Valtero is attached." & return & return, visible:true}
  tell newMessage
    make new to recipient at end of to recipients with properties {address:"${DeveloperContact.email}"}
    try
      make new attachment with properties {file name:POSIX file "$escapedPath"} at after the last paragraph
    end try
  end tell
  activate
end tell
''';
    try {
      final result = await Process.run('osascript', ['-e', script]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  Future<DebugLogsShareResult> _mailtoWithPathFallback(String filePath) async {
    await Clipboard.setData(ClipboardData(text: filePath));
    final subject = Uri.encodeComponent('Valtero debug log');
    final body = Uri.encodeComponent(
      'Please attach this log file:\n$filePath\n\n'
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
}

final debugLogsControllerProvider = Provider<DebugLogsController>((ref) {
  return DebugLogsController(ref);
});
