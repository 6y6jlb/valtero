/// Steps [current] forward or backward through [items], wrapping at the ends.
///
/// When [current] is missing from [items], returns the first item (or [current]
/// if the list is empty).
T cycleIndex<T>(List<T> items, T current, {required bool forward}) {
  if (items.isEmpty) return current;
  final i = items.indexOf(current);
  if (i < 0) return items.first;
  final next = forward
      ? (i + 1) % items.length
      : (i - 1 + items.length) % items.length;
  return items[next];
}

/// Default distance a horizontal drag / scroll must travel for one cycle step.
const kChartHorizontalCycleThreshold = 56.0;

/// Result of folding one horizontal delta into a cycle accumulator.
typedef HorizontalCycleAccum = ({double accum, int steps, bool forward});

/// Accumulates [dx] into [accum] and reports how many cycle steps to fire.
///
/// Negative [dx] (swipe left / content scrolls right) → [HorizontalCycleAccum.forward]
/// is true (call onNext). Positive [dx] → previous. Remainder stays in [accum].
HorizontalCycleAccum consumeHorizontalCycleDelta({
  required double accum,
  required double dx,
  double threshold = kChartHorizontalCycleThreshold,
}) {
  final nextAccum = accum + dx;
  if (nextAccum.abs() < threshold) {
    return (accum: nextAccum, steps: 0, forward: nextAccum < 0);
  }
  final steps = (nextAccum.abs() / threshold).floor();
  final forward = nextAccum < 0;
  final remainder =
      nextAccum.sign * (nextAccum.abs() % threshold);
  return (accum: remainder, steps: steps, forward: forward);
}
