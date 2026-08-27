import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/features/export_expenses/model/export_controller.dart';
import 'package:valtero/features/export_expenses/model/export_destination.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings.dart';

bool isTelegramExportConfigured(AppSettings? settings) {
  if (settings == null) return false;
  return settings.telegramEnabled &&
      settings.telegramBotToken.trim().isNotEmpty &&
      settings.telegramChatId.trim().isNotEmpty;
}

/// share_plus has no usable file-share UI on Linux.
bool get isExportShareSupported =>
    Platform.isAndroid ||
    Platform.isIOS ||
    Platform.isWindows ||
    Platform.isMacOS;

Future<void> showExportUnsupportedDialog(
  BuildContext context,
  String message,
) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dismiss),
        ),
      ],
    ),
  );
}

Future<String?> runExportDestination(
  WidgetRef ref,
  BuildContext context, {
  required ExportFormat format,
  required ExportDestination destination,
}) async {
  final controller = ref.read(exportControllerProvider);
  final l10n = AppLocalizations.of(context)!;
  switch (destination) {
    case ExportDestination.save:
      final path = await controller.saveFile(format);
      return path == null ? null : l10n.exportDone;
    case ExportDestination.share:
      await controller.share(format);
      return l10n.exportDone;
    case ExportDestination.copy:
      await controller.copy(format);
      return l10n.copiedToClipboard;
    case ExportDestination.telegram:
      await controller.sendTelegram(format);
      return l10n.telegramSent;
  }
}
