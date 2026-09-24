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

/// Trackpad / pointer-scroll travel that commits one interactive slide step
/// (see [shouldCommitDragCycle] in `drag_cycle_settle.dart`).
const kChartHorizontalCycleThreshold = 56.0;
