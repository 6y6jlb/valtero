import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart'
    show ExportFormat;
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/money.dart';

/// One row of the merged cash-flow export: the operation plus its direction
/// and category tag ids (expense and income tag ids share a namespace but are
/// resolved against the same name map).
typedef CashFlowExportRow = ({
  Operation operation,
  bool isIncome,
  List<int> tagIds,
});

/// Merged expenses + income export. Unlike [ExpenseExporter] / `IncomeExporter`
/// this writes a single document with a leading `type` column so one file
/// carries the whole cash flow.
class CashFlowExporter {
  static const String expenseType = 'expense';
  static const String incomeType = 'income';

  String buildCsv(
    List<CashFlowExportRow> rows,
    Map<int, String> tagNames, {
    Map<int, String> paymentNames = const {},
  }) {
    final csvRows = <List<dynamic>>[
      [
        'type',
        'id',
        'occurredAt',
        'originalAmount',
        'originalCurrency',
        'storedAmount',
        'storedCurrency',
        'rateUsed',
        'paymentMethod',
        'countryCode',
        'tags',
        'note',
      ],
      for (final row in rows)
        [
          row.isIncome ? incomeType : expenseType,
          row.operation.id,
          row.operation.occurredAt.toIso8601String(),
          Money.formatMinor(row.operation.originalAmountMinor),
          row.operation.originalCurrencyCode,
          Money.formatMinor(row.operation.storedAmountMinor),
          row.operation.storedCurrencyCode,
          row.operation.rateUsed,
          row.operation.paymentMethodId == null
              ? ''
              : (paymentNames[row.operation.paymentMethodId!] ?? ''),
          row.operation.countryCode ?? '',
          row.tagIds
              .map((id) => tagNames[id] ?? '')
              .where((n) => n.isNotEmpty)
              .join('|'),
          row.operation.note ?? '',
        ],
    ];
    return csv.encode(csvRows);
  }

  String buildJson(
    List<CashFlowExportRow> rows,
    Map<int, String> tagNames, {
    Map<int, String> paymentNames = const {},
  }) {
    final list = rows
        .map(
          (row) => {
            'type': row.isIncome ? incomeType : expenseType,
            'id': row.operation.id,
            'occurredAt': row.operation.occurredAt.toIso8601String(),
            'originalAmount':
                Money.formatMinor(row.operation.originalAmountMinor),
            'originalCurrency': row.operation.originalCurrencyCode,
            'storedAmount': Money.formatMinor(row.operation.storedAmountMinor),
            'storedCurrency': row.operation.storedCurrencyCode,
            'rateUsed': row.operation.rateUsed,
            'paymentMethod': row.operation.paymentMethodId == null
                ? null
                : paymentNames[row.operation.paymentMethodId!],
            'countryCode': row.operation.countryCode,
            'tags':
                row.tagIds.map((id) => tagNames[id]).whereType<String>().toList(),
            'note': row.operation.note,
          },
        )
        .toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }

  Future<File> writeTempFile({
    required String content,
    required ExportFormat format,
  }) async {
    final dir = await getTemporaryDirectory();
    final name =
        'valtero_cash_flow_export_${DateTime.now().millisecondsSinceEpoch}.${format == ExportFormat.csv ? 'csv' : 'json'}';
    final file = File(p.join(dir.path, name));
    await file.writeAsString(content);
    return file;
  }

  Future<String?> saveWithDialog({
    required String content,
    required ExportFormat format,
  }) async {
    final ext = format == ExportFormat.csv ? 'csv' : 'json';
    final path = await getSaveLocation(
      suggestedName: 'valtero_cash_flow_export.$ext',
      acceptedTypeGroups: [
        XTypeGroup(label: ext.toUpperCase(), extensions: [ext]),
      ],
    );
    if (path == null) return null;
    final file = File(path.path);
    await file.writeAsString(content);
    return file.path;
  }

  Future<void> shareFile(File file) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'Valtero export'),
    );
  }
}
