import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Shared fl_chart tooltip chrome matching the former selection panel look.
Color chartTooltipBg(BuildContext context) =>
    Theme.of(context).colorScheme.surface.withValues(alpha: 0.94);

TextStyle chartTooltipTitleStyle(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ) ??
      const TextStyle(fontSize: 11, fontWeight: FontWeight.w600);
}

TextStyle chartTooltipBodyStyle(BuildContext context, {Color? color}) {
  final theme = Theme.of(context);
  return theme.textTheme.labelMedium?.copyWith(
        color: color ?? theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ) ??
      TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      );
}

BarTooltipItem chartBarTooltipItem({
  required BuildContext context,
  required String title,
  String? amountOrLabel,
  Color? accent,
}) {
  final children = <TextSpan>[];
  if (amountOrLabel != null && amountOrLabel.isNotEmpty) {
    children.add(
      TextSpan(
        text: '\n$amountOrLabel',
        style: chartTooltipBodyStyle(context, color: accent),
      ),
    );
  }
  return BarTooltipItem(
    title,
    chartTooltipTitleStyle(context),
    textAlign: TextAlign.left,
    children: children.isEmpty ? null : children,
  );
}

LineTooltipItem chartLineTooltipItem({
  required BuildContext context,
  required String text,
  Color? accent,
}) {
  return LineTooltipItem(
    text,
    chartTooltipBodyStyle(context, color: accent),
    textAlign: TextAlign.left,
  );
}
