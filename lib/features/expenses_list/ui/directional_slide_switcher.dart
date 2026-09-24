import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/drag_cycle_settle.dart';

/// Duration for tab / chart-breakdown parallel slide settle / spring-back.
const kDirectionalSlideDuration = Duration(milliseconds: 280);

/// Gesture-driven parallel horizontal slide between cycle pages.
///
/// While the user drags (or scrolls horizontally), [child] moves with the
/// finger and an optional [neighborBuilder] page enters from the opposite
/// side. On release past the commit threshold the pager finishes the slide
/// then calls [onNext] / [onPrevious]. Otherwise it springs back.
///
/// External [pageKey] changes (tab / icon taps) play the same parallel slide
/// using the previous child as the outgoing page. Pass [externalForward] so
/// the exit direction matches the circular step.
///
/// Nested pagers: the deepest under the pointer wins pointer-scroll via
/// [PointerSignalResolver]; horizontal drag uses the gesture arena.
class InteractiveSlidePager extends StatefulWidget {
  final Object pageKey;
  final Widget child;

  /// Builds a peek of the page that would appear when dragging [forward].
  /// When null, an empty box is used so the current page still slides.
  final Widget Function(bool forward)? neighborBuilder;

  final VoidCallback onNext;
  final VoidCallback onPrevious;

  /// Direction of the last external [pageKey] change (true = next / from right).
  final bool externalForward;

  /// When true, expands to fill the parent (list / dashboard body).
  final bool expand;

  /// When false, gestures are disabled (still animates on [pageKey] change).
  final bool enableGestures;

  final Duration duration;
  final Curve curve;

  const InteractiveSlidePager({
    super.key,
    required this.pageKey,
    required this.child,
    required this.onNext,
    required this.onPrevious,
    this.neighborBuilder,
    this.externalForward = true,
    this.expand = false,
    this.enableGestures = true,
    this.duration = kDirectionalSlideDuration,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<InteractiveSlidePager> createState() => _InteractiveSlidePagerState();
}

class _InteractiveSlidePagerState extends State<InteractiveSlidePager>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  double _offset = 0;
  double _width = 0;
  double _animFrom = 0;
  double _animTo = 0;
  VoidCallback? _pendingOnDone;

  /// Child shown at [_offset] while an external pageKey animation runs.
  Widget? _outgoingChild;
  bool _slideForward = true;

  /// After a gesture commit we call onNext/onPrevious; ignore the resulting
  /// pageKey change so it does not start a second animation.
  bool _suppressExternalSlide = false;

  bool _dragging = false;
  Timer? _pointerSettle;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(_onAnimTick)
      ..addStatusListener(_onAnimStatus);
  }

  @override
  void dispose() {
    _pointerSettle?.cancel();
    _anim.dispose();
    super.dispose();
  }

  void _onAnimTick() {
    final t = widget.curve.transform(_anim.value);
    setState(() {
      _offset = _animFrom + (_animTo - _animFrom) * t;
    });
  }

  void _onAnimStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    final done = _pendingOnDone;
    _pendingOnDone = null;
    done?.call();
  }

  @override
  void didUpdateWidget(covariant InteractiveSlidePager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _anim.duration = widget.duration;
    }
    if (widget.pageKey == oldWidget.pageKey) return;
    if (_suppressExternalSlide) {
      _suppressExternalSlide = false;
      _outgoingChild = null;
      _offset = 0;
      return;
    }
    if (_dragging || _anim.isAnimating) {
      _anim.stop();
      _dragging = false;
      _pendingOnDone = null;
    }
    _slideForward = widget.externalForward;
    _outgoingChild = oldWidget.child;
    final w = _width > 0 ? _width : 1.0;
    _offset = 0;
    _animateTo(_slideForward ? -w : w, onDone: () {
      if (!mounted) return;
      setState(() {
        _outgoingChild = null;
        _offset = 0;
      });
    });
  }

  void _animateTo(double target, {VoidCallback? onDone}) {
    _animFrom = _offset;
    _animTo = target;
    _pendingOnDone = onDone;
    _anim.duration = widget.duration;
    _anim.forward(from: 0);
  }

  void _applyDelta(double dx) {
    if (_width <= 0) return;
    setState(() {
      _offset = clampDragCycleOffset(_offset + dx, _width);
      _slideForward = dragCycleForwardFromOffset(_offset);
    });
  }

  void _finishGesture({
    required double velocity,
    required bool fromTrackpadBurst,
  }) {
    if (_width <= 0) {
      setState(() => _offset = 0);
      return;
    }
    final commit = shouldCommitDragCycle(
      offset: _offset,
      width: _width,
      velocity: velocity,
      fromTrackpadBurst: fromTrackpadBurst,
    );
    if (!commit) {
      _animateTo(0);
      return;
    }
    final forward = dragCycleForwardFromOffset(_offset);
    final target = dragCycleCommitTarget(_offset, _width);
    _animateTo(target, onDone: () {
      _suppressExternalSlide = true;
      if (forward) {
        widget.onNext();
      } else {
        widget.onPrevious();
      }
      if (mounted) {
        setState(() {
          _offset = 0;
          _outgoingChild = null;
        });
      }
    });
  }

  Widget _neighbor(bool forward) {
    return widget.neighborBuilder?.call(forward) ?? const SizedBox.expand();
  }

  @override
  Widget build(BuildContext context) {
    final stack = LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        _width = w;

        final external = _outgoingChild != null;
        final forward = external
            ? _slideForward
            : (_offset == 0 ? true : dragCycleForwardFromOffset(_offset));
        final showNeighbor = external || _offset != 0;

        final currentChild = external ? _outgoingChild! : widget.child;
        final incomingChild =
            external ? widget.child : _neighbor(forward);

        // Forward: incoming from the right (+width). Backward: from the left.
        final incomingShift = forward ? w : -w;

        return Stack(
          fit: widget.expand ? StackFit.expand : StackFit.loose,
          clipBehavior: Clip.hardEdge,
          children: [
            if (showNeighbor)
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(_offset + incomingShift, 0),
                  child: incomingChild,
                ),
              ),
            // Non-positioned so the stack sizes to the current page when
            // [expand] is false (chart plot height).
            Transform.translate(
              offset: Offset(_offset, 0),
              child: currentChild,
            ),
          ],
        );
      },
    );

    Widget clipped = ClipRect(child: stack);
    if (widget.expand) {
      clipped = SizedBox.expand(child: clipped);
    }

    if (!widget.enableGestures) return clipped;

    return Listener(
      onPointerSignal: (event) {
        if (event is! PointerScrollEvent) return;
        final dx = event.scrollDelta.dx;
        final dy = event.scrollDelta.dy;
        if (dx.abs() <= dy.abs() || dx == 0) return;
        GestureBinding.instance.pointerSignalResolver.register(event, (e) {
          if (e is! PointerScrollEvent) return;
          if (_anim.isAnimating) return;
          _dragging = true;
          _applyDelta(e.scrollDelta.dx);
          _pointerSettle?.cancel();
          _pointerSettle = Timer(const Duration(milliseconds: 120), () {
            if (!mounted || _anim.isAnimating) return;
            _dragging = false;
            _finishGesture(velocity: 0, fromTrackpadBurst: true);
          });
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (_) {
          if (_anim.isAnimating) {
            _anim.stop();
            _pendingOnDone = null;
          }
          _dragging = true;
          _outgoingChild = null;
        },
        onHorizontalDragUpdate: (details) {
          _applyDelta(details.delta.dx);
        },
        onHorizontalDragEnd: (details) {
          _dragging = false;
          final v = details.primaryVelocity ?? 0;
          _finishGesture(velocity: v, fromTrackpadBurst: false);
        },
        onHorizontalDragCancel: () {
          _dragging = false;
          _animateTo(0);
        },
        child: clipped,
      ),
    );
  }
}
