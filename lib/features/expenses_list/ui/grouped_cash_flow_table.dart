import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_group_row.dart';
import 'package:valtero/features/expenses_list/ui/signed_money_text.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/money_text.dart';

const double _kColGap = 16;
const double _kGroupW = 150;
const double _kCountW = 60;
const double _kAmountW = 120;

const double _kTableMinWidth = 16 * 2 +
    _kGroupW +
    _kColGap +
    _kCountW +
    _kColGap +
    _kAmountW * 3 +
    _kColGap * 3 +
    72;

/// Grouping table for the cash-flow list: one row per group + currency with
/// income, expenses and net side by side (see [CashFlowGroupRow]).
class GroupedCashFlowTable extends StatelessWidget {
  final List<CashFlowGroupRow> rows;

  const GroupedCashFlowTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > _kTableMinWidth
            ? constraints.maxWidth
            : _kTableMinWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: _kGroupW,
                        child: Text(l10n.columnGroup, style: headerStyle),
                      ),
                      const SizedBox(width: _kColGap),
                      SizedBox(
                        width: _kCountW,
                        child: Text(l10n.columnCount, style: headerStyle),
                      ),
                      const SizedBox(width: _kColGap),
                      SizedBox(
                        width: _kAmountW,
                        child: Text(l10n.cashFlowIncome, style: headerStyle),
                      ),
                      const SizedBox(width: _kColGap),
                      SizedBox(
                        width: _kAmountW,
                        child: Text(l10n.cashFlowExpense, style: headerStyle),
                      ),
                      const SizedBox(width: _kColGap),
                      SizedBox(
                        width: _kAmountW,
                        child: Text(l10n.cashFlowNet, style: headerStyle),
                      ),
                      const SizedBox(width: _kColGap),
                      Expanded(
                        child: Text(l10n.columnCurrency, style: headerStyle),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                for (final row in rows) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: _kGroupW,
                          child: Text(
                            '${row.groupLabel}(${row.currencyCode})',
                            style: theme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: _kColGap),
                        SizedBox(
                          width: _kCountW,
                          child: Text(
                            '${row.count}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: _kColGap),
                        SizedBox(
                          width: _kAmountW,
                          child: MoneyText(
                            amountMinor: row.incomeMinor,
                            currencyCode: row.currencyCode,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                        ),
                        const SizedBox(width: _kColGap),
                        SizedBox(
                          width: _kAmountW,
                          child: MoneyText(
                            amountMinor: row.expenseMinor,
                            currencyCode: row.currencyCode,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: _kColGap),
                        SizedBox(
                          width: _kAmountW,
                          child: SignedMoneyText(
                            signedAmountMinor: row.netMinor,
                            currencyCode: row.currencyCode,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: _kColGap),
                        Expanded(
                          child: CurrencyCodeLabel(
                            row.currencyCode,
                            compact: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
