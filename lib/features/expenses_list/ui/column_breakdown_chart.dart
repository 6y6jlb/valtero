import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/money_text.dart';

/// Vertical column chart for the same [DonutChartSlice] breakdown data.
class ColumnBreakdownChart extends ConsumerWidget {
  final List<DonutChartSlice> slices;
  final String displayCurrency;
  final ValueChanged<DonutChartSlice>? onSegmentTap;
  final bool hideSegmentAmounts;
  final double chartHeight;
  final String? emptyMessage;

  const ColumnBreakdownChart({
    super.key,
    required this.slices,
    required this.displayCurrency,
    this.onSegmentTap,
    this.hideSegmentAmounts = false,
    this.chartHeight = 260,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (slices.isEmpty) {
      return SizedBox(
        height: chartHeight,
        child: Center(
          child: Text(emptyMessage ?? l10n.noMatchingExpenses),
        ),
      );
    }

    final maxY = slices
        .map((s) => s.amountMinor.toDouble().abs())
        .fold<double>(0, (a, b) => a > b ? a : b);
    final barWidth = (28.0 - slices.length * 1.2).clamp(6.0, 22.0);
    final showBottomTitles = slices.length <= 8;

    return SizedBox(
      height: chartHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 12, 4),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY <= 0 ? 1 : maxY * 1.12,
            minY: 0,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) =>
                    theme.colorScheme.inverseSurface.withValues(alpha: 0.92),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  if (groupIndex < 0 || groupIndex >= slices.length) {
                    return null;
                  }
                  final slice = slices[groupIndex];
                  final amount = hideSegmentAmounts
                      ? ''
                      : formatMoneyOf(
                          context,
                          ref,
                          amountMinor: slice.amountMinor,
                          currencyCode:
                              slice.currencyCode ?? displayCurrency,
                        );
                  return BarTooltipItem(
                    amount.isEmpty ? slice.label : '${slice.label}\n$amount',
                    TextStyle(
                      color: theme.colorScheme.onInverseSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                },
              ),
              touchCallback: (event, response) {
                if (onSegmentTap == null) return;
                if (event is! FlTapUpEvent) return;
                final index = response?.spot?.touchedBarGroupIndex;
                if (index == null || index < 0 || index >= slices.length) {
                  return;
                }
                onSegmentTap!(slices[index]);
              },
              mouseCursorResolver: (event, response) {
                if (onSegmentTap == null) return SystemMouseCursors.basic;
                final index = response?.spot?.touchedBarGroupIndex;
                if (index != null && index >= 0 && index < slices.length) {
                  return SystemMouseCursors.click;
                }
                return SystemMouseCursors.basic;
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
                  showTitles: showBottomTitles,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= slices.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        slices[i].label,
                        maxLines: 2,
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
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              for (var i = 0; i < slices.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: slices[i].amountMinor.toDouble().abs() == 0
                          ? 0.0001
                          : slices[i].amountMinor.toDouble().abs(),
                      color: slices[i].color,
                      width: barWidth,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          duration: Duration.zero,
        ),
      ),
    );
  }
}
