import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_aggregator.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/ui/breakdown_chart_view.dart';
import 'package:valtero/features/expenses_list/ui/cash_flow_chart.dart';
import 'package:valtero/features/expenses_list/ui/cash_flow_line_chart.dart';
import 'package:valtero/features/expenses_list/ui/chart_overlay_controls.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

const _kCashFlowChartTypes = [
  ExpenseChartType.donut,
  ExpenseChartType.column,
  ExpenseChartType.line,
];

/// Cash-flow chart with donut (income vs expense totals), temporal grouped
/// bars, or line chart. Donut is the default shape.
class CashFlowChartView extends ConsumerWidget {
  final List<CashFlowBucket> buckets;
  final String displayCurrency;
  final ExpenseChartType chartType;
  final ValueChanged<ExpenseChartType> onChartTypeChanged;
  final ExpenseChartBreakdown? breakdown;
  final ValueChanged<ExpenseChartBreakdown>? onBreakdownChanged;
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
    this.breakdown,
    this.onBreakdownChanged,
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
        availableChartTypes: _kCashFlowChartTypes,
        breakdown: breakdown,
        onBreakdownChanged: onBreakdownChanged,
        cashFlowPeriodOnly: true,
        hideCenterTotal: hideAmounts,
        hideSegmentAmounts: hideAmounts,
        emptyMessage: emptyMessage,
        emptyIcon: emptyIcon,
        chartHeight: chartHeight,
      );
    }

    if (chartType == ExpenseChartType.line) {
      return padClearOfEndSystemBar(
        context,
        Column(
          children: [
            ChartOverlayControls(
              chartType: chartType,
              onChartTypeChanged: onChartTypeChanged,
              availableChartTypes: _kCashFlowChartTypes,
            ),
            const SizedBox(height: 4),
            CashFlowLineChart(
              buckets: buckets,
              displayCurrency: displayCurrency,
              hideAmounts: hideAmounts,
              emptyMessage: emptyMessage,
              chartHeight: chartHeight,
              breakdown: breakdown,
              onBreakdownChanged: onBreakdownChanged,
            ),
          ],
        ),
      );
    }

    // Grouped bars by period (day/week/month/year).
    return padClearOfEndSystemBar(
      context,
      Column(
        children: [
          ChartOverlayControls(
            chartType: chartType,
            onChartTypeChanged: onChartTypeChanged,
            availableChartTypes: _kCashFlowChartTypes,
          ),
          const SizedBox(height: 4),
          CashFlowChart(
            buckets: buckets,
            displayCurrency: displayCurrency,
            hideBarAmounts: hideAmounts,
            emptyMessage: emptyMessage,
            emptyIcon: emptyIcon,
            chartHeight: chartHeight,
            breakdown: breakdown,
            onBreakdownChanged: onBreakdownChanged,
          ),
        ],
      ),
    );
  }
}
