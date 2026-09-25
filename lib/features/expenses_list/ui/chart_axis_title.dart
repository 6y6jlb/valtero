import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/chart_axis_label_stride.dart';

export 'package:valtero/features/expenses_list/model/chart_axis_label_stride.dart'
    show ChartAxisLabelPlan, planChartAxisLabels, shouldShowChartAxisLabel;

/// Bottom-axis title with default fl_chart alignment (no fitInside shift).
Widget chartBottomAxisTitle({
  required TitleMeta meta,
  required Widget child,
  double space = 6,
}) {
  return SideTitleWidget(
    meta: meta,
    space: space,
    child: child,
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

/// Plans bottom labels from the longest string among [labels].
ChartAxisLabelPlan planChartAxisLabelsForTexts({
  required List<String> labels,
  required double plotWidth,
  required TextStyle? style,
  double minGap = 8,
}) {
  var maxWidth = 0.0;
  for (final label in labels) {
    final w = measureChartAxisLabelWidth(label, style);
    if (w > maxWidth) maxWidth = w;
  }
  return planChartAxisLabels(
    labelCount: labels.length,
    plotWidth: plotWidth,
    maxLabelWidth: maxWidth,
    minGap: minGap,
  );
}
