import 'dart:math' show max, min;

/// How many axis indices to skip between shown bottom labels, and whether the
/// final index is forced on even when it is not a stride tick.
typedef ChartAxisLabelPlan = ({int stride, bool includeLast});

/// Axis plan plus horizontal inset so centered edge titles are not clipped.
typedef ChartAxisLabelLayout = ({ChartAxisLabelPlan plan, double edgeInset});

/// Picks a label stride so adjacent titles do not overlap on [plotWidth].
///
/// [plotWidth] should be the bottom-axis track only (chart width minus left /
/// right [edgeInset]). Tick pitch is `plotWidth / labelCount` — the tighter
/// bar `spaceAround` spacing — so line charts stay a bit conservative too.
///
/// [maxLabelWidth] is the painted width of the longest label. [minGap] is the
/// clear space required between neighboring label boxes.
ChartAxisLabelPlan planChartAxisLabels({
  required int labelCount,
  required double plotWidth,
  required double maxLabelWidth,
  double minGap = 12,
}) {
  if (labelCount <= 1) {
    return (stride: 1, includeLast: true);
  }
  if (plotWidth <= 0 || maxLabelWidth <= 0) {
    final stride = max(1, (labelCount / 6).ceil());
    return (stride: stride, includeLast: true);
  }

  final slot = maxLabelWidth + minGap;

  var stride = 1;
  while (stride < labelCount) {
    if (_shownLabelsFit(
      labelCount: labelCount,
      stride: stride,
      includeLast: true,
      plotWidth: plotWidth,
      slot: slot,
    )) {
      break;
    }
    if (_shownLabelsFit(
      labelCount: labelCount,
      stride: stride,
      includeLast: false,
      plotWidth: plotWidth,
      slot: slot,
    )) {
      return (stride: stride, includeLast: false);
    }
    stride++;
  }

  final includeLast = _shownLabelsFit(
    labelCount: labelCount,
    stride: stride,
    includeLast: true,
    plotWidth: plotWidth,
    slot: slot,
  );
  return (stride: stride, includeLast: includeLast);
}

/// Long axis titles wrap or ellipsize past this so one subcategory name cannot
/// widen every column. Extra text uses a second line inside the slot.
const kChartAxisLabelMaxWidth = 96.0;

/// Clear space kept between neighboring bottom-axis title boxes.
const kChartAxisLabelGap = 8.0;

/// Minimum plot width so [labelCount] bottom titles of [maxLabelWidth] do not
/// overlap. Each slot is at least [minSlot].
double chartPlotWidthForBottomLabels({
  required int labelCount,
  required double maxLabelWidth,
  double minGap = kChartAxisLabelGap,
  double minSlot = 40,
}) {
  if (labelCount <= 0) return 0;
  final capped = min(max(maxLabelWidth, 0), kChartAxisLabelMaxWidth);
  final slot = max(capped + minGap, minSlot);
  return labelCount * slot;
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

List<int> _shownIndices(
  int labelCount,
  int stride, {
  required bool includeLast,
}) {
  final indices = <int>[];
  for (var i = 0; i < labelCount; i++) {
    if (i % stride == 0) {
      indices.add(i);
    } else if (includeLast && i == labelCount - 1) {
      indices.add(i);
    }
  }
  return indices;
}

/// Centers are [pitch] apart per index step (`plotWidth / labelCount`).
bool _shownLabelsFit({
  required int labelCount,
  required int stride,
  required bool includeLast,
  required double plotWidth,
  required double slot,
}) {
  final indices = _shownIndices(labelCount, stride, includeLast: includeLast);
  if (indices.length <= 1) return true;
  final pitch = plotWidth / labelCount;
  for (var k = 0; k < indices.length - 1; k++) {
    final gap = (indices[k + 1] - indices[k]) * pitch;
    if (gap < slot) return false;
  }
  return true;
}
