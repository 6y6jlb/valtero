import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/expand_fab_menu.dart';

/// Theme-colored Show FAB → Show cash flow / expenses / income.
class ShowListFab extends StatelessWidget {
  final String heroTag;
  final Future<void> Function() onShowCashFlow;
  final Future<void> Function() onShowExpenses;
  final Future<void> Function() onShowIncome;

  const ShowListFab({
    super.key,
    required this.heroTag,
    required this.onShowCashFlow,
    required this.onShowExpenses,
    required this.onShowIncome,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ExpandFabMenu(
      heroTag: heroTag,
      closedTooltip: l10n.fabShow,
      closedExtended: true,
      closedLabel: l10n.fabShow,
      closedChild: const Icon(Icons.list_alt),
      actions: [
        ExpandFabAction(
          label: l10n.showCashFlow,
          onPressed: onShowCashFlow,
        ),
        ExpandFabAction(
          label: l10n.showExpenses,
          onPressed: onShowExpenses,
        ),
        ExpandFabAction(
          label: l10n.showIncomeList,
          onPressed: onShowIncome,
        ),
      ],
    );
  }
}
