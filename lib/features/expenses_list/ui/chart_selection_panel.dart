import 'package:flutter/material.dart';

/// One row in a chart selection detail (series label + optional amount).
class ChartSelectionLine {
  final String label;
  final String? amountText;
  final Color? color;

  const ChartSelectionLine({required this.label, this.amountText, this.color});
}

/// Snapshot of the hovered / touched chart point shown as a plot overlay.
class ChartSelectionDetail {
  final String title;
  final List<ChartSelectionLine> lines;

  const ChartSelectionDetail({required this.title, this.lines = const []});
}

/// Floating selection badge over the chart (same corner as the column sum
/// badge). Must be placed in a [Stack] with [Positioned]; does not affect
/// layout height. Pointers pass through to the chart / overlay actions.
class ChartSelectionPanel extends StatelessWidget {
  final ChartSelectionDetail? detail;

  static const maxWidth = 220.0;

  const ChartSelectionPanel({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = detail;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: d == null ? 0 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: d == null
            ? const SizedBox.shrink()
            : Material(
                color: theme.colorScheme.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
                elevation: 1,
                shadowColor: Colors.black26,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: maxWidth),
                    child: DefaultTextStyle(
                      style: theme.textTheme.labelMedium!.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            d.title,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          for (final line in d.lines) ...[
                            const SizedBox(height: 2),
                            Text(
                              line.amountText == null ||
                                      line.amountText!.isEmpty
                                  ? line.label
                                  : '${line.label}: ${line.amountText}',
                              style: TextStyle(
                                color:
                                    line.color ?? theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
