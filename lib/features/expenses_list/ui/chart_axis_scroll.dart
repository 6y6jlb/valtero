import 'dart:math' show max;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Horizontal scroll for a chart plot when [contentWidth] exceeds the viewport.
///
/// Legend and the controls around the plot stay put; only [child] scrolls.
/// Mouse drag is enabled so a desktop pointer can pan the axis. While the plot
/// overflows, that drag scrolls the chart instead of cycling breakdown.
class ChartAxisScroll extends StatelessWidget {
  final double contentWidth;
  final Widget child;

  const ChartAxisScroll({
    super.key,
    required this.contentWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = constraints.maxWidth;
        final width = max(viewport, contentWidth);
        final plot = SizedBox(width: width, child: child);
        if (contentWidth <= viewport + 0.5) return plot;
        return ScrollConfiguration(
          behavior: const ChartAxisScrollBehavior(),
          child: Scrollbar(
            thumbVisibility: true,
            thickness: 4,
            radius: const Radius.circular(4),
            interactive: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              primary: false,
              child: plot,
            ),
          ),
        );
      },
    );
  }
}

/// Lets a mouse drag the chart axis, same as touch.
class ChartAxisScrollBehavior extends MaterialScrollBehavior {
  const ChartAxisScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.unknown,
  };
}
