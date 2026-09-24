import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Bottom-axis title kept inside the plot so edge labels are not clipped by
/// the surrounding [InteractiveSlidePager] / [ClipRect].
Widget chartBottomAxisTitle({
  required TitleMeta meta,
  required Widget child,
  double space = 6,
}) {
  return SideTitleWidget(
    meta: meta,
    space: space,
    fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
    child: child,
  );
}
