import 'package:valtero/features/expenses_list/model/cycle_index.dart';

/// Fraction of page width a drag must cover to commit (≈30%).
const kDragCycleCommitFraction = 0.3;

/// Horizontal velocity (px/s) that commits even below the distance threshold.
const kDragCycleVelocityCommit = 700.0;

/// Whether a finished drag / burst should advance the cycle.
///
/// [offset] is the translation of the current page: negative means the user
/// swiped left (next). [velocity] is pixels/second along the same axis
/// (negative = leftward).
///
/// For trackpad / pointer-scroll bursts, pass [fromTrackpadBurst] so a shorter
/// absolute travel ([kChartHorizontalCycleThreshold]) is enough to commit.
bool shouldCommitDragCycle({
  required double offset,
  required double width,
  double velocity = 0,
  bool fromTrackpadBurst = false,
  double commitFraction = kDragCycleCommitFraction,
  double velocityThreshold = kDragCycleVelocityCommit,
  double trackpadThreshold = kChartHorizontalCycleThreshold,
}) {
  if (offset == 0) return false;
  final abs = offset.abs();
  if (fromTrackpadBurst && abs >= trackpadThreshold) return true;
  if (width > 0 && abs >= width * commitFraction) return true;
  if (offset < 0 && velocity <= -velocityThreshold) return true;
  if (offset > 0 && velocity >= velocityThreshold) return true;
  return false;
}

/// Negative [offset] → next (forward); positive → previous.
bool dragCycleForwardFromOffset(double offset) => offset < 0;

/// Clamps a live drag offset to one page width in either direction.
double clampDragCycleOffset(double offset, double width) {
  if (width <= 0) return offset;
  if (offset > width) return width;
  if (offset < -width) return -width;
  return offset;
}

/// Target offset after a commit settle (full page in the drag direction).
double dragCycleCommitTarget(double offset, double width) {
  if (width <= 0) return 0;
  return offset < 0 ? -width : width;
}
