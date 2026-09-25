import 'dart:math' show max;

/// How many axis indices to skip between shown bottom labels, and whether the
/// final index is forced on even when it is not a stride tick.
typedef ChartAxisLabelPlan = ({int stride, bool includeLast});

/// Picks a label stride so adjacent titles do not overlap on [plotWidth].
///
/// [maxLabelWidth] is the painted width of the longest label (same text style
/// as the axis). [minGap] is the minimum clear space between label boxes.
ChartAxisLabelPlan planChartAxisLabels({
  required int labelCount,
  required double plotWidth,
  required double maxLabelWidth,
  double minGap = 8,
}) {
  if (labelCount <= 1) {
    return (stride: 1, includeLast: true);
  }
  if (plotWidth <= 0 || maxLabelWidth <= 0) {
    final stride = max(1, (labelCount / 6).ceil());
    return (stride: stride, includeLast: true);
  }

  final slot = maxLabelWidth + minGap;
  final maxLabels = max(1, (plotWidth / slot).floor());

  var stride = 1;
  while (stride < labelCount) {
    final withLast = _shownCount(labelCount, stride, includeLast: true);
    if (withLast <= maxLabels) {
      break;
    }
    final withoutLast = _shownCount(labelCount, stride, includeLast: false);
    if (withoutLast <= maxLabels) {
      return (stride: stride, includeLast: false);
    }
    stride++;
  }

  final includeLast = !_lastCollidesWithPrevious(
    labelCount: labelCount,
    stride: stride,
    plotWidth: plotWidth,
    slot: slot,
  );
  return (stride: stride, includeLast: includeLast);
}

/// Whether bottom-axis index [index] should show a title for [plan].
bool shouldShowChartAxisLabel({
  required int index,
  required int labelCount,
  required ChartAxisLabelPlan plan,
}) {
  if (index < 0 || index >= labelCount) return false;
  if (index % plan.stride == 0) return true;
  if (plan.includeLast && index == labelCount - 1) return true;
  return false;
}

int _shownCount(int labelCount, int stride, {required bool includeLast}) {
  var count = 0;
  for (var i = 0; i < labelCount; i++) {
    if (i % stride == 0) {
      count++;
    } else if (includeLast && i == labelCount - 1) {
      count++;
    }
  }
  return count;
}

bool _lastCollidesWithPrevious({
  required int labelCount,
  required int stride,
  required double plotWidth,
  required double slot,
}) {
  if (labelCount <= 1) return false;
  final last = labelCount - 1;
  if (last % stride == 0) return false;
  final previous = (last ~/ stride) * stride;
  final span = labelCount - 1;
  final pixelGap = ((last - previous) / span) * plotWidth;
  return pixelGap < slot;
}
