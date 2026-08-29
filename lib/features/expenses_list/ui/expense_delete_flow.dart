import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/add_expense/model/add_expense_controller.dart';
import 'package:valtero/features/expenses_list/model/expense_bulk_list_description.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_toast.dart';
import 'package:valtero/widgets/confirm_action_sheet.dart';

/// Returns `true` if the expense was deleted.
Future<bool> confirmAndDeleteExpense(
  BuildContext context,
  WidgetRef ref,
  int expenseId, {
  Expense? expense,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final description = expense == null
      ? l10n.confirmDeleteExpenseDescription
      : '${l10n.confirmDeleteExpenseDescription}\n\n'
          '${buildExpenseBulkListDescription(context, ref, expenses: [expense])}';

  final confirmed = await showConfirmActionSheet<bool>(
    context: context,
    initialChildSize: 0.38,
    minChildSize: 0.28,
    maxChildSize: 0.55,
    child: Builder(
      builder: (sheetContext) => ConfirmActionLayout(
        title: l10n.confirmDeleteExpense,
        description: description,
        actions: confirmActionButtons(
          context: sheetContext,
          confirmLabel: l10n.yes,
          destructive: true,
          onConfirm: () => Navigator.pop(sheetContext, true),
          onCancel: () => Navigator.pop(sheetContext, false),
        ),
      ),
    ),
  );
  if (confirmed != true || !context.mounted) return false;

  await ref.read(addExpenseControllerProvider).delete(expenseId);
  if (!context.mounted) return true;

  showAppToast(context, l10n.expenseDeleted);
  return true;
}
