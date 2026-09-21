import 'dart:math' as math;

/// Radius of the empty hole in the donut's center. Ring thickness is
/// [kDonutSectionRadius]; both are preferred sizes and may shrink via
/// [fitDonutChartRadii] so the pie stays inside the plot box.
const kDonutCenterSpaceRadius = 58.0;

/// Preferred ring thickness (outer radius = center + this).
const kDonutSectionRadius = 86.0;

/// Keep a little air between the fitted ring and the plot clip edge.
const kDonutFitEdgeInset = 2.0;

/// Fraction of the hole diameter used by the centered total label.
const kDonutCenterTotalWidthFactor = 0.82;

/// Default minimum arc for a visible donut segment (~3.9% of the circle).
/// Keeps on-segment labels readable for tiny slices without changing
/// legend/total amounts (those still use real [DonutChartSlice.amountMinor]).
const kMinDonutSweepDegrees = 14.0;

/// Fitted hole + ring radii for a donut that must stay inside the plot box.
class DonutChartRadii {
  final double centerSpaceRadius;
  final double sectionRadius;

  const DonutChartRadii({
    required this.centerSpaceRadius,
    required this.sectionRadius,
  });

  double get outerRadius => centerSpaceRadius + sectionRadius;
}

/// Scales preferred donut radii down so `center + section` fits in the
/// shorter side of [width] × [height]. Never scales up.
DonutChartRadii fitDonutChartRadii({
  required double width,
  required double height,
  double preferredCenter = kDonutCenterSpaceRadius,
  double preferredSection = kDonutSectionRadius,
  double edgeInset = kDonutFitEdgeInset,
}) {
  final preferred = DonutChartRadii(
    centerSpaceRadius: preferredCenter,
    sectionRadius: preferredSection,
  );
  if (!width.isFinite || !height.isFinite) {
    return preferred;
  }
  final shortest = math.min(width, height);
  final maxOuter = shortest / 2 - edgeInset;
  if (maxOuter <= 0) {
    return const DonutChartRadii(centerSpaceRadius: 0, sectionRadius: 0);
  }
  final preferredOuter = preferred.outerRadius;
  if (preferredOuter <= maxOuter) return preferred;
  final scale = maxOuter / preferredOuter;
  return DonutChartRadii(
    centerSpaceRadius: preferredCenter * scale,
    sectionRadius: preferredSection * scale,
  );
}

/// Floors each **visible** value so no visible segment sweeps less than
/// [minSweepDegrees]; larger segments are left untouched. Entries marked
/// [hidden] keep their raw value (typically near-zero for legend toggle
/// tweens) and are excluded from the floor math so they do not leave a gap.
///
/// Only affects pie layout proportions — labels/legend/center total keep
/// using real amounts.
List<double> computeDonutSectionValues(
  List<double> rawValues, {
  double minSweepDegrees = kMinDonutSweepDegrees,
  List<bool>? hidden,
}) {
  assert(
    hidden == null || hidden.length == rawValues.length,
    'hidden mask must match rawValues length',
  );
  if (rawValues.isEmpty) return rawValues;

  var visibleTotal = 0.0;
  for (var i = 0; i < rawValues.length; i++) {
    if (hidden != null && hidden[i]) continue;
    visibleTotal += rawValues[i];
  }
  if (visibleTotal <= 0) return List<double>.from(rawValues);

  final minValue = visibleTotal * minSweepDegrees / 360;
  return [
    for (var i = 0; i < rawValues.length; i++)
      if (hidden != null && hidden[i])
        rawValues[i]
      else
        rawValues[i] < minValue ? minValue : rawValues[i],
  ];
}
