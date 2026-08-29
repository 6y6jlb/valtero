import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/add_expense/model/add_expense_controller.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_toast.dart';

/// Returns `true` if the expense was deleted.
Future<bool> confirmAndDeleteExpense(
  BuildContext context,
  WidgetRef ref,
  int expenseId,
) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showAppModalSheet<bool>(
    context: context,
    initialChildSize: 0.35,
    minChildSize: 0.25,
    maxChildSize: 0.5,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Text(
          l10n.confirmDeleteExpense,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.no),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.yes),
            ),
          ],
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;

  await ref.read(addExpenseControllerProvider).delete(expenseId);
  if (!context.mounted) return true;

  showAppToast(context, l10n.expenseDeleted);
  return true;
}
