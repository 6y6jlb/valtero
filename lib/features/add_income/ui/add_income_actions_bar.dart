import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/add_income/ui/income_delete_flow.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';

/// Bottom action bar for add/edit income sheet.
class AddIncomeActionsBar extends ConsumerWidget {
  final bool isEdit;
  final int? incomeId;
  final VoidCallback onSave;
  final bool canSave;

  const AddIncomeActionsBar({
    super.key,
    required this.isEdit,
    required this.incomeId,
    required this.onSave,
    this.canSave = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return AppSheetActionsBar(
      children: [
        const AppCloseIconButton(),
        if (isEdit && incomeId != null)
          AppOutlinedButton(
            label: l10n.delete,
            icon: Icons.delete_outline,
            destructive: true,
            onPressed: () async {
              final deleted =
                  await confirmAndDeleteIncome(context, ref, incomeId!);
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
