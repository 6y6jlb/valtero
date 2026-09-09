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

/// Mirrors [ExpenseExporter] for [Income] rows.
class IncomeExporter {
  String buildCsv(
    List<Income> incomes,
    Map<int, String> tagNames,
    Map<int, List<int>> tagsByIncome, {
    Map<int, String> paymentNames = const {},
  }) {
    final rows = <List<dynamic>>[
      [
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
      for (final i in incomes)
        [
          i.id,
          i.occurredAt.toIso8601String(),
          Money.formatMinor(i.originalAmountMinor),
          i.originalCurrencyCode,
          Money.formatMinor(i.storedAmountMinor),
          i.storedCurrencyCode,
          i.rateUsed,
          i.paymentMethodId == null
              ? ''
              : (paymentNames[i.paymentMethodId!] ?? ''),
          i.countryCode ?? '',
          (tagsByIncome[i.id] ?? const [])
              .map((id) => tagNames[id] ?? '')
              .where((n) => n.isNotEmpty)
              .join('|'),
          i.note ?? '',
        ],
    ];
    return csv.encode(rows);
  }

  String buildJson(
    List<Income> incomes,
    Map<int, String> tagNames,
    Map<int, List<int>> tagsByIncome, {
    Map<int, String> paymentNames = const {},
  }) {
    final list = incomes
        .map(
          (i) => {
            'id': i.id,
            'occurredAt': i.occurredAt.toIso8601String(),
            'originalAmount': Money.formatMinor(i.originalAmountMinor),
            'originalCurrency': i.originalCurrencyCode,
            'storedAmount': Money.formatMinor(i.storedAmountMinor),
            'storedCurrency': i.storedCurrencyCode,
            'rateUsed': i.rateUsed,
            'paymentMethod': i.paymentMethodId == null
                ? null
                : paymentNames[i.paymentMethodId!],
            'countryCode': i.countryCode,
            'tags': (tagsByIncome[i.id] ?? const [])
                .map((id) => tagNames[id])
                .whereType<String>()
                .toList(),
            'note': i.note,
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
        'valtero_income_export_${DateTime.now().millisecondsSinceEpoch}.${format == ExportFormat.csv ? 'csv' : 'json'}';
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
      suggestedName: 'valtero_income_export.$ext',
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
