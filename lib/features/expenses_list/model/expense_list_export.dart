import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/expense/model/expense_tags_provider.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/payment_method/model/payment_methods_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/expenses_list/model/expense_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/features/export_expenses/model/export_controller.dart';
import 'package:valtero/features/export_expenses/model/export_destination.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/payment_method_label.dart';
import 'package:valtero/shared/utils/tag_label.dart';

Future<String?> exportFilteredExpenses(
  WidgetRef ref,
  BuildContext context, {
  required ExportFormat format,
  required ExportDestination destination,
  required ExpenseListQuery query,
  Map<String, double>? displayRates,
  String? displayCurrency,
}) async {
  final expenses = ref.read(allExpensesProvider).value ?? const [];
  final tags = ref.read(tagsStreamProvider).value ?? const [];
  final methods = ref.read(paymentMethodsStreamProvider).value ?? const [];
  final expenseTags = ref.read(expenseTagIdsProvider).value ?? const {};
  final timeZoneId =
      ref.read(appSettingsProvider).value?.timeZoneId ?? kSystemTimeZoneId;
  final tagLabels = {
    for (final t in tags) t.id: localizedTagLabel(context, t),
  };
  final paymentLabels = {
    for (final m in methods) m.id: localizedPaymentMethodLabel(context, m),
  };
  final filtered = sortExpenses(
    list: filterExpenses(
      all: expenses,
      query: query,
      expenseTags: expenseTags,
      timeZoneId: timeZoneId,
    ),
    query: query,
    displayRates: displayRates,
    displayCurrency: displayCurrency,
  );
  final tagsByExpense = {
    for (final e in filtered) e.id: expenseTags[e.id] ?? const <int>[],
  };
  final controller = ref.read(exportControllerProvider);
  final l10n = AppLocalizations.of(context)!;

  switch (destination) {
    case ExportDestination.share:
      await controller.shareFor(
        format,
        expenses: filtered,
        tagNames: tagLabels,
        tagsByExpense: tagsByExpense,
        paymentNames: paymentLabels,
      );
      return l10n.exportDone;
    case ExportDestination.copy:
      await controller.copyFor(
        format,
        expenses: filtered,
        tagNames: tagLabels,
        tagsByExpense: tagsByExpense,
        paymentNames: paymentLabels,
      );
      return l10n.copiedToClipboard;
    case ExportDestination.telegram:
      await controller.sendTelegramFor(
        format,
        expenses: filtered,
        tagNames: tagLabels,
        tagsByExpense: tagsByExpense,
        paymentNames: paymentLabels,
      );
      return l10n.telegramSent;
    case ExportDestination.save:
      final path = await controller.saveFileFor(
        format,
        expenses: filtered,
        tagNames: tagLabels,
        tagsByExpense: tagsByExpense,
        paymentNames: paymentLabels,
      );
      return path == null ? null : l10n.exportDone;
  }
}
