import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/expense_group_row.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/money_text.dart';

class GroupedExpenseTable extends StatelessWidget {
  final List<ExpenseGroupRow> rows;

  const GroupedExpenseTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(l10n.columnGroup, style: headerStyle),
              ),
              Expanded(
                flex: 2,
                child: Text(l10n.columnCount, style: headerStyle),
              ),
              Expanded(
                flex: 3,
                child: Text(l10n.columnAmount, style: headerStyle),
              ),
              Expanded(
                flex: 2,
                child: Text(l10n.columnCurrency, style: headerStyle),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        for (final row in rows) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    '${row.groupLabel}(${row.currencyCode})',
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${row.count}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: MoneyText(
                    amountMinor: row.amountMinor,
                    currencyCode: row.currencyCode,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: CurrencyCodeLabel(row.currencyCode, compact: true),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ],
    );
  }
}
