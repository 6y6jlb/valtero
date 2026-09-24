/// Whether stepping from [from] to [to] in a circular [items] list should
/// animate as a forward (next) slide.
///
/// Uses the shorter arc along the circle; ties prefer forward. Unknown [from]
/// or [to] also prefer forward.
bool cycleTransitionForward<T>(List<T> items, T from, T to) {
  if (identical(from, to) || from == to) return true;
  final i = items.indexOf(from);
  final j = items.indexOf(to);
  if (i < 0 || j < 0 || items.isEmpty) return true;
  final n = items.length;
  final forwardDist = (j - i + n) % n;
  final backwardDist = (i - j + n) % n;
  return forwardDist <= backwardDist;
}
