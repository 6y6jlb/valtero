import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/ui/expense_delete_flow.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';

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

    return AppSheetActionsBar(
      children: [
        const AppCloseIconButton(),
        if (isEdit && expenseId != null)
          AppOutlinedButton(
            label: l10n.delete,
            icon: Icons.delete_outline,
            destructive: true,
            onPressed: () async {
              final deleted =
                  await confirmAndDeleteExpense(context, ref, expenseId!);
              if (!deleted || !context.mounted) return;
              Navigator.of(context).pop();
            },
          ),
        AppFilledButton(
          label: isEdit ? l10n.save : l10n.create,
          icon: Icons.check,
          onPressed: canSave ? onSave : null,
        ),
      ],
    );
  }
}
