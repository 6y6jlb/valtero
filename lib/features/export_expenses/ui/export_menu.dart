import 'package:flutter/material.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/features/export_expenses/model/export_data_type.dart';
import 'package:valtero/features/export_expenses/model/export_destination.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

typedef ExportMenuSelection = ({
  ExportFormat format,
  ExportDestination destination,
  ExportDataType dataType,
});

String exportMenuValue(
  ExportFormat format,
  ExportDestination destination, [
  ExportDataType dataType = ExportDataType.expenses,
]) {
  final typeKey = switch (dataType) {
    ExportDataType.income => 'income',
    ExportDataType.cashFlow => 'cashFlow',
    ExportDataType.expenses => 'expenses',
  };
  final formatKey = format == ExportFormat.csv ? 'csv' : 'json';
  return '${typeKey}_${formatKey}_${destination.name}';
}

ExportMenuSelection? parseExportMenuValue(String value) {
  final parts = value.split('_');
  if (parts.length != 3) return null;
  final dataType = switch (parts[0]) {
    'income' => ExportDataType.income,
    'cashFlow' => ExportDataType.cashFlow,
    'expenses' => ExportDataType.expenses,
    _ => null,
  };
  final format = switch (parts[1]) {
    'csv' => ExportFormat.csv,
    'json' => ExportFormat.json,
    _ => null,
  };
  final destination = ExportDestination.values
      .where((d) => d.name == parts[2])
      .firstOrNull;
  if (dataType == null || format == null || destination == null) return null;
  return (format: format, destination: destination, dataType: dataType);
}

/// [showIncome] adds income export entries, [showCashFlow] the merged
/// expenses + income document. [showExpenses] defaults to true; pass false on
/// the income / cash-flow lists so the menu only offers their own exports.
List<PopupMenuEntry<String>> buildExportMenuItems(
  AppLocalizations l10n, {
  bool showShare = true,
  bool showTelegram = false,
  bool showIncome = false,
  bool showExpenses = true,
  bool showCashFlow = false,
}) {
  PopupMenuItem<String> item({
    required ExportFormat format,
    required ExportDestination destination,
    required String label,
    ExportDataType dataType = ExportDataType.expenses,
  }) {
    return PopupMenuItem(
      value: exportMenuValue(format, destination, dataType),
      child: Text(label),
    );
  }

  String formatLabel(ExportFormat format) =>
      format == ExportFormat.csv ? l10n.exportCsv : l10n.exportJson;

  final shownTypes = [
    if (showExpenses) ExportDataType.expenses,
    if (showIncome) ExportDataType.income,
    if (showCashFlow) ExportDataType.cashFlow,
  ];

  List<PopupMenuEntry<String>> itemsFor(ExportDataType dataType) {
    final prefix = shownTypes.length < 2
        ? ''
        : switch (dataType) {
            ExportDataType.expenses => '${l10n.directionExpenses} · ',
            ExportDataType.income => '${l10n.income} · ',
            ExportDataType.cashFlow => '${l10n.directionCashFlow} · ',
          };
    return [
      for (final format in ExportFormat.values) ...[
        item(
          format: format,
          destination: ExportDestination.save,
          dataType: dataType,
          label: '$prefix${formatLabel(format)} · ${l10n.saveFile}',
        ),
        if (showShare)
          item(
            format: format,
            destination: ExportDestination.share,
            dataType: dataType,
            label: '$prefix${formatLabel(format)} · ${l10n.share}',
          ),
        item(
          format: format,
          destination: ExportDestination.copy,
          dataType: dataType,
          label: '$prefix${l10n.copyAs} ${formatLabel(format)}',
        ),
        if (showTelegram)
          item(
            format: format,
            destination: ExportDestination.telegram,
            dataType: dataType,
            label: '$prefix${formatLabel(format)} · ${l10n.sendTelegram}',
          ),
      ],
    ];
  }

  return [for (final dataType in shownTypes) ...itemsFor(dataType)];
}
