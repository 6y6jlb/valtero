/// Default minimum arc for a visible donut segment (~3.9% of the circle).
/// Keeps on-segment labels readable for tiny slices without changing
/// legend/total amounts (those still use real [DonutChartSlice.amountMinor]).
const kMinDonutSweepDegrees = 14.0;

/// Floors each value so no visible segment sweeps less than
/// [minSweepDegrees]; larger segments are left untouched. Only affects pie
/// layout proportions — labels/legend/center total keep using real amounts.
List<double> computeDonutSectionValues(
  List<double> rawValues, {
  double minSweepDegrees = kMinDonutSweepDegrees,
}) {
  if (rawValues.isEmpty) return rawValues;
  final total = rawValues.fold<double>(0, (a, b) => a + b);
  if (total <= 0) return List<double>.from(rawValues);
  final minValue = total * minSweepDegrees / 360;
  return [for (final v in rawValues) v < minValue ? minValue : v];
}
