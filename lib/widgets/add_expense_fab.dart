import 'package:flutter/material.dart';
import 'package:valtero/features/add_expense/ui/add_expense_sheet.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// FAB that opens the add-expense sheet (outflow arrow).
FloatingActionButton addExpenseFab(
  BuildContext context, {
  required String heroTag,
}) {
  final l10n = AppLocalizations.of(context)!;
  return FloatingActionButton(
    heroTag: heroTag,
    tooltip: l10n.addExpense,
    onPressed: () => showAddExpenseSheet(context),
    child: const Icon(Icons.north_east, size: 28),
  );
}
