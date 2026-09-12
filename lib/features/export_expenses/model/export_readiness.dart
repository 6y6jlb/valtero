import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/features/export_expenses/model/export_controller.dart';
import 'package:valtero/features/export_expenses/model/export_data_type.dart';
import 'package:valtero/features/export_expenses/model/export_destination.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_ok_button.dart';

/// share_plus has no usable file-share UI on Linux.
bool get isExportShareSupported =>
    Platform.isAndroid ||
    Platform.isIOS ||
    Platform.isWindows ||
    Platform.isMacOS;

Future<void> showExportUnsupportedDialog(BuildContext context, String message) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(message),
      actions: [AppOkButton(label: l10n.dismiss)],
    ),
  );
}

Future<String?> runExportDestination(
  WidgetRef ref,
  BuildContext context, {
  required ExportFormat format,
  required ExportDestination destination,
  ExportDataType dataType = ExportDataType.expenses,
}) async {
  final controller = ref.read(exportControllerProvider);
  final l10n = AppLocalizations.of(context)!;
  switch (destination) {
    case ExportDestination.save:
      final path = await switch (dataType) {
        ExportDataType.income => controller.saveIncomeFile(format),
        ExportDataType.cashFlow => controller.saveCashFlowFile(format),
        ExportDataType.expenses => controller.saveFile(format),
      };
      return path == null ? null : l10n.exportDone;
    case ExportDestination.share:
      await switch (dataType) {
        ExportDataType.income => controller.shareIncome(format),
        ExportDataType.cashFlow => controller.shareCashFlow(format),
        ExportDataType.expenses => controller.share(format),
      };
      return l10n.exportDone;
    case ExportDestination.copy:
      await switch (dataType) {
        ExportDataType.income => controller.copyIncome(format),
        ExportDataType.cashFlow => controller.copyCashFlow(format),
        ExportDataType.expenses => controller.copy(format),
      };
      return l10n.copiedToClipboard;
    case ExportDestination.telegram:
      await switch (dataType) {
        ExportDataType.income => controller.sendIncomeTelegram(format),
        ExportDataType.cashFlow => controller.sendCashFlowTelegram(format),
        ExportDataType.expenses => controller.sendTelegram(format),
      };
      return l10n.telegramSent;
  }
}
