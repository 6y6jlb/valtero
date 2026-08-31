import 'package:flutter/material.dart';

/// Shared legend chips for donut / column breakdown charts.
class BreakdownChartLegend extends StatelessWidget {
  final List<({String key, String label, Color color})> items;
  final Set<String> hiddenKeys;
  final ValueChanged<String> onToggle;

  const BreakdownChartLegend({
    super.key,
    required this.items,
    required this.hiddenKeys,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        for (final item in items)
          _LegendChip(
            label: item.label,
            color: item.color,
            visible: !hiddenKeys.contains(item.key),
            onTap: () => onToggle(item.key),
          ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool visible;
  final VoidCallback onTap;

  const _LegendChip({
    required this.label,
    required this.color,
    required this.visible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: visible ? color : theme.colorScheme.outlineVariant,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: visible ? null : muted,
                decoration: visible ? null : TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
