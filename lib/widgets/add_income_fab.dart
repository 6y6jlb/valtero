import 'package:flutter/material.dart';
import 'package:valtero/features/add_income/ui/add_income_sheet.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// FAB that opens the add-income sheet (green button, +).
FloatingActionButton addIncomeFab(
  BuildContext context, {
  required String heroTag,
}) {
  final l10n = AppLocalizations.of(context)!;
  return FloatingActionButton(
    heroTag: heroTag,
    tooltip: l10n.addIncome,
    backgroundColor: const Color(0xFF2E7D32),
    foregroundColor: Colors.white,
    onPressed: () => showAddIncomeSheet(context),
    child: const Icon(Icons.add, size: 28),
  );
}
