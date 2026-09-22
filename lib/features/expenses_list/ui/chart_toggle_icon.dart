import 'package:flutter/material.dart';

/// Selection tint for chart overlay icons — app primary shifted toward blue.
Color chartOverlaySelectionColor(ColorScheme scheme) {
  return Color.lerp(scheme.primary, const Color(0xFF2563EB), 0.42)!;
}

/// Fixed-size icon button for chart-type toggles (donut / column / line / …).
///
/// Size is locked so switching chart types never changes the toggle row’s
/// footprint (avoids layout jank on mobile). Selected state uses the same
/// circular wash as breakdown / period icons.
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
    final selectedColor = chartOverlaySelectionColor(theme.colorScheme);
    final muted = theme.colorScheme.onSurfaceVariant;
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
        color: selected ? selectedColor : muted,
      ),
      style: IconButton.styleFrom(
        backgroundColor: selected
            ? selectedColor.withValues(alpha: 0.14)
            : Colors.transparent,
      ),
    );
  }
}
