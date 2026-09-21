import 'package:flutter/material.dart';

/// Fixed-size icon button for chart-type toggles (donut / column / line / …).
///
/// Size is locked so switching chart types never changes the toggle row’s
/// footprint (avoids layout jank on mobile).
class ChartToggleIcon extends StatelessWidget {
  final String tooltip;
  final bool selected;
  final IconData icon;
  final VoidCallback onPressed;

  static const double extent = 36;
  static const double iconSize = 20;

  const ChartToggleIcon({
    super.key,
    required this.tooltip,
    required this.selected,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(
        minWidth: extent,
        minHeight: extent,
      ),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: iconSize,
        color: selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
