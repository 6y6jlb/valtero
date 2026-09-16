import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_aggregator.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/ui/breakdown_chart_view.dart';
import 'package:valtero/features/expenses_list/ui/cash_flow_chart.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Cash-flow chart with donut (income vs expense totals) or temporal grouped
/// bars. Donut is the default shape; toggle matches expenses/income charts.
class CashFlowChartView extends ConsumerWidget {
  final List<CashFlowBucket> buckets;
  final String displayCurrency;
  final ExpenseChartType chartType;
  final ValueChanged<ExpenseChartType> onChartTypeChanged;
  final bool hideAmounts;
  final String? emptyMessage;
  final IconData emptyIcon;
  final double chartHeight;

  const CashFlowChartView({
    super.key,
    required this.buckets,
    required this.displayCurrency,
    required this.chartType,
    required this.onChartTypeChanged,
    this.hideAmounts = false,
    this.emptyMessage,
    this.emptyIcon = Icons.pie_chart_outline,
    this.chartHeight = 312,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final slices = cashFlowDirectionSlices(
      buckets: buckets,
      incomeLabel: l10n.cashFlowIncome,
      expenseLabel: l10n.cashFlowExpense,
      incomeColor: theme.colorScheme.tertiary,
      expenseColor: theme.colorScheme.error,
    );

    if (chartType == ExpenseChartType.donut) {
      return BreakdownChartView(
        slices: slices,
        displayCurrency: displayCurrency,
        chartType: ExpenseChartType.donut,
        onChartTypeChanged: onChartTypeChanged,
        hideCenterTotal: hideAmounts,
        hideSegmentAmounts: hideAmounts,
        emptyMessage: emptyMessage,
        emptyIcon: emptyIcon,
        chartHeight: chartHeight,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CashFlowChart(
          buckets: buckets,
          displayCurrency: displayCurrency,
          hideBarAmounts: hideAmounts,
          emptyMessage: emptyMessage,
          emptyIcon: emptyIcon,
          chartHeight: chartHeight,
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Material(
            color: theme.colorScheme.surface.withValues(alpha: 0.88),
            elevation: 0,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: l10n.chartTypeDonut,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.pie_chart_outline,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () =>
                        onChartTypeChanged(ExpenseChartType.donut),
                  ),
                  IconButton(
                    tooltip: l10n.chartTypeColumn,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.bar_chart,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () =>
                        onChartTypeChanged(ExpenseChartType.column),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
