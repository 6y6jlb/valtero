import 'package:flutter/material.dart';
import 'package:valtero/features/add_income/ui/add_income_sheet.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Shared “+” FAB that opens the add-income sheet (mirrors [addExpenseFab]).
FloatingActionButton addIncomeFab(
  BuildContext context, {
  required String heroTag,
}) {
  final l10n = AppLocalizations.of(context)!;
  return FloatingActionButton(
    heroTag: heroTag,
    tooltip: l10n.addIncome,
    onPressed: () => showAddIncomeSheet(context),
    child: const Icon(Icons.add, size: 32),
  );
}
