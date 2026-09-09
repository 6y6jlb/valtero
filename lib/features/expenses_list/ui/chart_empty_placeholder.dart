import 'package:flutter/material.dart';

/// Compact empty state for dashboard / list charts: icon + one short line.
class ChartEmptyPlaceholder extends StatelessWidget {
  final String message;
  final IconData icon;
  final double height;

  const ChartEmptyPlaceholder({
    super.key,
    required this.message,
    this.icon = Icons.pie_chart_outline,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: muted),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
