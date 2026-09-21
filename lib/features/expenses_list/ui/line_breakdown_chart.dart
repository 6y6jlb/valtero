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

/// Multi-series line chart over time with a bold total line.
///
/// Pass the full [series] list plus [hiddenKeys]. Hidden series animate to
/// zero instead of being removed, so the plot eases instead of jumping.
/// The total line is the sum of non-hidden series at each point.
///
/// Hover / touch details are reported via [onSelectionChanged] so the parent
/// can render them under the plot (avoids covering overlay actions).
class LineBreakdownChart extends ConsumerWidget {
  final List<ChartSeriesDef> series;
  final List<ChartTimeSeriesPoint> points;
  final Set<String> hiddenKeys;
  final String displayCurrency;
  final double chartHeight;
  final bool hideAmounts;
  final String? emptyMessage;
  final Color? totalColor;
  final ValueChanged<ChartSelectionDetail?>? onSelectionChanged;

  const LineBreakdownChart({
    super.key,
    required this.series,
    required this.points,
    this.hiddenKeys = const {},
    required this.displayCurrency,
    this.chartHeight = 312,
    this.hideAmounts = false,
    this.emptyMessage,
    this.totalColor,
    this.onSelectionChanged,
  });

  bool get _hideTotalLine => hiddenKeys.contains(kChartTotalSeriesKey);

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
    Color totalLineColor,
    int i,
    List<int> visibleTotals,
  ) {
    if (i < 0 || i >= points.length) return null;
    final point = points[i];
    final visibleTotal = visibleTotals[i];
    final lines = <ChartSelectionLine>[];
    if (!_hideTotalLine && visibleTotal > 0) {
      lines.add(
        ChartSelectionLine(
          label: l10n.summaryTotal,
          amountText: hideAmounts
              ? null
              : formatMoneyOf(
                  context,
                  ref,
                  amountMinor: visibleTotal,
                  currencyCode: displayCurrency,
                ),
          color: totalLineColor,
        ),
      );
    }
    for (final s in series) {
      if (hiddenKeys.contains(s.key)) continue;
      final amountMinor = point.amountBySeriesKey[s.key] ?? 0;
      if (amountMinor <= 0) continue;
      lines.add(
        ChartSelectionLine(
          label: s.label,
          amountText: hideAmounts
              ? null
              : formatMoneyOf(
                  context,
                  ref,
                  amountMinor: amountMinor,
                  currencyCode: displayCurrency,
                ),
          color: s.color,
        ),
      );
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
    final totalLineColor = totalColor ?? theme.colorScheme.onSurface;
    final visibleTotals = [
      for (final point in points) _visibleTotalAt(point),
    ];

    var maxY = 0.0;
    for (var i = 0; i < points.length; i++) {
      maxY = max(maxY, visibleTotals[i].toDouble());
      for (final s in series) {
        if (hiddenKeys.contains(s.key)) continue;
        maxY = max(
          maxY,
          (points[i].amountBySeriesKey[s.key] ?? 0).toDouble(),
        );
      }
    }

    final lineBars = <LineChartBarData>[
      for (final s in series)
        () {
          final hidden = hiddenKeys.contains(s.key);
          return LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(
                  i.toDouble(),
                  hidden
                      ? 0
                      : (points[i].amountBySeriesKey[s.key] ?? 0).toDouble(),
                ),
            ],
            isCurved: true,
            preventCurveOverShooting: true,
            color: hidden ? s.color.withValues(alpha: 0) : s.color,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          );
        }(),
      // Always keep the total bar so show/hide tweens instead of remounting.
      LineChartBarData(
        spots: [
          for (var i = 0; i < points.length; i++)
            FlSpot(
              i.toDouble(),
              _hideTotalLine ? 0 : visibleTotals[i].toDouble(),
            ),
        ],
        isCurved: true,
        preventCurveOverShooting: true,
        color: _hideTotalLine
            ? totalLineColor.withValues(alpha: 0)
            : totalLineColor,
        barWidth: 3.5,
        dotData: const FlDotData(show: false),
      ),
    ];

    return SizedBox(
      height: chartHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, kChartOverlayTopInset, 12, 4),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: points.length <= 1 ? 1 : (points.length - 1).toDouble(),
            minY: 0,
            maxY: maxY <= 0 ? 1 : maxY * 1.12,
            lineTouchData: LineTouchData(
              enabled: true,
              // Keep spot indicators; selection text lives under the plot.
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) =>
                    touchedSpots.map((_) => null).toList(),
              ),
              touchCallback: (event, response) {
                final onChanged = onSelectionChanged;
                if (onChanged == null) return;
                final spots = response?.lineBarSpots;
                if (spots == null || spots.isEmpty) {
                  if (event is FlPointerExitEvent) onChanged(null);
                  return;
                }
                final i = spots.first.x.round();
                onChanged(
                  _detailForIndex(
                    context,
                    ref,
                    l10n,
                    totalLineColor,
                    i,
                    visibleTotals,
                  ),
                );
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
            lineBarsData: lineBars,
          ),
          duration: kChartAnimDuration,
          curve: kChartAnimCurve,
        ),
      ),
    );
  }
}
