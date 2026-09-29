import 'dart:math' show max;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Horizontal scroll for a chart plot when [contentWidth] exceeds the viewport.
///
/// Legend and the controls around the plot stay put; only [child] scrolls.
/// Mouse drag is enabled so a desktop pointer can pan the axis. While the plot
/// overflows, that drag scrolls the chart instead of cycling breakdown.
class ChartAxisScroll extends StatefulWidget {
  final double contentWidth;
  final Widget child;

  const ChartAxisScroll({
    super.key,
    required this.contentWidth,
    required this.child,
  });

  @override
  State<ChartAxisScroll> createState() => _ChartAxisScrollState();
}

class _ChartAxisScrollState extends State<ChartAxisScroll> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = constraints.maxWidth;
        // At least the full plot. Extra room is width, not a wider column pitch:
        // bar charts pack groups at the start, line charts extend maxX.
        final width = max(viewport, widget.contentWidth);
        final plot = SizedBox(
          width: width,
          height: constraints.maxHeight,
          child: widget.child,
        );
        if (widget.contentWidth <= viewport + 0.5) return plot;
        return ScrollConfiguration(
          behavior: const ChartAxisScrollBehavior(),
          child: Scrollbar(
            controller: _controller,
            thumbVisibility: false,
            thickness: 4,
            radius: const Radius.circular(4),
            interactive: true,
            child: SingleChildScrollView(
              controller: _controller,
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
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

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
