/// Default minimum arc for a visible donut segment (~3.9% of the circle).
/// Keeps on-segment labels readable for tiny slices without changing
/// legend/total amounts (those still use real [DonutChartSlice.amountMinor]).
const kMinDonutSweepDegrees = 14.0;

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
