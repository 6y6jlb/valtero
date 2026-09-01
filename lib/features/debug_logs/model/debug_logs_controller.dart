import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:valtero/features/export_expenses/model/export_readiness.dart';
import 'package:valtero/shared/consts/developer_contact.dart';
import 'package:valtero/shared/logging/logging_providers.dart';

class DebugLogsController {
  final Ref ref;

  DebugLogsController(this.ref);

  Future<String> readLogs() {
    return ref.read(appLoggerProvider).readAll();
  }

  Future<void> clearLogs() {
    return ref.read(appLoggerProvider).clear();
  }

  /// Shares the log file via system sheet when supported; otherwise copies text.
  /// Returns `'shared'`, `'copied'`, or `null` if empty / cancelled.
  Future<String?> shareOrCopyLogs() async {
    final logger = ref.read(appLoggerProvider);
    final content = await logger.readAll();
    if (content.trim().isEmpty) return null;

    if (isExportShareSupported) {
      final file = logger.logFile;
      if (file != null && await file.exists()) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text:
                'Valtero debug log — please send to ${DeveloperContact.email}',
          ),
        );
        return 'shared';
      }
    }

    await Clipboard.setData(ClipboardData(text: content));
    return 'copied';
  }

  Future<void> copyLogs() async {
    final content = await readLogs();
    await Clipboard.setData(ClipboardData(text: content));
  }
}

final debugLogsControllerProvider = Provider<DebugLogsController>((ref) {
  return DebugLogsController(ref);
});
