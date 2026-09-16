import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/expand_fab_controller.dart';

/// One expandable menu action (text label, no icon).
class ExpandFabAction {
  final String label;
  final Future<void> Function() onPressed;

  const ExpandFabAction({
    required this.label,
    required this.onPressed,
  });
}

/// Theme primary FAB that expands upward into lighter text-only actions.
///
/// Tree shape is identical open or closed so [_TriggerFab] keeps its
/// [AnimationController] across toggles. Sub-actions stay mounted and animate
/// via height-factor + opacity. Pair with [AppPageScaffold]
/// `Positioned(right: …)` anchors so neighbors never shift.
class ExpandFabMenu extends StatefulWidget {
  final String heroTag;
  final String closedTooltip;
  final Widget closedChild;
  final bool closedExtended;
  final String? closedLabel;
  final List<ExpandFabAction> actions;

  const ExpandFabMenu({
    super.key,
    required this.heroTag,
    required this.closedTooltip,
    required this.closedChild,
    required this.actions,
    this.closedExtended = false,
    this.closedLabel,
  });

  @override
  State<ExpandFabMenu> createState() => _ExpandFabMenuState();
}

class _ExpandFabMenuState extends State<ExpandFabMenu> {
  final Object _id = Object();

  static const _actionAnim = Duration(milliseconds: 220);

  Future<void> _run(ExpandFabAction action) async {
    final future = action.onPressed();
    ExpandFabScope.of(context).close(_id);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = ExpandFabScope.of(context);
    final open = controller.isOpen(_id);
    final scheme = Theme.of(context).colorScheme;
    final actionBg = expandFabActionBackground(scheme);
    final actionFg = expandFabActionForeground(scheme, actionBg);

    // Same Column shape open or closed — never remount the trigger.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _ActionsColumn(
          open: open,
          actions: widget.actions,
          heroTag: widget.heroTag,
          actionBg: actionBg,
          actionFg: actionFg,
          animDuration: _actionAnim,
          onRun: _run,
        ),
        _TriggerFab(
          heroTag: widget.heroTag,
          open: open,
          closedExtended: widget.closedExtended,
          closedTooltip: widget.closedTooltip,
          closedLabel: widget.closedLabel,
          closedChild: widget.closedChild,
          actionBg: actionBg,
          actionFg: actionFg,
          cancelTooltip: l10n.cancel,
          onPressed: () => controller.toggle(_id),
        ),
      ],
    );
  }
}

/// Always mounted; open/closed is only opacity + height factor (no FAB remount).
class _ActionsColumn extends StatelessWidget {
  final bool open;
  final List<ExpandFabAction> actions;
  final String heroTag;
  final Color actionBg;
  final Color actionFg;
  final Duration animDuration;
  final Future<void> Function(ExpandFabAction action) onRun;

  const _ActionsColumn({
    required this.open,
    required this.actions,
    required this.heroTag,
    required this.actionBg,
    required this.actionFg,
    required this.animDuration,
    required this.onRun,
  });

  @override
  Widget build(BuildContext context) {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: '${heroTag}_action_$i',
            backgroundColor: actionBg,
            foregroundColor: actionFg,
            onPressed: () => onRun(actions[i]),
            label: Text(actions[i].label),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: open ? 1 : 0),
      duration: animDuration,
      curve: Curves.easeOutCubic,
      builder: (context, factor, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.bottomCenter,
            heightFactor: factor.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: AnimatedOpacity(
        opacity: open ? 1 : 0,
        duration: animDuration,
        curve: Curves.easeOutCubic,
        child: IgnorePointer(
          ignoring: !open,
          child: column,
        ),
      ),
    );
  }
}

class _TriggerFab extends StatefulWidget {
  final String heroTag;
  final bool open;
  final bool closedExtended;
  final String closedTooltip;
  final String? closedLabel;
  final Widget closedChild;
  final Color actionBg;
  final Color actionFg;
  final String cancelTooltip;
  final VoidCallback onPressed;

  const _TriggerFab({
    required this.heroTag,
    required this.open,
    required this.closedExtended,
    required this.closedTooltip,
    required this.closedLabel,
    required this.closedChild,
    required this.actionBg,
    required this.actionFg,
    required this.cancelTooltip,
    required this.onPressed,
  });

  @override
  State<_TriggerFab> createState() => _TriggerFabState();
}

class _TriggerFabState extends State<_TriggerFab>
    with SingleTickerProviderStateMixin {
  static const _circle = CircleBorder();
  static const _plusAnimDuration = Duration(milliseconds: 320);
  static const _extendedAnimDuration = Duration(milliseconds: 560);

  /// Closed `+` → open looks like × via a quarter-turn (same glyph, no swap).
  static const _openRotation = math.pi / 4;

  /// Show FAB: label out → list icon spin/morph → + twists to ×.
  static const _labelInterval = Interval(0.0, 0.34, curve: Curves.easeInOutCubic);
  static const _iconMorphInterval =
      Interval(0.30, 0.74, curve: Curves.easeInOutCubic);
  static const _plusTwistInterval =
      Interval(0.70, 1.0, curve: Curves.easeInOutCubic);

  late final AnimationController _ctrl;

  Duration get _animDuration =>
      widget.closedExtended ? _extendedAnimDuration : _plusAnimDuration;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _animDuration);
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted) {
        setState(() {});
      }
    });
    if (widget.open) {
      _ctrl.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant _TriggerFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_ctrl.duration != _animDuration) {
      _ctrl.duration = _animDuration;
    }
    if (widget.open == oldWidget.open) return;
    if (widget.open) {
      _ctrl.forward(from: _ctrl.value);
    } else {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// When the closed glyph is already `+`, open/close is only rotation + color.
  bool get _closedIsPlus {
    final child = widget.closedChild;
    return child is Icon && child.icon == Icons.add;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final closedBg = theme.floatingActionButtonTheme.backgroundColor ??
        scheme.primaryContainer;
    final closedFg = theme.floatingActionButtonTheme.foregroundColor ??
        scheme.onPrimaryContainer;
    final elevation = theme.floatingActionButtonTheme.elevation ?? 6;

    if (widget.closedExtended) {
      return _buildExtendedTrigger(
        theme: theme,
        closedBg: closedBg,
        closedFg: closedFg,
        elevation: elevation,
      );
    }

    return Material(
      elevation: elevation,
      shadowColor: theme.shadowColor,
      color: Colors.transparent,
      shape: _circle,
      clipBehavior: Clip.antiAlias,
      child: Tooltip(
        message: widget.open ? widget.cancelTooltip : widget.closedTooltip,
        child: InkWell(
          customBorder: _circle,
          onTap: widget.onPressed,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final t = Curves.easeInOutCubic.transform(_ctrl.value);
              final bg = Color.lerp(closedBg, widget.actionBg, t)!;
              final plusColor = Color.lerp(closedFg, widget.actionFg, t)!;
              return Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                ),
                child: _closedIsPlus
                    ? Transform.rotate(
                        angle: t * _openRotation,
                        child: Icon(
                          Icons.add,
                          size: 28,
                          color: plusColor,
                        ),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: (1 - t).clamp(0.0, 1.0),
                            child: IconTheme.merge(
                              data: IconThemeData(color: closedFg, size: 28),
                              child: widget.closedChild,
                            ),
                          ),
                          Opacity(
                            opacity: t.clamp(0.0, 1.0),
                            child: Transform.rotate(
                              angle: t * _openRotation,
                              child: Icon(
                                Icons.add,
                                size: 28,
                                color: plusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExtendedTrigger({
    required ThemeData theme,
    required Color closedBg,
    required Color closedFg,
    required double elevation,
  }) {
    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      color: closedFg,
      fontWeight: FontWeight.w500,
    );

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final v = _ctrl.value;
        final labelT = _labelInterval.transform(v);
        final morphT = _iconMorphInterval.transform(v);
        final twistT = _plusTwistInterval.transform(v);

        // Color shifts with icon morph so the pill stays “primary” while text
        // collapses, then matches action tint as + appears.
        final bg = Color.lerp(closedBg, widget.actionBg, morphT)!;
        final plusColor = Color.lerp(closedFg, widget.actionFg, morphT)!;

        // List icon spins ~half turn, then yields to + near the end.
        final listOpacity =
            (1 - const Interval(0.55, 1.0).transform(morphT)).clamp(0.0, 1.0);
        final plusOpacity =
            const Interval(0.55, 1.0).transform(morphT).clamp(0.0, 1.0);
        final listAngle = morphT * math.pi;
        final plusAngle = twistT * _openRotation;

        final labelFactor = (1 - labelT).clamp(0.0, 1.0);
        final shape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        );

        return Material(
          elevation: elevation,
          shadowColor: theme.shadowColor,
          color: bg,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: Tooltip(
            message: widget.open ? widget.cancelTooltip : widget.closedTooltip,
            child: InkWell(
              customBorder: shape,
              onTap: widget.onPressed,
              child: SizedBox(
                height: 56,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (listOpacity > 0.01)
                            Opacity(
                              opacity: listOpacity,
                              child: Transform.rotate(
                                angle: listAngle,
                                child: IconTheme.merge(
                                  data:
                                      IconThemeData(color: closedFg, size: 28),
                                  child: widget.closedChild,
                                ),
                              ),
                            ),
                          if (plusOpacity > 0.01)
                            Opacity(
                              opacity: plusOpacity,
                              child: Transform.rotate(
                                angle: plusAngle,
                                child: Icon(
                                  Icons.add,
                                  size: 28,
                                  color: plusColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: labelFactor,
                        child: Opacity(
                          opacity: labelFactor,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Text(
                              widget.closedLabel ?? '',
                              maxLines: 1,
                              softWrap: false,
                              style: labelStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Slightly lighter than the theme FAB fill so menu actions read as secondary.
Color expandFabActionBackground(ColorScheme scheme) {
  final base = scheme.primaryContainer;
  final amount = scheme.brightness == Brightness.dark ? 0.22 : 0.42;
  return Color.lerp(base, Colors.white, amount)!;
}

Color expandFabActionForeground(ColorScheme scheme, Color background) {
  final contrast = ThemeData.estimateBrightnessForColor(background);
  if (contrast == Brightness.dark) {
    return Colors.white;
  }
  return scheme.onPrimaryContainer;
}
