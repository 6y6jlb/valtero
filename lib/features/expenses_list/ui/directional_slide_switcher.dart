import 'package:flutter/material.dart';

/// Duration for tab / chart-breakdown parallel slide transitions.
const kDirectionalSlideDuration = Duration(milliseconds: 280);

/// Parallel horizontal slide: outgoing and incoming move together.
///
/// When [forward] is true (next / swipe left), the old child exits to the left
/// and the new one enters from the right. When false, the opposite.
///
/// Put a [ValueKey] (or change [switchKey]) on each logical page so
/// [AnimatedSwitcher] treats them as distinct children.
class DirectionalSlideSwitcher extends StatelessWidget {
  final Object switchKey;
  final bool forward;
  final Widget child;
  final Duration duration;
  final Curve curve;

  /// When true, expands to fill the parent (list / dashboard body).
  final bool expand;

  const DirectionalSlideSwitcher({
    super.key,
    required this.switchKey,
    required this.forward,
    required this.child,
    this.duration = kDirectionalSlideDuration,
    this.curve = Curves.easeOutCubic,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final keyed = KeyedSubtree(
      key: ValueKey(switchKey),
      child: child,
    );

    final switcher = AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          fit: expand ? StackFit.expand : StackFit.passthrough,
          alignment: Alignment.topCenter,
          children: [
            ...previousChildren,
            ?currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final isIncoming = child.key == ValueKey(switchKey);
        final begin = isIncoming
            ? Offset(forward ? 1.0 : -1.0, 0.0)
            : Offset(forward ? -1.0 : 1.0, 0.0);
        final position = Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(animation);
        return SlideTransition(position: position, child: child);
      },
      child: keyed,
    );

    final clipped = ClipRect(child: switcher);
    if (!expand) return clipped;
    return SizedBox.expand(child: clipped);
  }
}
