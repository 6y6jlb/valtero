import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/tag/model/tag_hierarchy.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/ui/chart_anim.dart';
import 'package:valtero/features/expenses_list/ui/chart_axis_scroll.dart';
import 'package:valtero/features/expenses_list/ui/chart_axis_title.dart';
import 'package:valtero/features/expenses_list/ui/chart_overlay_controls.dart';
import 'package:valtero/features/expenses_list/ui/chart_tooltip_style.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/money_text.dart';

/// Vertical column chart for the same [DonutChartSlice] breakdown data.
///
/// Pass every slice plus [hiddenKeys]. Hidden bars animate to zero height.
/// Hover / touch shows an in-plot tooltip.
class ColumnBreakdownChart extends ConsumerWidget {
  final List<DonutChartSlice> slices;
  final Set<String> hiddenKeys;
  final String displayCurrency;
  final ValueChanged<DonutChartSlice>? onSegmentTap;
  final bool hideSegmentAmounts;
  final double chartHeight;
  final String? emptyMessage;

  const ColumnBreakdownChart({
    super.key,
    required this.slices,
    this.hiddenKeys = const {},
    required this.displayCurrency,
    this.onSegmentTap,
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
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      fontSize: 9,
      height: 1.1,
    );
    final amountStyle = theme.textTheme.labelSmall?.copyWith(
      fontSize: 8,
      height: 1.1,
      fontWeight: FontWeight.w600,
    );
    final contentWidth = chartAxisTrackWidth(slices.length);

    return SizedBox(
      height: chartHeight,
      child: Padding(
        padding: kChartPlotPadding,
        child: ChartAxisScroll(
          contentWidth: contentWidth,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.start,
              groupsSpace: chartGroupsSpace(kChartBarWidth),
              maxY: maxY <= 0 ? 1 : maxY * 1.12,
              minY: 0,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => chartTooltipBg(context),
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final i = group.x.toInt();
                    if (i < 0 || i >= slices.length) {
                      return null;
                    }
                    final slice = slices[i];
                    if (hiddenKeys.contains(slice.key)) return null;
                    return chartBarTooltipItem(
                      context: context,
                      title: slice.label,
                      amountOrLabel: hideSegmentAmounts
                          ? null
                          : formatMoneyOf(
                              context,
                              ref,
                              amountMinor: slice.amountMinor,
                              currencyCode:
                                  slice.currencyCode ?? displayCurrency,
                            ),
                      accent: slice.color,
                    );
                  },
                ),
                touchCallback: (event, response) {
                  if (onSegmentTap == null) return;
                  if (event is! FlTapUpEvent) return;
                  final index = response?.spot?.touchedBarGroup.x.toInt();
                  if (index == null || index < 0 || index >= slices.length) {
                    return;
                  }
                  if (hiddenKeys.contains(slices[index].key)) return;
                  onSegmentTap!(slices[index]);
                },
                mouseCursorResolver: (event, response) {
                  if (onSegmentTap == null) return SystemMouseCursors.basic;
                  final index = response?.spot?.touchedBarGroup.x.toInt();
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
                rightTitles: chartAxisEdgeSpacer(
                  reservedSize: kChartAngledEdgeInset,
                ),
                leftTitles: chartAxisEdgeSpacer(
                  reservedSize: kChartAngledEdgeInset,
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: kChartAngledLabelExtent,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= slices.length) {
                        return const SizedBox.shrink();
                      }
                      final slice = slices[i];
                      final muted = hiddenKeys.contains(slice.key);
                      return chartAngledAxisTitle(
                        meta: meta,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              categoryAxisTitle(slice.label),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: labelStyle?.copyWith(
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
                                softWrap: false,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: amountStyle?.copyWith(
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
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                chartLeadingSpacerGroup(kChartBarWidth),
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
                          width: kChartBarWidth,
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
      ),
    );
  }
}
