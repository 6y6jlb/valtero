import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/entities/payment_method/model/payment_methods_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/logging/logging_providers.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

final expenseExporterProvider = Provider<ExpenseExporter>((ref) {
  return ExpenseExporter();
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
    final settings = ref.read(appSettingsProvider).value;
    if (settings == null) throw StateError('no_settings');
    final logger = ref.read(appLoggerProvider);
    final file = await ref.read(expenseExporterProvider).writeTempFile(
          content: content,
          format: format,
        );
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
}

final exportControllerProvider = Provider<ExportController>((ref) {
  return ExportController(ref);
});
