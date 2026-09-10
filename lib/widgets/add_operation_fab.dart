import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/expand_fab_menu.dart';

/// Theme-colored `+` FAB that expands upward into text actions for expense / income.
class AddOperationFab extends StatelessWidget {
  final String heroTag;
  final Future<void> Function() onAddExpense;
  final Future<void> Function() onAddIncome;

  const AddOperationFab({
    super.key,
    required this.heroTag,
    required this.onAddExpense,
    required this.onAddIncome,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ExpandFabMenu(
      heroTag: heroTag,
      closedTooltip: l10n.add,
      closedChild: const Icon(Icons.add, size: 28),
      actions: [
        ExpandFabAction(
          label: l10n.addExpense,
          onPressed: onAddExpense,
        ),
        ExpandFabAction(
          label: l10n.addIncome,
          onPressed: onAddIncome,
        ),
      ],
    );
  }
}
