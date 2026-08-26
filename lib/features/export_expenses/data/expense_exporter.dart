import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/settings/app_settings.dart';
import 'package:valtero/shared/utils/money.dart';

enum ExportFormat { csv, json }

class ExpenseExporter {
  String buildCsv(List<Expense> expenses, Map<int, String> tagNames) {
    final rows = <List<dynamic>>[
      [
        'id',
        'occurredAt',
        'originalAmount',
        'originalCurrency',
        'storedAmount',
        'storedCurrency',
        'rateUsed',
        'tag',
        'note',
      ],
      for (final e in expenses)
        [
          e.id,
          e.occurredAt.toIso8601String(),
          Money.formatMinor(e.originalAmountMinor),
          e.originalCurrencyCode,
          Money.formatMinor(e.storedAmountMinor),
          e.storedCurrencyCode,
          e.rateUsed,
          e.tagId == null ? '' : (tagNames[e.tagId!] ?? ''),
          e.note ?? '',
        ],
    ];
    return const ListToCsvConverter().convert(rows);
  }

  String buildJson(List<Expense> expenses, Map<int, String> tagNames) {
    final list = expenses
        .map(
          (e) => {
            'id': e.id,
            'occurredAt': e.occurredAt.toIso8601String(),
            'originalAmount': Money.formatMinor(e.originalAmountMinor),
            'originalCurrency': e.originalCurrencyCode,
            'storedAmount': Money.formatMinor(e.storedAmountMinor),
            'storedCurrency': e.storedCurrencyCode,
            'rateUsed': e.rateUsed,
            'tag': e.tagId == null ? null : tagNames[e.tagId!],
            'note': e.note,
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
        'valtero_export_${DateTime.now().millisecondsSinceEpoch}.${format == ExportFormat.csv ? 'csv' : 'json'}';
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
      suggestedName: 'valtero_export.$ext',
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

  Future<void> sendTelegram({
    required Dio dio,
    required AppSettings settings,
    required File file,
  }) async {
    if (!settings.telegramEnabled ||
        settings.telegramBotToken.trim().isEmpty ||
        settings.telegramChatId.trim().isEmpty) {
      throw StateError('telegram_not_configured');
    }
    final token = settings.telegramBotToken.trim();
    final form = FormData.fromMap({
      'chat_id': settings.telegramChatId.trim(),
      'document': await MultipartFile.fromFile(
        file.path,
        filename: p.basename(file.path),
      ),
    });
    await dio.post(
      'https://api.telegram.org/bot$token/sendDocument',
      data: form,
    );
  }
}
