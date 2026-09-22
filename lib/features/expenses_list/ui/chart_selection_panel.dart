import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/ui/chart_selection_sheet.dart';

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

  /// Compact overlay preview: title + first amount (or first label-only line).
  /// Full [lines] stay available for the detail sheet.
  (String? amountOrLabel, Color? color) get compactPreview {
    for (final line in lines) {
      final amount = line.amountText;
      if (amount != null && amount.isNotEmpty) {
        return (amount, line.color);
      }
    }
    if (lines.isEmpty) return (null, null);
    return (lines.first.label, lines.first.color);
  }
}

/// Floating selection / total badge in chart chrome (or in-plot for cash flow).
///
/// Shows [title] with ellipsis and a single full amount line. Tap opens a
/// bottom sheet only when [detail] has more than one line (single-line and
/// total badges already show everything).
class ChartSelectionPanel extends StatelessWidget {
  final ChartSelectionDetail? detail;

  /// When set and [detail] is null, shows a total badge (same chrome slot).
  final String? totalLabel;
  final String? totalAmountText;

  const ChartSelectionPanel({
    super.key,
    required this.detail,
    this.totalLabel,
    this.totalAmountText,
  });

  bool get _hasTotal =>
      detail == null &&
      totalLabel != null &&
      totalAmountText != null &&
      totalAmountText!.isNotEmpty;

  bool get _visible => detail != null || _hasTotal;

  /// Sheet only when there is more than one detail line.
  bool get _canOpenSheet {
    final d = detail;
    return d != null && d.lines.length > 1;
  }

  void _openSheet(BuildContext context) {
    final d = detail;
    if (d == null || d.lines.length <= 1) return;
    showChartSelectionSheet(context, d);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = detail;
    final showTotal = _hasTotal;

    final String title;
    final String? secondary;
    final Color? secondaryColor;
    if (d != null) {
      title = d.title;
      final preview = d.compactPreview;
      secondary = preview.$1;
      secondaryColor = preview.$2;
    } else if (showTotal) {
      title = totalLabel!;
      secondary = totalAmountText;
      secondaryColor = null;
    } else {
      title = '';
      secondary = null;
      secondaryColor = null;
    }

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (secondary != null && secondary.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              secondary,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.clip,
              style: theme.textTheme.labelMedium?.copyWith(
                color: secondaryColor ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ],
        ],
      ),
    );

    final canOpen = _canOpenSheet;
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: !_visible
          ? const SizedBox.shrink()
          : Material(
              color: theme.colorScheme.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(12),
              elevation: 1,
              shadowColor: Colors.black26,
              child: canOpen
                  ? InkWell(
                      onTap: () => _openSheet(context),
                      borderRadius: BorderRadius.circular(12),
                      child: content,
                    )
                  : content,
            ),
    );
  }
}
