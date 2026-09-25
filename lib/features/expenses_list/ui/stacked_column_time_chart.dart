import 'dart:math' show max;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/chart_time_series.dart';
import 'package:valtero/features/expenses_list/ui/chart_anim.dart';
import 'package:valtero/features/expenses_list/ui/chart_axis_title.dart';
import 'package:valtero/features/expenses_list/ui/chart_overlay_controls.dart';
import 'package:valtero/features/expenses_list/ui/chart_tooltip_style.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/money_text.dart';

/// Stacked column chart with one bar per date bucket.
///
/// Pass the full [series] list plus [hiddenKeys]. Hidden stack segments
/// animate to zero height so the bar eases instead of jumping.
///
/// Hover / touch shows an in-plot tooltip (title + total + series lines).
class StackedColumnTimeChart extends ConsumerWidget {
  final List<ChartSeriesDef> series;
  final List<ChartTimeSeriesPoint> points;
  final Set<String> hiddenKeys;
  final String displayCurrency;
  final double chartHeight;
  final bool hideAmounts;
  final String? emptyMessage;

  const StackedColumnTimeChart({
    super.key,
    required this.series,
    required this.points,
    this.hiddenKeys = const {},
    required this.displayCurrency,
    this.chartHeight = 312,
    this.hideAmounts = false,
    this.emptyMessage,
  });

  int _visibleTotalAt(ChartTimeSeriesPoint point) {
    if (series.isEmpty) return point.totalMinor;
    var sum = 0;
    for (final s in series) {
      if (hiddenKeys.contains(s.key)) continue;
      sum += point.amountBySeriesKey[s.key] ?? 0;
    }
    return sum;
  }

  BarTooltipItem? _tooltipForIndex(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    int groupIndex,
  ) {
    if (groupIndex < 0 || groupIndex >= points.length) return null;
    final point = points[groupIndex];
    final visibleTotal = _visibleTotalAt(point);
    final children = <TextSpan>[];
    if (hideAmounts) {
      children.add(
        TextSpan(
          text: '\n${l10n.summaryTotal}',
          style: chartTooltipBodyStyle(context),
        ),
      );
    } else {
      if (visibleTotal > 0) {
        children.add(
          TextSpan(
            text:
                '\n${l10n.summaryTotal}: ${formatMoneyOf(context, ref, amountMinor: visibleTotal, currencyCode: displayCurrency)}',
            style: chartTooltipBodyStyle(context),
          ),
        );
      }
      for (final s in series) {
        if (hiddenKeys.contains(s.key)) continue;
        final amount = point.amountBySeriesKey[s.key] ?? 0;
        if (amount <= 0) continue;
        children.add(
          TextSpan(
            text:
                '\n${s.label}: ${formatMoneyOf(context, ref, amountMinor: amount, currencyCode: displayCurrency)}',
            style: chartTooltipBodyStyle(context, color: s.color),
          ),
        );
      }
    }
    return BarTooltipItem(
      point.dateLabel,
      chartTooltipTitleStyle(context),
      textAlign: TextAlign.left,
      children: children.isEmpty ? null : children,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (points.isEmpty) {
      return SizedBox(
        height: chartHeight,
        child: Center(child: Text(emptyMessage ?? l10n.noMatchingExpenses)),
      );
    }

    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      fontSize: 9,
      height: 1.1,
    );
    final maxY = points.fold<double>(
      0,
      (m, p) => max(m, _visibleTotalAt(p).toDouble()),
    );
    final barWidth = (28.0 - points.length * 1.2).clamp(6.0, 22.0);

    return SizedBox(
      height: chartHeight,
      child: Padding(
        padding: kChartPlotPadding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final plan = planChartAxisLabelsForTexts(
              labels: [for (final p in points) p.dateLabel],
              plotWidth: constraints.maxWidth,
              style: labelStyle,
            );
            return BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY <= 0 ? 1 : maxY * 1.12,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => chartTooltipBg(context),
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    maxContentWidth: 200,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                        _tooltipForIndex(context, ref, l10n, groupIndex),
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
                          labelCount: points.length,
                          plan: plan,
                        )) {
                          return const SizedBox.shrink();
                        }
                        return chartBottomAxisTitle(
                          meta: meta,
                          child: Text(
                            points[i].dateLabel,
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
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.5),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  for (var i = 0; i < points.length; i++)
                    () {
                      final visibleTotal = _visibleTotalAt(points[i]);
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: visibleTotal <= 0
                                ? 0.0001
                                : visibleTotal.toDouble(),
                            width: barWidth,
                            color: series.isEmpty
                                ? theme.colorScheme.onSurface
                                : null,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                            rodStackItems: series.isEmpty
                                ? const []
                                : _stackItemsForPoint(points[i]),
                          ),
                        ],
                      );
                    }(),
                ],
              ),
              duration: kChartAnimDuration,
              curve: kChartAnimCurve,
            );
          },
        ),
      ),
    );
  }

  List<BarChartRodStackItem> _stackItemsForPoint(ChartTimeSeriesPoint point) {
    var yFrom = 0.0;
    final items = <BarChartRodStackItem>[];
    for (final s in series) {
      final amount = hiddenKeys.contains(s.key)
          ? 0.0
          : (point.amountBySeriesKey[s.key] ?? 0).toDouble();
      // Keep a stack slot for every series so hide/show can tween.
      items.add(BarChartRodStackItem(yFrom, yFrom + amount, s.color));
      yFrom += amount;
    }
    return items;
  }
}
