import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/transaction_direction.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Three-way segmented control switching between expenses / income /
/// combined cash-flow views.
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
    return SegmentedButton<TransactionDirection>(
      segments: [
        for (final direction in TransactionDirection.values)
          ButtonSegment<TransactionDirection>(
            value: direction,
            label: Text(_label(l10n, direction)),
          ),
      ],
      selected: {selected},
      showSelectedIcon: false,
      onSelectionChanged: (next) {
        if (next.isEmpty) return;
        onChanged(next.first);
      },
    );
  }
}
