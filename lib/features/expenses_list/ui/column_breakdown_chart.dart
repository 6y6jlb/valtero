import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/ui/chart_anim.dart';
import 'package:valtero/features/expenses_list/ui/chart_overlay_controls.dart';
import 'package:valtero/features/expenses_list/ui/chart_selection_panel.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/money_text.dart';

/// Vertical column chart for the same [DonutChartSlice] breakdown data.
///
/// Pass every slice plus [hiddenKeys]. Hidden bars animate to zero height.
/// Hover details go to [onSelectionChanged] (rendered in the chrome row).
class ColumnBreakdownChart extends ConsumerWidget {
  final List<DonutChartSlice> slices;
  final Set<String> hiddenKeys;
  final String displayCurrency;
  final ValueChanged<DonutChartSlice>? onSegmentTap;
  final ValueChanged<ChartSelectionDetail?>? onSelectionChanged;
  final bool hideSegmentAmounts;
  final double chartHeight;
  final String? emptyMessage;

  const ColumnBreakdownChart({
    super.key,
    required this.slices,
    this.hiddenKeys = const {},
    required this.displayCurrency,
    this.onSegmentTap,
    this.onSelectionChanged,
    this.hideSegmentAmounts = false,
    this.chartHeight = 312,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (slices.isEmpty) {
      return SizedBox(
        height: chartHeight,
        child: Center(child: Text(emptyMessage ?? l10n.noMatchingExpenses)),
      );
    }

    final maxY = slices
        .where((s) => !hiddenKeys.contains(s.key))
        .map((s) => s.amountMinor.toDouble().abs())
        .fold<double>(0, (a, b) => a > b ? a : b);
    final barWidth = (28.0 - slices.length * 1.2).clamp(6.0, 22.0);
    final showBottomTitles = slices.length <= 8;

    return SizedBox(
      height: chartHeight,
      child: Padding(
        padding: kChartPlotPadding,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY <= 0 ? 1 : maxY * 1.12,
            minY: 0,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) => null,
              ),
              touchCallback: (event, response) {
                final index = response?.spot?.touchedBarGroupIndex;
                final onChanged = onSelectionChanged;
                if (onChanged != null) {
                  if (index == null ||
                      index < 0 ||
                      index >= slices.length ||
                      hiddenKeys.contains(slices[index].key)) {
                    if (event is FlPointerExitEvent) onChanged(null);
                  } else {
                    final slice = slices[index];
                    onChanged(
                      ChartSelectionDetail(
                        title: slice.label,
                        lines: [
                          if (!hideSegmentAmounts)
                            ChartSelectionLine(
                              label: formatMoneyOf(
                                context,
                                ref,
                                amountMinor: slice.amountMinor,
                                currencyCode:
                                    slice.currencyCode ?? displayCurrency,
                              ),
                              color: slice.color,
                            ),
                        ],
                      ),
                    );
                  }
                }
                if (onSegmentTap == null) return;
                if (event is! FlTapUpEvent) return;
                if (index == null || index < 0 || index >= slices.length) {
                  return;
                }
                if (hiddenKeys.contains(slices[index].key)) return;
                onSegmentTap!(slices[index]);
              },
              mouseCursorResolver: (event, response) {
                if (onSegmentTap == null) return SystemMouseCursors.basic;
                final index = response?.spot?.touchedBarGroupIndex;
                if (index != null &&
                    index >= 0 &&
                    index < slices.length &&
                    !hiddenKeys.contains(slices[index].key)) {
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
                  reservedSize: hideSegmentAmounts ? 36 : 48,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= slices.length) {
                      return const SizedBox.shrink();
                    }
                    final slice = slices[i];
                    final muted = hiddenKeys.contains(slice.key);
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            slice.label,
                            maxLines: hideSegmentAmounts ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              height: 1.1,
                              color: muted
                                  ? theme.colorScheme.onSurfaceVariant
                                  : null,
                              decoration: muted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (!hideSegmentAmounts && !muted)
                            Text(
                              formatMoneyOf(
                                context,
                                ref,
                                amountMinor: slice.amountMinor,
                                currencyCode:
                                    slice.currencyCode ?? displayCurrency,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 8,
                                height: 1.1,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
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
                () {
                  final hidden = hiddenKeys.contains(slices[i].key);
                  final raw = slices[i].amountMinor.toDouble().abs();
                  final toY = hidden || raw == 0 ? 0.0001 : raw;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: toY,
                        color: hidden
                            ? slices[i].color.withValues(alpha: 0)
                            : slices[i].color,
                        width: barWidth,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }(),
            ],
          ),
          duration: kChartAnimDuration,
          curve: kChartAnimCurve,
        ),
      ),
    );
  }
}
