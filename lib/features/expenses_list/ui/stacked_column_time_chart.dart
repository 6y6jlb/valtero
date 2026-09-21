import 'dart:math' show max;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/chart_time_series.dart';
import 'package:valtero/features/expenses_list/ui/chart_anim.dart';
import 'package:valtero/features/expenses_list/ui/chart_overlay_controls.dart';
import 'package:valtero/features/expenses_list/ui/chart_selection_panel.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/money_text.dart';

/// Stacked column chart with one bar per date bucket.
///
/// Pass the full [series] list plus [hiddenKeys]. Hidden stack segments
/// animate to zero height so the bar eases instead of jumping.
///
/// Hover / touch details are reported via [onSelectionChanged] so the parent
/// can render them under the plot (avoids covering overlay actions).
class StackedColumnTimeChart extends ConsumerWidget {
  final List<ChartSeriesDef> series;
  final List<ChartTimeSeriesPoint> points;
  final Set<String> hiddenKeys;
  final String displayCurrency;
  final double chartHeight;
  final bool hideAmounts;
  final String? emptyMessage;
  final ValueChanged<ChartSelectionDetail?>? onSelectionChanged;

  const StackedColumnTimeChart({
    super.key,
    required this.series,
    required this.points,
    this.hiddenKeys = const {},
    required this.displayCurrency,
    this.chartHeight = 312,
    this.hideAmounts = false,
    this.emptyMessage,
    this.onSelectionChanged,
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

  ChartSelectionDetail? _detailForIndex(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    int groupIndex,
  ) {
    if (groupIndex < 0 || groupIndex >= points.length) return null;
    final point = points[groupIndex];
    final visibleTotal = _visibleTotalAt(point);
    final lines = <ChartSelectionLine>[];
    if (hideAmounts) {
      lines.add(ChartSelectionLine(label: l10n.summaryTotal));
    } else {
      if (visibleTotal > 0) {
        lines.add(
          ChartSelectionLine(
            label: l10n.summaryTotal,
            amountText: formatMoneyOf(
              context,
              ref,
              amountMinor: visibleTotal,
              currencyCode: displayCurrency,
            ),
          ),
        );
      }
      for (final s in series) {
        if (hiddenKeys.contains(s.key)) continue;
        final amount = point.amountBySeriesKey[s.key] ?? 0;
        if (amount <= 0) continue;
        lines.add(
          ChartSelectionLine(
            label: s.label,
            amountText: formatMoneyOf(
              context,
              ref,
              amountMinor: amount,
              currencyCode: displayCurrency,
            ),
            color: s.color,
          ),
        );
      }
    }
    return ChartSelectionDetail(title: point.dateLabel, lines: lines);
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

    final stride = max(1, (points.length / 6).ceil());
    final maxY = points.fold<double>(
      0,
      (m, p) => max(m, _visibleTotalAt(p).toDouble()),
    );
    final barWidth = (28.0 - points.length * 1.2).clamp(6.0, 22.0);

    return SizedBox(
      height: chartHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, kChartOverlayTopInset, 12, 4),
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
                final onChanged = onSelectionChanged;
                if (onChanged == null) return;
                final index = response?.spot?.touchedBarGroupIndex;
                if (index == null || index < 0 || index >= points.length) {
                  if (event is FlPointerExitEvent) onChanged(null);
                  return;
                }
                onChanged(_detailForIndex(context, ref, l10n, index));
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
                    if (i < 0 || i >= points.length) {
                      return const SizedBox.shrink();
                    }
                    if (i % stride != 0 && i != points.length - 1) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        points[i].dateLabel,
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
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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
