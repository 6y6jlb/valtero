import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/transaction_direction.dart';
import 'package:valtero/features/expenses_list/ui/expenses_sheet_title_bar.dart';
import 'package:valtero/features/expenses_list/ui/operation_direction_tabs.dart';

/// Optional title bar + direction tabs shown above the filter summary bar.
/// Extracted from `ExpensesSheetBody` to keep that file under the
/// UI-component line budget.
class ExpensesSheetTopBar extends StatelessWidget {
  final bool showTitleBar;
  final TransactionDirection? direction;
  final ValueChanged<TransactionDirection>? onDirectionChanged;

  const ExpensesSheetTopBar({
    super.key,
    required this.showTitleBar,
    this.direction,
    this.onDirectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final direction = this.direction;
    final onDirectionChanged = this.onDirectionChanged;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTitleBar) ...[
          const ExpensesSheetTitleBar(),
          const SizedBox(height: 12),
        ],
        if (direction != null && onDirectionChanged != null) ...[
          OperationDirectionTabs(
            selected: direction,
            onChanged: onDirectionChanged,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
