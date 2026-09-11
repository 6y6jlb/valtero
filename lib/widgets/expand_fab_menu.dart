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
  static const _animDuration = Duration(milliseconds: 420);

  late final AnimationController _ctrl;
  late final Animation<double> _appear;
  late final Animation<double> _spin;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _animDuration);
    _appear = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    );
    _spin = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOutCubic),
    );
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

  bool get _showExtendedClosed =>
      widget.closedExtended &&
      !widget.open &&
      _ctrl.value == 0 &&
      !_ctrl.isAnimating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final closedBg = theme.floatingActionButtonTheme.backgroundColor ??
        scheme.primaryContainer;
    final closedFg = theme.floatingActionButtonTheme.foregroundColor ??
        scheme.onPrimaryContainer;

    if (_showExtendedClosed) {
      return FloatingActionButton.extended(
        heroTag: widget.heroTag,
        tooltip: widget.closedTooltip,
        onPressed: widget.onPressed,
        icon: widget.closedChild,
        label: Text(widget.closedLabel ?? ''),
      );
    }

    return Material(
      elevation: theme.floatingActionButtonTheme.elevation ?? 6,
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
              final t = _appear.value;
              return Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color.lerp(closedBg, widget.actionBg, t),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IgnorePointer(
                      // Invisible × must not steal taps while closed.
                      ignoring: t > 0.01,
                      child: Opacity(
                        opacity: (1 - t).clamp(0.0, 1.0),
                        child: IconTheme.merge(
                          data: IconThemeData(color: closedFg, size: 28),
                          child: widget.closedChild,
                        ),
                      ),
                    ),
                    IgnorePointer(
                      ignoring: t < 0.01,
                      child: Opacity(
                        opacity: t.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: 0.7 + 0.3 * t,
                          child: Transform.rotate(
                            angle: _spin.value * math.pi,
                            child: Icon(
                              Icons.close,
                              size: 28,
                              color: widget.actionFg,
                            ),
                          ),
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
