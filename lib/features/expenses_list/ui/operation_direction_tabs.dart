import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/transaction_direction.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/bookmark_tabs.dart';

/// Folder-style bookmark tabs for expenses / income / cash-flow views.
class OperationDirectionTabs extends StatelessWidget {
  final TransactionDirection selected;
  final ValueChanged<TransactionDirection> onChanged;

  const OperationDirectionTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  String _label(AppLocalizations l10n, TransactionDirection direction) {
    return switch (direction) {
      TransactionDirection.expenses => l10n.directionExpenses,
      TransactionDirection.income => l10n.directionIncome,
      TransactionDirection.cashFlow => l10n.directionCashFlow,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final directions = TransactionDirection.values;

    return BookmarkTabs(
      labels: [for (final d in directions) _label(l10n, d)],
      selectedIndex: directions.indexOf(selected),
      onChanged: (i) => onChanged(directions[i]),
    );
  }
}
