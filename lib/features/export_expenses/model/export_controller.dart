import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/income/model/income_provider.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/entities/payment_method/model/payment_methods_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/export_expenses/data/cash_flow_exporter.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/features/export_expenses/data/income_exporter.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/logging/logging_providers.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

final expenseExporterProvider = Provider<ExpenseExporter>((ref) {
  return ExpenseExporter();
});

final incomeExporterProvider = Provider<IncomeExporter>((ref) {
  return IncomeExporter();
});

final cashFlowExporterProvider = Provider<CashFlowExporter>((ref) {
  return CashFlowExporter();
});

class ExportController {
  final Ref ref;

  ExportController(this.ref);

  Future<String> buildContent(ExportFormat format) async {
    final expenses = ref.read(allExpensesProvider).value ?? const [];
    final tags = ref.read(tagsStreamProvider).value ?? const [];
    final methods = ref.read(paymentMethodsStreamProvider).value ?? const [];
    final tagNames = {for (final t in tags) t.id: t.name};
    final paymentNames = {for (final m in methods) m.id: m.name};
    final tagsByExpense = await ref
        .read(appDatabaseProvider)
        .getTagIdsByExpenseIds(expenses.map((e) => e.id).toList());
    return buildContentFor(
      format,
      expenses: expenses,
      tagNames: tagNames,
      tagsByExpense: tagsByExpense,
      paymentNames: paymentNames,
    );
  }

  String buildContentFor(
    ExportFormat format, {
    required List<Expense> expenses,
    required Map<int, String> tagNames,
    required Map<int, List<int>> tagsByExpense,
    Map<int, String> paymentNames = const {},
  }) {
    final exporter = ref.read(expenseExporterProvider);
    return format == ExportFormat.csv
        ? exporter.buildCsv(
            expenses,
            tagNames,
            tagsByExpense,
            paymentNames: paymentNames,
          )
        : exporter.buildJson(
            expenses,
            tagNames,
            tagsByExpense,
            paymentNames: paymentNames,
          );
  }

  Future<String?> saveFile(ExportFormat format) async {
    final content = await buildContent(format);
    return ref.read(expenseExporterProvider).saveWithDialog(
          content: content,
          format: format,
        );
  }

  Future<String?> saveFileFor(
    ExportFormat format, {
    required List<Expense> expenses,
    required Map<int, String> tagNames,
    required Map<int, List<int>> tagsByExpense,
    Map<int, String> paymentNames = const {},
  }) {
    final content = buildContentFor(
      format,
      expenses: expenses,
      tagNames: tagNames,
      tagsByExpense: tagsByExpense,
      paymentNames: paymentNames,
    );
    return ref.read(expenseExporterProvider).saveWithDialog(
          content: content,
          format: format,
        );
  }

  Future<void> share(ExportFormat format) async {
    final content = await buildContent(format);
    final file = await ref.read(expenseExporterProvider).writeTempFile(
          content: content,
          format: format,
        );
    await ref.read(expenseExporterProvider).shareFile(file);
  }

  Future<void> shareFor(
    ExportFormat format, {
    required List<Expense> expenses,
    required Map<int, String> tagNames,
    required Map<int, List<int>> tagsByExpense,
    Map<int, String> paymentNames = const {},
  }) async {
    final content = buildContentFor(
      format,
      expenses: expenses,
      tagNames: tagNames,
      tagsByExpense: tagsByExpense,
      paymentNames: paymentNames,
    );
    final file = await ref.read(expenseExporterProvider).writeTempFile(
          content: content,
          format: format,
        );
    await ref.read(expenseExporterProvider).shareFile(file);
  }

  Future<void> copy(ExportFormat format) async {
    final content = await buildContent(format);
    await Clipboard.setData(ClipboardData(text: content));
  }

  Future<void> copyFor(
    ExportFormat format, {
    required List<Expense> expenses,
    required Map<int, String> tagNames,
    required Map<int, List<int>> tagsByExpense,
    Map<int, String> paymentNames = const {},
  }) async {
    final content = buildContentFor(
      format,
      expenses: expenses,
      tagNames: tagNames,
      tagsByExpense: tagsByExpense,
      paymentNames: paymentNames,
    );
    await Clipboard.setData(ClipboardData(text: content));
  }

  Future<void> sendTelegram(ExportFormat format) async {
    final content = await buildContent(format);
    await _sendTelegramContent(content: content, format: format);
  }

  Future<void> sendTelegramFor(
    ExportFormat format, {
    required List<Expense> expenses,
    required Map<int, String> tagNames,
    required Map<int, List<int>> tagsByExpense,
    Map<int, String> paymentNames = const {},
  }) async {
    final content = buildContentFor(
      format,
      expenses: expenses,
      tagNames: tagNames,
      tagsByExpense: tagsByExpense,
      paymentNames: paymentNames,
    );
    await _sendTelegramContent(content: content, format: format);
  }

  Future<void> _sendTelegramContent({
    required String content,
    required ExportFormat format,
  }) async {
    final file = await ref.read(expenseExporterProvider).writeTempFile(
          content: content,
          format: format,
        );
    await _sendTelegramFile(file, format: format);
  }

  Future<void> _sendTelegramFile(
    File file, {
    required ExportFormat format,
  }) async {
    final settings = ref.read(appSettingsProvider).value;
    if (settings == null) throw StateError('no_settings');
    final logger = ref.read(appLoggerProvider);
    try {
      await ref.read(telegramIntegrationProvider).exportFile(
            file: file,
            filename: p.basename(file.path),
            settings: settings,
          );
      // ignore: unawaited_futures
      logger.debug('Telegram export sent format=${format.name}');
    } catch (e, st) {
      // ignore: unawaited_futures
      logger.error('Telegram export failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<String> buildIncomeContent(ExportFormat format) async {
    final incomes = ref.read(allIncomeProvider).value ?? const [];
    final tags = ref.read(tagsStreamProvider).value ?? const [];
    final methods = ref.read(paymentMethodsStreamProvider).value ?? const [];
    final tagNames = {for (final t in tags) t.id: t.name};
    final paymentNames = {for (final m in methods) m.id: m.name};
    final tagsByIncome = await ref
        .read(appDatabaseProvider)
        .getTagIdsByIncomeIds(incomes.map((e) => e.id).toList());
    final exporter = ref.read(incomeExporterProvider);
    return format == ExportFormat.csv
        ? exporter.buildCsv(
            incomes,
            tagNames,
            tagsByIncome,
            paymentNames: paymentNames,
          )
        : exporter.buildJson(
            incomes,
            tagNames,
            tagsByIncome,
            paymentNames: paymentNames,
          );
  }

  Future<String?> saveIncomeFile(ExportFormat format) async {
    final content = await buildIncomeContent(format);
    return ref.read(incomeExporterProvider).saveWithDialog(
          content: content,
          format: format,
        );
  }

  Future<void> shareIncome(ExportFormat format) async {
    final content = await buildIncomeContent(format);
    final file = await ref.read(incomeExporterProvider).writeTempFile(
          content: content,
          format: format,
        );
    await ref.read(incomeExporterProvider).shareFile(file);
  }

  Future<void> copyIncome(ExportFormat format) async {
    final content = await buildIncomeContent(format);
    await Clipboard.setData(ClipboardData(text: content));
  }

  Future<void> sendIncomeTelegram(ExportFormat format) async {
    final content = await buildIncomeContent(format);
    final file = await ref.read(incomeExporterProvider).writeTempFile(
          content: content,
          format: format,
        );
    await _sendTelegramFile(file, format: format);
  }

  String buildIncomeContentFor(
    ExportFormat format, {
    required List<Income> incomes,
    required Map<int, String> tagNames,
    required Map<int, List<int>> tagsByIncome,
    Map<int, String> paymentNames = const {},
  }) {
    final exporter = ref.read(incomeExporterProvider);
    return format == ExportFormat.csv
        ? exporter.buildCsv(
            incomes,
            tagNames,
            tagsByIncome,
            paymentNames: paymentNames,
          )
        : exporter.buildJson(
            incomes,
            tagNames,
            tagsByIncome,
            paymentNames: paymentNames,
          );
  }

  Future<String?> saveIncomeFileFor(
    ExportFormat format, {
    required List<Income> incomes,
    required Map<int, String> tagNames,
    required Map<int, List<int>> tagsByIncome,
    Map<int, String> paymentNames = const {},
  }) {
    final content = buildIncomeContentFor(
      format,
      incomes: incomes,
      tagNames: tagNames,
      tagsByIncome: tagsByIncome,
      paymentNames: paymentNames,
    );
    return ref.read(incomeExporterProvider).saveWithDialog(
          content: content,
          format: format,
        );
  }

  Future<void> shareIncomeFor(
    ExportFormat format, {
    required List<Income> incomes,
    required Map<int, String> tagNames,
    required Map<int, List<int>> tagsByIncome,
    Map<int, String> paymentNames = const {},
  }) async {
    final content = buildIncomeContentFor(
      format,
      incomes: incomes,
      tagNames: tagNames,
      tagsByIncome: tagsByIncome,
      paymentNames: paymentNames,
    );
    final file = await ref.read(incomeExporterProvider).writeTempFile(
          content: content,
          format: format,
        );
    await ref.read(incomeExporterProvider).shareFile(file);
  }

  Future<void> copyIncomeFor(
    ExportFormat format, {
    required List<Income> incomes,
    required Map<int, String> tagNames,
    required Map<int, List<int>> tagsByIncome,
    Map<int, String> paymentNames = const {},
  }) async {
    final content = buildIncomeContentFor(
      format,
      incomes: incomes,
      tagNames: tagNames,
      tagsByIncome: tagsByIncome,
      paymentNames: paymentNames,
    );
    await Clipboard.setData(ClipboardData(text: content));
  }

  Future<void> sendIncomeTelegramFor(
    ExportFormat format, {
    required List<Income> incomes,
    required Map<int, String> tagNames,
    required Map<int, List<int>> tagsByIncome,
    Map<int, String> paymentNames = const {},
  }) async {
    final content = buildIncomeContentFor(
      format,
      incomes: incomes,
      tagNames: tagNames,
      tagsByIncome: tagsByIncome,
      paymentNames: paymentNames,
    );
    final file = await ref.read(incomeExporterProvider).writeTempFile(
          content: content,
          format: format,
        );
    await _sendTelegramFile(file, format: format);
  }

  String buildCashFlowContentFor(
    ExportFormat format, {
    required List<CashFlowExportRow> rows,
    required Map<int, String> tagNames,
    Map<int, String> paymentNames = const {},
  }) {
    final exporter = ref.read(cashFlowExporterProvider);
    return format == ExportFormat.csv
        ? exporter.buildCsv(rows, tagNames, paymentNames: paymentNames)
        : exporter.buildJson(rows, tagNames, paymentNames: paymentNames);
  }

  Future<String> buildCashFlowContent(ExportFormat format) async {
    final expenses = ref.read(allExpensesProvider).value ?? const [];
    final incomes = ref.read(allIncomeProvider).value ?? const [];
    final tags = ref.read(tagsStreamProvider).value ?? const [];
    final methods = ref.read(paymentMethodsStreamProvider).value ?? const [];
    final db = ref.read(appDatabaseProvider);
    final tagsByExpense =
        await db.getTagIdsByExpenseIds(expenses.map((e) => e.id).toList());
    final tagsByIncome =
        await db.getTagIdsByIncomeIds(incomes.map((i) => i.id).toList());
    final rows = <CashFlowExportRow>[
      for (final e in expenses)
        (
          operation: e,
          isIncome: false,
          tagIds: tagsByExpense[e.id] ?? const <int>[],
        ),
      for (final i in incomes)
        (
          operation: i,
          isIncome: true,
          tagIds: tagsByIncome[i.id] ?? const <int>[],
        ),
    ]..sort(
        (a, b) => b.operation.occurredAt.compareTo(a.operation.occurredAt),
      );
    return buildCashFlowContentFor(
      format,
      rows: rows,
      tagNames: {for (final t in tags) t.id: t.name},
      paymentNames: {for (final m in methods) m.id: m.name},
    );
  }

  Future<String?> saveCashFlowFile(ExportFormat format) async {
    final content = await buildCashFlowContent(format);
    return ref.read(cashFlowExporterProvider).saveWithDialog(
          content: content,
          format: format,
        );
  }

  Future<void> shareCashFlow(ExportFormat format) async {
    final content = await buildCashFlowContent(format);
    await _shareCashFlowContent(content, format: format);
  }

  Future<void> copyCashFlow(ExportFormat format) async {
    final content = await buildCashFlowContent(format);
    await Clipboard.setData(ClipboardData(text: content));
  }

  Future<void> sendCashFlowTelegram(ExportFormat format) async {
    final content = await buildCashFlowContent(format);
    await _sendCashFlowContent(content, format: format);
  }

  Future<String?> saveCashFlowFileFor(
    ExportFormat format, {
    required List<CashFlowExportRow> rows,
    required Map<int, String> tagNames,
    Map<int, String> paymentNames = const {},
  }) {
    final content = buildCashFlowContentFor(
      format,
      rows: rows,
      tagNames: tagNames,
      paymentNames: paymentNames,
    );
    return ref.read(cashFlowExporterProvider).saveWithDialog(
          content: content,
          format: format,
        );
  }

  Future<void> shareCashFlowFor(
    ExportFormat format, {
    required List<CashFlowExportRow> rows,
    required Map<int, String> tagNames,
    Map<int, String> paymentNames = const {},
  }) async {
    await _shareCashFlowContent(
      buildCashFlowContentFor(
        format,
        rows: rows,
        tagNames: tagNames,
        paymentNames: paymentNames,
      ),
      format: format,
    );
  }

  Future<void> copyCashFlowFor(
    ExportFormat format, {
    required List<CashFlowExportRow> rows,
    required Map<int, String> tagNames,
    Map<int, String> paymentNames = const {},
  }) async {
    final content = buildCashFlowContentFor(
      format,
      rows: rows,
      tagNames: tagNames,
      paymentNames: paymentNames,
    );
    await Clipboard.setData(ClipboardData(text: content));
  }

  Future<void> sendCashFlowTelegramFor(
    ExportFormat format, {
    required List<CashFlowExportRow> rows,
    required Map<int, String> tagNames,
    Map<int, String> paymentNames = const {},
  }) async {
    await _sendCashFlowContent(
      buildCashFlowContentFor(
        format,
        rows: rows,
        tagNames: tagNames,
        paymentNames: paymentNames,
      ),
      format: format,
    );
  }

  Future<void> _shareCashFlowContent(
    String content, {
    required ExportFormat format,
  }) async {
    final exporter = ref.read(cashFlowExporterProvider);
    final file = await exporter.writeTempFile(
      content: content,
      format: format,
    );
    await exporter.shareFile(file);
  }

  Future<void> _sendCashFlowContent(
    String content, {
    required ExportFormat format,
  }) async {
    final file = await ref.read(cashFlowExporterProvider).writeTempFile(
          content: content,
          format: format,
        );
    await _sendTelegramFile(file, format: format);
  }
}

final exportControllerProvider = Provider<ExportController>((ref) {
  return ExportController(ref);
});
