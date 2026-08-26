import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/shared/network/dio_provider.dart';
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
    final tagNames = {for (final t in tags) t.id: t.name};
    final exporter = ref.read(expenseExporterProvider);
    return format == ExportFormat.csv
        ? exporter.buildCsv(expenses, tagNames)
        : exporter.buildJson(expenses, tagNames);
  }

  Future<String?> saveFile(ExportFormat format) async {
    final content = await buildContent(format);
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

  Future<void> sendTelegram(ExportFormat format) async {
    final settings = ref.read(appSettingsProvider).value;
    if (settings == null) throw StateError('no_settings');
    final content = await buildContent(format);
    final file = await ref.read(expenseExporterProvider).writeTempFile(
          content: content,
          format: format,
        );
    await ref.read(expenseExporterProvider).sendTelegram(
          dio: ref.read(dioProvider),
          settings: settings,
          file: file,
        );
  }
}

final exportControllerProvider = Provider<ExportController>((ref) {
  return ExportController(ref);
});
