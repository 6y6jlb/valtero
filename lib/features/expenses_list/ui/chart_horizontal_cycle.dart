import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/cycle_index.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';

export 'package:valtero/features/expenses_list/model/cycle_index.dart'
    show kChartHorizontalCycleThreshold;

/// Horizontal swipe / trackpad scroll that steps a cycle (breakdown or tab).
///
/// Vertical scroll is ignored so page lists keep scrolling. One step per
/// [kChartHorizontalCycleThreshold] of accumulated horizontal travel.
///
/// Swipe left / content-scroll right → [onNext]; opposite → [onPrevious].
///
/// Nested cycles: the deepest [ChartHorizontalCycle] under the pointer wins
/// pointer-scroll via [PointerSignalResolver]; horizontal drag uses the
/// gesture arena (child typically wins when the drag starts on it).
class ChartHorizontalCycle extends StatefulWidget {
  final Widget child;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const ChartHorizontalCycle({
    super.key,
    required this.child,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<ChartHorizontalCycle> createState() => _ChartHorizontalCycleState();
}

class _ChartHorizontalCycleState extends State<ChartHorizontalCycle> {
  double _dragAccum = 0;
  double _pointerAccum = 0;

  void _apply(HorizontalCycleAccum result, {required bool fromPointerScroll}) {
    for (var i = 0; i < result.steps; i++) {
      if (result.forward) {
        widget.onNext();
      } else {
        widget.onPrevious();
      }
    }
    if (fromPointerScroll) {
      _pointerAccum = result.accum;
    } else {
      _dragAccum = result.accum;
    }
  }

  void _consumeDelta(double dx, {required bool fromPointerScroll}) {
    final result = consumeHorizontalCycleDelta(
      accum: fromPointerScroll ? _pointerAccum : _dragAccum,
      dx: dx,
    );
    _apply(result, fromPointerScroll: fromPointerScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is! PointerScrollEvent) return;
        final dx = event.scrollDelta.dx;
        final dy = event.scrollDelta.dy;
        if (dx.abs() <= dy.abs() || dx == 0) return;
        // First registrant in hit-test order (deepest) wins.
        GestureBinding.instance.pointerSignalResolver.register(event, (e) {
          if (e is! PointerScrollEvent) return;
          _consumeDelta(e.scrollDelta.dx, fromPointerScroll: true);
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (_) {
          _dragAccum = 0;
        },
        onHorizontalDragUpdate: (details) {
          _consumeDelta(details.delta.dx, fromPointerScroll: false);
        },
        onHorizontalDragEnd: (_) {
          _dragAccum = 0;
        },
        onHorizontalDragCancel: () {
          _dragAccum = 0;
        },
        child: widget.child,
      ),
    );
  }
}

/// Wraps [child] so a horizontal cycle steps [breakdown] through [order].
Widget wrapChartBreakdownCycle({
  required Widget child,
  required ExpenseChartBreakdown? breakdown,
  required ValueChanged<ExpenseChartBreakdown>? onChanged,
  required List<ExpenseChartBreakdown> order,
}) {
  if (breakdown == null || onChanged == null) return child;
  return ChartHorizontalCycle(
    onNext: () => onChanged(cycleIndex(order, breakdown, forward: true)),
    onPrevious: () => onChanged(cycleIndex(order, breakdown, forward: false)),
    child: child,
  );
}
