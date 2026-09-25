import 'dart:math' show max, min;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_aggregator.dart';
import 'package:valtero/features/expenses_list/model/chart_breakdown_options.dart';
import 'package:valtero/features/expenses_list/model/cycle_index.dart';
import 'package:valtero/features/expenses_list/model/cycle_transition_direction.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/ui/chart_breakdown_row.dart';
import 'package:valtero/features/expenses_list/ui/chart_empty_placeholder.dart';
import 'package:valtero/features/expenses_list/ui/chart_axis_title.dart';
import 'package:valtero/features/expenses_list/ui/chart_overlay_controls.dart';
import 'package:valtero/features/expenses_list/ui/chart_tooltip_style.dart';
import 'package:valtero/features/expenses_list/ui/directional_slide_switcher.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/money_text.dart';

/// Line chart for income, expense, and net cash flow over time.
class CashFlowLineChart extends ConsumerStatefulWidget {
  final List<CashFlowBucket> buckets;
  final String displayCurrency;
  final double chartHeight;
  final bool hideAmounts;
  final String? emptyMessage;
  final ExpenseChartBreakdown? breakdown;
  final ValueChanged<ExpenseChartBreakdown>? onBreakdownChanged;

  const CashFlowLineChart({
    super.key,
    required this.buckets,
    required this.displayCurrency,
    this.chartHeight = 312,
    this.hideAmounts = false,
    this.emptyMessage,
    this.breakdown,
    this.onBreakdownChanged,
  });

  @override
  ConsumerState<CashFlowLineChart> createState() => _CashFlowLineChartState();
}

class _CashFlowLineChartState extends ConsumerState<CashFlowLineChart> {
  bool _breakdownSlideForward = true;

  @override
  void didUpdateWidget(covariant CashFlowLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldB = oldWidget.breakdown;
    final newB = widget.breakdown;
    if (oldB != null && newB != null && oldB != newB) {
      _breakdownSlideForward = cycleTransitionForward(
        kCashFlowChartBreakdownOrder,
        oldB,
        newB,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final incomeColor = theme.colorScheme.tertiary;
    final expenseColor = theme.colorScheme.error;
    final netColor = theme.colorScheme.onSurface;
    final buckets = widget.buckets;
    final hideAmounts = widget.hideAmounts;
    final displayCurrency = widget.displayCurrency;
    final chartHeight = widget.chartHeight;
    final breakdown = widget.breakdown;
    final onBreakdownChanged = widget.onBreakdownChanged;

    if (buckets.isEmpty) {
      return ChartEmptyPlaceholder(
        message: widget.emptyMessage ?? l10n.noMatchingOperations,
        icon: Icons.show_chart_outlined,
        height: chartHeight * 0.55,
      );
    }

    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      fontSize: 9,
      height: 1.1,
    );
    final showDots = buckets.length == 1;
    const incomeBarIndex = 0;
    const expenseBarIndex = 1;

    var minY = 0.0;
    var maxY = 0.0;
    for (final bucket in buckets) {
      minY = min(minY, bucket.netMinor.toDouble());
      maxY = max(maxY, bucket.incomeTotalMinor.toDouble());
      maxY = max(maxY, bucket.expenseTotalMinor.toDouble());
      maxY = max(maxY, bucket.netMinor.toDouble());
    }
    final yPad = maxY <= 0 && minY >= 0 ? 1.0 : (maxY - minY) * 0.12;

    String lineLabel(int barIndex) {
      return switch (barIndex) {
        incomeBarIndex => l10n.cashFlowIncome,
        expenseBarIndex => l10n.cashFlowExpense,
        _ => l10n.summaryTotal,
      };
    }

    Color lineColor(int barIndex) {
      return switch (barIndex) {
        incomeBarIndex => incomeColor,
        expenseBarIndex => expenseColor,
        _ => netColor,
      };
    }

    int amountForBar(int barIndex, CashFlowBucket bucket) {
      return switch (barIndex) {
        incomeBarIndex => bucket.incomeTotalMinor,
        expenseBarIndex => bucket.expenseTotalMinor,
        _ => bucket.netMinor,
      };
    }

    final showBreakdown = breakdown != null && onBreakdownChanged != null;

    Widget plot = SizedBox(
      height: chartHeight,
      child: Padding(
        padding: kChartPlotPadding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final plan = planChartAxisLabelsForTexts(
              labels: [for (final b in buckets) b.label],
              plotWidth: constraints.maxWidth,
              style: labelStyle,
            );
            return LineChart(
              LineChartData(
                minX: 0,
                maxX: buckets.length <= 1
                    ? 1
                    : (buckets.length - 1).toDouble(),
                minY: minY < 0 ? minY - yPad : 0,
                maxY: maxY <= 0 && minY >= 0 ? 1 : maxY + yPad,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => chartTooltipBg(context),
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    maxContentWidth: 200,
                    getTooltipItems: (touchedSpots) {
                      if (touchedSpots.isEmpty) return [];
                      final i = touchedSpots.first.x.round();
                      if (i < 0 || i >= buckets.length) {
                        return touchedSpots.map((_) => null).toList();
                      }
                      final bucket = buckets[i];
                      final buf = StringBuffer(bucket.label);
                      final seen = <int>{};
                      for (final spot in touchedSpots) {
                        if (!seen.add(spot.barIndex)) continue;
                        final amountMinor =
                            amountForBar(spot.barIndex, bucket);
                        if (!hideAmounts && amountMinor == 0) continue;
                        buf.write('\n${lineLabel(spot.barIndex)}');
                        if (!hideAmounts) {
                          buf.write(
                            ': ${formatMoneyOf(context, ref, amountMinor: amountMinor, currencyCode: displayCurrency)}',
                          );
                        }
                      }
                      return [
                        for (var s = 0; s < touchedSpots.length; s++)
                          if (s == 0)
                            chartLineTooltipItem(
                              context: context,
                              text: buf.toString(),
                              accent: lineColor(touchedSpots.first.barIndex),
                            )
                          else
                            null,
                      ];
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final i = value.round();
                        if (!shouldShowChartAxisLabel(
                          index: i,
                          labelCount: buckets.length,
                          plan: plan,
                        )) {
                          return const SizedBox.shrink();
                        }
                        return chartBottomAxisTitle(
                          meta: meta,
                          child: Text(
                            buckets[i].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: labelStyle,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < buckets.length; i++)
                        FlSpot(
                          i.toDouble(),
                          buckets[i].incomeTotalMinor.toDouble(),
                        ),
                    ],
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: incomeColor,
                    barWidth: 2,
                    dotData: FlDotData(show: showDots),
                  ),
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < buckets.length; i++)
                        FlSpot(
                          i.toDouble(),
                          buckets[i].expenseTotalMinor.toDouble(),
                        ),
                    ],
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: expenseColor,
                    barWidth: 2,
                    dotData: FlDotData(show: showDots),
                  ),
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < buckets.length; i++)
                        FlSpot(
                          i.toDouble(),
                          buckets[i].netMinor.toDouble(),
                        ),
                    ],
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: netColor,
                    barWidth: 3.5,
                    dotData: FlDotData(show: showDots),
                  ),
                ],
              ),
              duration: Duration.zero,
            );
          },
        ),
      ),
    );

    plot = showBreakdown
        ? InteractiveSlidePager(
            pageKey: breakdown,
            externalForward: _breakdownSlideForward,
            onNext: () => onBreakdownChanged(
              cycleIndex(
                kCashFlowChartBreakdownOrder,
                breakdown,
                forward: true,
              ),
            ),
            onPrevious: () => onBreakdownChanged(
              cycleIndex(
                kCashFlowChartBreakdownOrder,
                breakdown,
                forward: false,
              ),
            ),
            child: plot,
          )
        : plot;

    final incomeTotal =
        buckets.fold<int>(0, (sum, b) => sum + b.incomeTotalMinor);
    final expenseTotal =
        buckets.fold<int>(0, (sum, b) => sum + b.expenseTotalMinor);
    final netTotal = incomeTotal - expenseTotal;
    String? amountOf(int minor) {
      if (hideAmounts) return null;
      return formatMoneyOf(
        context,
        ref,
        amountMinor: minor,
        currencyCode: displayCurrency,
        hideFraction: true,
      );
    }

    final legend = Wrap(
      spacing: 16,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        _LegendDot(
          color: incomeColor,
          label: l10n.cashFlowIncome,
          amountLabel: amountOf(incomeTotal),
          icon: Icons.south_west,
        ),
        _LegendDot(
          color: expenseColor,
          label: l10n.cashFlowExpense,
          amountLabel: amountOf(expenseTotal),
          icon: Icons.north_east,
        ),
        _LegendDot(
          color: netColor,
          label: l10n.summaryTotal,
          amountLabel: amountOf(netTotal),
        ),
      ],
    );

    return Column(
      children: [
        plot,
        if (showBreakdown) ...[
          const SizedBox(height: 4),
          ChartBreakdownRow(
            selected: breakdown,
            onChanged: onBreakdownChanged,
            cashFlowPeriodOnly: true,
          ),
        ],
        const SizedBox(height: 8),
        legend,
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final String? amountLabel;
  final IconData? icon;

  const _LegendDot({
    required this.color,
    required this.label,
    this.amountLabel,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: amountLabel != null ? 2 : 0),
          child: icon != null
              ? Icon(icon, size: 16, color: color)
              : Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
        ),
        const SizedBox(width: 6),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelMedium),
            if (amountLabel != null)
              Text(
                amountLabel!,
                style: theme.textTheme.labelSmall?.copyWith(color: muted),
              ),
          ],
        ),
      ],
    );
  }
}
