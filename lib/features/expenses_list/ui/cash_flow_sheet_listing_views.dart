import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/features/add_expense/ui/add_expense_sheet.dart';
import 'package:valtero/features/add_income/ui/add_income_sheet.dart';
import 'package:valtero/features/add_income/ui/income_delete_flow.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_aggregator.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_group_row.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_selection_key.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/model/recent_operation.dart';
import 'package:valtero/features/expenses_list/ui/expense_delete_flow.dart';
import 'package:valtero/features/expenses_list/ui/cash_flow_breakdown_icons.dart';
import 'package:valtero/features/expenses_list/ui/cash_flow_chart.dart';
import 'package:valtero/features/expenses_list/ui/cash_flow_table.dart';
import 'package:valtero/features/expenses_list/ui/grouped_cash_flow_table.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/infinite_scroll_ellipsis.dart';

/// List / grouping / chart body inside the cash-flow listing card. The chart
/// stays the temporal income-vs-expense bar chart — cash flow has no
/// category/donut breakdown.
class CashFlowSheetListingViews extends ConsumerWidget {
  final ExpenseListViewMode view;
  final List<Expense> filteredExpenses;
  final List<Income> filteredIncomes;
  final List<RecentOperation> pageItems;
  final List<RecentOperation> filtered;
  final bool hasMoreList;
  final List<CashFlowGroupRow>? groupRows;
  final Set<CashFlowSelectionKey> selectedKeys;
  final ValueChanged<CashFlowSelectionKey> onToggleSelected;
  final VoidCallback onToggleSelectAll;
  final bool allSelectableSelected;
  final Map<int, String> paymentLabels;
  final String? displayCurrency;
  final int? Function(RecentOperation operation) convertedMinor;
  final String summaryCurrency;
  final String snapshotKey;
  final RateResolver resolver;
  final ExpenseChartBreakdown chartDatePeriod;
  final String timeZoneId;
  final ValueChanged<ExpenseChartBreakdown> onChartDatePeriodChanged;
  final String emptyMessage;

  const CashFlowSheetListingViews({
    super.key,
    required this.view,
    required this.filteredExpenses,
    required this.filteredIncomes,
    required this.pageItems,
    required this.filtered,
    required this.hasMoreList,
    required this.groupRows,
    required this.selectedKeys,
    required this.onToggleSelected,
    required this.onToggleSelectAll,
    required this.allSelectableSelected,
    required this.paymentLabels,
    required this.displayCurrency,
    required this.convertedMinor,
    required this.summaryCurrency,
    required this.snapshotKey,
    required this.resolver,
    required this.chartDatePeriod,
    required this.timeZoneId,
    required this.onChartDatePeriodChanged,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (view) {
      ExpenseListViewMode.list => Column(
          children: [
            CashFlowTable(
              items: pageItems,
              paymentLabels: paymentLabels,
              displayCurrency: displayCurrency,
              convertedMinor: convertedMinor,
              selectedKeys: selectedKeys,
              onToggleSelected: onToggleSelected,
              onToggleSelectAll: onToggleSelectAll,
              allSelectableSelected: allSelectableSelected,
              onDelete: (key) {
                final match = filtered.where(
                  (op) => CashFlowSelectionKey.fromOperation(op) == key,
                );
                if (match.isEmpty) return;
                final op = match.first;
                if (op.kind == OperationKind.income) {
                  confirmAndDeleteIncome(
                    context,
                    ref,
                    op.id,
                    income: op.income,
                  );
                } else {
                  confirmAndDeleteExpense(
                    context,
                    ref,
                    op.id,
                    expense: op.expense,
                  );
                }
              },
              onOpen: (op) {
                if (op.kind == OperationKind.income) {
                  showAddIncomeSheet(context, income: op.income);
                } else {
                  showAddExpenseSheet(context, expense: op.expense);
                }
              },
              onEdit: (op) {
                if (op.kind == OperationKind.income) {
                  showAddIncomeSheet(context, income: op.income);
                } else {
                  showAddExpenseSheet(context, expense: op.expense);
                }
              },
            ),
            if (hasMoreList) const InfiniteScrollEllipsis(),
          ],
        ),
      ExpenseListViewMode.grouping =>
        GroupedCashFlowTable(rows: groupRows ?? const []),
      ExpenseListViewMode.chart => _CashFlowChartView(
          key: ValueKey(
            'cash-flow-chart-$snapshotKey-'
            '${chartDatePeriod.name}-$summaryCurrency',
          ),
          future: aggregateCashFlow(
            expenses: filteredExpenses,
            incomes: filteredIncomes,
            primaryCurrency: summaryCurrency,
            resolver: resolver,
            breakdown: chartDatePeriod,
            timeZoneId: timeZoneId,
          ),
          displayCurrency: summaryCurrency,
          chartDatePeriod: chartDatePeriod,
          onChartDatePeriodChanged: onChartDatePeriodChanged,
          emptyMessage: emptyMessage,
        ),
    };
  }
}

class _CashFlowChartView extends StatelessWidget {
  final Future<CashFlowAggregation> future;
  final String displayCurrency;
  final ExpenseChartBreakdown chartDatePeriod;
  final ValueChanged<ExpenseChartBreakdown> onChartDatePeriodChanged;
  final String emptyMessage;

  const _CashFlowChartView({
    super.key,
    required this.future,
    required this.displayCurrency,
    required this.chartDatePeriod,
    required this.onChartDatePeriodChanged,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return FutureBuilder<CashFlowAggregation>(
      future: future,
      builder: (context, snapshot) {
        final aggregation = snapshot.data ??
            (buckets: const <CashFlowBucket>[], missingRateCount: 0);
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          child: Column(
            children: [
              if (aggregation.missingRateCount > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.chartMissingRatesAlertGeneric(
                      aggregation.missingRateCount,
                    ),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              CashFlowChart(
                buckets: aggregation.buckets,
                displayCurrency: displayCurrency,
                hideBarAmounts: aggregation.missingRateCount > 0,
                emptyMessage: emptyMessage,
              ),
              const SizedBox(height: 8),
              CashFlowBreakdownIcons(
                selected: chartDatePeriod,
                onChanged: onChartDatePeriodChanged,
              ),
            ],
          ),
        );
      },
    );
  }
}
