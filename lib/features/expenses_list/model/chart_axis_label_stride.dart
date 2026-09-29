import 'dart:math' show max, pi;

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

/// Pitch between neighboring columns, or between neighboring line-chart points.
/// The same value on every chart so a bar does not change width with the label.
const kChartColumnSlot = 36.0;

/// Width of a single column rod. Cash-flow groups keep two narrower rods
/// inside the same [kChartColumnSlot].
const kChartBarWidth = 16.0;

/// Fixed left/right inset so the first column is not flush with the edge.
const kChartAngledEdgeInset = 12.0;

/// Empty slot inside the plot, before the first column. A 45° title hangs
/// left of its bar; this keeps that title inside the grid instead of in a
/// margin outside it.
const kChartAngledLeading = kChartColumnSlot;

/// −45°: the title reads left to right and rises from its column.
const kChartAxisLabelAngle = -pi / 4;

/// Longest painted width of a rotated title. Wider names ellipsize so they
/// do not run into the next column.
const kChartAngledLabelMaxWidth = 64.0;

/// Gap between the column foot and the rotated title.
const kChartAngledLabelGap = 12.0;

/// Fixed bottom band for the capped 45° titles.
const kChartAngledLabelExtent = 72.0;

/// Chart width for [count] columns, or for [count] line points when [points]
/// is true. Does not depend on label length.
double chartAxisTrackWidth(int count, {bool points = false}) {
  if (count <= 0) return 0;
  final span = points ? (count <= 1 ? 1 : count - 1) : count;
  return span * kChartColumnSlot +
      kChartAngledLeading +
      2 * kChartAngledEdgeInset;
}

/// Width of a transparent first group so the next column starts
/// [kChartAngledLeading] from the left of the plot.
double chartLeadingGroupWidth(double groupWidth) {
  final width = kChartAngledLeading - chartGroupsSpace(groupWidth);
  return width < 1 ? 1 : width;
}

/// Line charts start at this x so the first point sits one slot in from the
/// left edge of the grid.
const kChartLineMinX = -1.0;

/// Space between bar groups so their centers stay [kChartColumnSlot] apart
/// when the chart is wider than the groups and they stay packed at the start.
double chartGroupsSpace(double groupWidth) {
  final gap = kChartColumnSlot - groupWidth;
  return gap < 0 ? 0 : gap;
}

/// Line-chart [maxX] so points stay [kChartColumnSlot] apart. [kChartLineMinX]
/// reserves one slot of grid left of the first point; spare plot width stays
/// to the right of the last point.
double chartLineMaxX({required int pointCount, required double plotWidth}) {
  final last = pointCount <= 1 ? 1.0 : (pointCount - 1).toDouble();
  if (plotWidth <= 0 || kChartColumnSlot <= 0) return last;
  final fitted = plotWidth / kChartColumnSlot + kChartLineMinX;
  return fitted > last ? fitted : last;
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
