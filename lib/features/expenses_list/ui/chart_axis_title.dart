import 'dart:math' show max;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/chart_axis_label_stride.dart';

export 'package:valtero/features/expenses_list/model/chart_axis_label_stride.dart'
    show
        ChartAxisLabelLayout,
        ChartAxisLabelPlan,
        chartPlotWidthForBottomLabels,
        kChartAxisLabelGap,
        kChartAxisLabelMaxWidth,
        planChartAxisLabels,
        shouldShowChartAxisLabel;

/// Bottom-axis title centered on its tick (no fitInside — that squeezes bar
/// titles toward the middle when groups use spaceAround).
Widget chartBottomAxisTitle({
  required TitleMeta meta,
  required Widget child,
  double space = 6,
}) {
  return SideTitleWidget(meta: meta, space: space, child: child);
}

/// Empty left/right axis spacer so centered edge dates are not clipped.
///
/// fl_chart only applies [SideTitles.reservedSize] when [SideTitles.showTitles]
/// is true (`AxisTitles.showSideTitles`), so we enable titles and render
/// nothing.
AxisTitles chartAxisEdgeSpacer({double reservedSize = 0}) {
  return AxisTitles(
    sideTitles: SideTitles(
      showTitles: reservedSize > 0,
      reservedSize: reservedSize,
      getTitlesWidget: (value, meta) => const SizedBox.shrink(),
    ),
  );
}

/// Painted width of [text] in [style] (single line).
double measureChartAxisLabelWidth(String text, TextStyle? style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.width;
}

/// Plans bottom labels and the left/right inset for [chartWidth].
ChartAxisLabelLayout planChartAxisLabelsForTexts({
  required List<String> labels,
  required double chartWidth,
  required TextStyle? style,
  double minGap = 12,
}) {
  var maxWidth = 0.0;
  for (final label in labels) {
    final w = measureChartAxisLabelWidth(label, style);
    if (w > maxWidth) maxWidth = w;
  }
  final edgeInset = maxWidth / 2;
  final trackWidth = max(0.0, chartWidth - 2 * edgeInset);
  return (
    plan: planChartAxisLabels(
      labelCount: labels.length,
      plotWidth: trackWidth,
      maxLabelWidth: maxWidth,
      minGap: minGap,
    ),
    edgeInset: edgeInset,
  );
}
