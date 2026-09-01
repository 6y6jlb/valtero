import 'package:flutter/material.dart';
import 'package:valtero/features/add_expense/ui/add_expense_sheet.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// AppBar-like title row for the expenses sheet (optional via [ExpensesSheetBody.showTitleBar]).
class ExpensesSheetTitleBar extends StatelessWidget {
  const ExpensesSheetTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.navExpenses,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton.filled(
          tooltip: l10n.addExpense,
          onPressed: () => showAddExpenseSheet(context),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
