import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_aggregator.dart';
import 'package:valtero/features/expenses_list/model/chart_overlay_layout.dart';
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

  Widget _overlayControls({int? maxIconsPerRow}) {
    return ChartOverlayControls(
      chartType: chartType,
      onChartTypeChanged: onChartTypeChanged,
      availableChartTypes: _kCashFlowChartTypes,
      breakdown: breakdown,
      onBreakdownChanged: onBreakdownChanged,
      cashFlowPeriodOnly: true,
      maxIconsPerRow: maxIconsPerRow,
    );
  }

  Widget _chromeOnlyOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = isChartOverlayNarrow(constraints.maxWidth);
        return Align(
          alignment: Alignment.centerRight,
          child: _overlayControls(
            maxIconsPerRow:
                narrow ? kChartOverlayNarrowMaxIconsPerRow : null,
          ),
        );
      },
    );
  }

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
      return Column(
        children: [
          _chromeOnlyOverlay(),
          const SizedBox(height: 4),
          CashFlowLineChart(
            buckets: buckets,
            displayCurrency: displayCurrency,
            hideAmounts: hideAmounts,
            emptyMessage: emptyMessage,
            chartHeight: chartHeight,
          ),
        ],
      );
    }

    // Grouped bars by period (day/week/month/year) — cash-flow's "by date"
    // chart. No separate columnByDate type: that icon is for category stacks
    // on expenses/income, which do not apply to income-vs-expense buckets.
    return Column(
      children: [
        _chromeOnlyOverlay(),
        const SizedBox(height: 4),
        CashFlowChart(
          buckets: buckets,
          displayCurrency: displayCurrency,
          hideBarAmounts: hideAmounts,
          emptyMessage: emptyMessage,
          emptyIcon: emptyIcon,
          chartHeight: chartHeight,
        ),
      ],
    );
  }
}
