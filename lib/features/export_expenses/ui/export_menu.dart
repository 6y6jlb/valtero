import 'package:flutter/material.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/features/export_expenses/model/export_destination.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

typedef ExportMenuSelection = ({
  ExportFormat format,
  ExportDestination destination,
});

String exportMenuValue(ExportFormat format, ExportDestination destination) {
  final formatKey = format == ExportFormat.csv ? 'csv' : 'json';
  return '${formatKey}_${destination.name}';
}

ExportMenuSelection? parseExportMenuValue(String value) {
  final parts = value.split('_');
  if (parts.length != 2) return null;
  final format = switch (parts[0]) {
    'csv' => ExportFormat.csv,
    'json' => ExportFormat.json,
    _ => null,
  };
  final destination = ExportDestination.values
      .where((d) => d.name == parts[1])
      .firstOrNull;
  if (format == null || destination == null) return null;
  return (format: format, destination: destination);
}

List<PopupMenuEntry<String>> buildExportMenuItems(
  AppLocalizations l10n, {
  bool showShare = true,
}) {
  PopupMenuItem<String> item({
    required ExportFormat format,
    required ExportDestination destination,
    required String label,
  }) {
    return PopupMenuItem(
      value: exportMenuValue(format, destination),
      child: Text(label),
    );
  }

  String formatLabel(ExportFormat format) =>
      format == ExportFormat.csv ? l10n.exportCsv : l10n.exportJson;

  return [
    for (final format in ExportFormat.values) ...[
      item(
        format: format,
        destination: ExportDestination.save,
        label: '${formatLabel(format)} · ${l10n.saveFile}',
      ),
      if (showShare)
        item(
          format: format,
          destination: ExportDestination.share,
          label: '${formatLabel(format)} · ${l10n.share}',
        ),
      item(
        format: format,
        destination: ExportDestination.copy,
        label: '${l10n.copyAs} ${formatLabel(format)}',
      ),
      item(
        format: format,
        destination: ExportDestination.telegram,
        label: '${formatLabel(format)} · ${l10n.sendTelegram}',
      ),
    ],
  ];
}
