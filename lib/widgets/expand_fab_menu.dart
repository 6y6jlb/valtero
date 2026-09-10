import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

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
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  void _close() {
    if (_open) setState(() => _open = false);
  }

  Future<void> _run(ExpandFabAction action) async {
    _close();
    await action.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final actionBg = expandFabActionBackground(scheme);
    final actionFg = expandFabActionForeground(scheme, actionBg);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.bottomRight,
          child: _open
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < widget.actions.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      FloatingActionButton.extended(
                        heroTag: '${widget.heroTag}_action_$i',
                        backgroundColor: actionBg,
                        foregroundColor: actionFg,
                        onPressed: () => _run(widget.actions[i]),
                        label: Text(widget.actions[i].label),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        if (widget.closedExtended)
          FloatingActionButton.extended(
            heroTag: widget.heroTag,
            tooltip: _open ? l10n.cancel : widget.closedTooltip,
            onPressed: _toggle,
            icon: _open ? const Icon(Icons.close) : widget.closedChild,
            label: Text(_open ? l10n.cancel : (widget.closedLabel ?? '')),
          )
        else
          FloatingActionButton(
            heroTag: widget.heroTag,
            tooltip: _open ? l10n.cancel : widget.closedTooltip,
            onPressed: _toggle,
            child: _open
                ? const Icon(Icons.close, size: 28)
                : widget.closedChild,
          ),
      ],
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
