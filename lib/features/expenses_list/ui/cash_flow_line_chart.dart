import 'dart:math' show max, min;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_aggregator.dart';
import 'package:valtero/features/expenses_list/ui/chart_empty_placeholder.dart';
import 'package:valtero/features/expenses_list/ui/chart_overlay_controls.dart';
import 'package:valtero/features/expenses_list/ui/chart_selection_panel.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/money_text.dart';

/// Line chart for income, expense, and net cash flow over time.
class CashFlowLineChart extends ConsumerStatefulWidget {
  final List<CashFlowBucket> buckets;
  final String displayCurrency;
  final double chartHeight;
  final bool hideAmounts;
  final String? emptyMessage;

  const CashFlowLineChart({
    super.key,
    required this.buckets,
    required this.displayCurrency,
    this.chartHeight = 312,
    this.hideAmounts = false,
    this.emptyMessage,
  });

  @override
  ConsumerState<CashFlowLineChart> createState() => _CashFlowLineChartState();
}

class _CashFlowLineChartState extends ConsumerState<CashFlowLineChart> {
  ChartSelectionDetail? _selection;

  @override
  void didUpdateWidget(covariant CashFlowLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.buckets, widget.buckets)) {
      _selection = null;
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

    if (buckets.isEmpty) {
      return ChartEmptyPlaceholder(
        message: widget.emptyMessage ?? l10n.noMatchingOperations,
        icon: Icons.show_chart_outlined,
        height: chartHeight * 0.55,
      );
    }

    final stride = max(1, (buckets.length / 6).ceil());
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

    return Column(
      children: [
        SizedBox(
          height: chartHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, kChartOverlayTopInset, 12, 4),
                child: LineChart(
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
                        getTooltipItems: (touchedSpots) =>
                            touchedSpots.map((_) => null).toList(),
                      ),
                      touchCallback: (event, response) {
                        final spots = response?.lineBarSpots;
                        if (spots == null || spots.isEmpty) {
                          if (event is FlPointerExitEvent) {
                            setState(() => _selection = null);
                          }
                          return;
                        }
                        final i = spots.first.x.round();
                        if (i < 0 || i >= buckets.length) return;
                        final bucket = buckets[i];
                        final lines = <ChartSelectionLine>[];
                        final seen = <int>{};
                        for (final spot in spots) {
                          if (!seen.add(spot.barIndex)) continue;
                          final amountMinor = amountForBar(
                            spot.barIndex,
                            bucket,
                          );
                          if (!hideAmounts && amountMinor == 0) continue;
                          lines.add(
                            ChartSelectionLine(
                              label: lineLabel(spot.barIndex),
                              amountText: hideAmounts
                                  ? null
                                  : formatMoneyOf(
                                      context,
                                      ref,
                                      amountMinor: amountMinor,
                                      currencyCode: displayCurrency,
                                    ),
                              color: lineColor(spot.barIndex),
                            ),
                          );
                        }
                        setState(() {
                          _selection = ChartSelectionDetail(
                            title: bucket.label,
                            lines: lines,
                          );
                        });
                      },
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
                            if (i < 0 || i >= buckets.length) {
                              return const SizedBox.shrink();
                            }
                            if (i % stride != 0 && i != buckets.length - 1) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                buckets[i].label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 9,
                                  height: 1.1,
                                ),
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
                        dotData: const FlDotData(show: false),
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
                        dotData: const FlDotData(show: false),
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
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                  duration: Duration.zero,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: ChartSelectionPanel(detail: _selection),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            _LegendDot(
              color: incomeColor,
              label: l10n.cashFlowIncome,
              icon: Icons.south_west,
            ),
            _LegendDot(
              color: expenseColor,
              label: l10n.cashFlowExpense,
              icon: Icons.north_east,
            ),
            _LegendDot(color: netColor, label: l10n.summaryTotal),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final IconData? icon;

  const _LegendDot({required this.color, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Icon(icon, size: 16, color: color)
        else
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}
