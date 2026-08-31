import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/ui/expense_delete_flow.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Bottom action bar for add/edit expense sheet.
class AddExpenseActionsBar extends ConsumerWidget {
  final bool isEdit;
  final int? expenseId;
  final VoidCallback onSave;
  final bool canSave;

  const AddExpenseActionsBar({
    super.key,
    required this.isEdit,
    required this.expenseId,
    required this.onSave,
    this.canSave = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            if (isEdit && expenseId != null) ...[
              OutlinedButton.icon(
                onPressed: () async {
                  final deleted =
                      await confirmAndDeleteExpense(context, ref, expenseId!);
                  if (!deleted || !context.mounted) return;
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.delete),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: FilledButton(
                onPressed: canSave ? onSave : null,
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
