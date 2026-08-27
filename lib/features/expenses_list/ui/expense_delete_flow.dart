import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/expense/model/expense_tags_provider.dart';
import 'package:valtero/features/add_expense/model/add_expense_controller.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_toast.dart';

Future<void> confirmAndDeleteExpense(
  BuildContext context,
  WidgetRef ref,
  int expenseId,
) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.confirmDeleteExpense),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.no),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.yes),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  await ref.read(addExpenseControllerProvider).delete(expenseId);
  ref.invalidate(expenseTagIdsProvider);
  if (!context.mounted) return;

  showAppToast(context, l10n.expenseDeleted);
}
