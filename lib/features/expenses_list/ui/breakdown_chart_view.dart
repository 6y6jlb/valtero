import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/ui/breakdown_chart_legend.dart';
import 'package:valtero/features/expenses_list/ui/chart_empty_placeholder.dart';
import 'package:valtero/features/expenses_list/ui/column_breakdown_chart.dart';
import 'package:valtero/features/expenses_list/ui/donut_breakdown_chart.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/money_text.dart';

/// Donut / column chart with an overlay type toggle (top-right, no extra
/// height) and an overlay total: centered in the donut hole, or a small
/// badge on the opposite corner (top-left) for the column chart.
class BreakdownChartView extends ConsumerStatefulWidget {
  final List<DonutChartSlice> slices;
  final String displayCurrency;
  final ExpenseChartType chartType;
  final ValueChanged<ExpenseChartType> onChartTypeChanged;
  final ValueChanged<DonutChartSlice>? onSegmentTap;
  final bool showTotal;
  final bool hideCenterTotal;
  final bool hideSegmentAmounts;
  final double chartHeight;
  final String? emptyMessage;
  final IconData emptyIcon;

  const BreakdownChartView({
    super.key,
    required this.slices,
    required this.displayCurrency,
    required this.chartType,
    required this.onChartTypeChanged,
    this.onSegmentTap,
    this.showTotal = true,
    this.hideCenterTotal = false,
    this.hideSegmentAmounts = false,
    this.chartHeight = 312,
    this.emptyMessage,
    this.emptyIcon = Icons.pie_chart_outline,
  });

  @override
  ConsumerState<BreakdownChartView> createState() => _BreakdownChartViewState();
}

class _BreakdownChartViewState extends ConsumerState<BreakdownChartView> {
  final Set<String> _hiddenKeys = {};

  @override
  void didUpdateWidget(covariant BreakdownChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextKeys = {for (final s in widget.slices) s.key};
    final oldKeys = {for (final s in oldWidget.slices) s.key};
    if (nextKeys.length != oldKeys.length || !nextKeys.containsAll(oldKeys)) {
      _hiddenKeys.removeWhere((k) => !nextKeys.contains(k));
    }
  }

  void _toggle(String key) {
    setState(() {
      if (_hiddenKeys.contains(key)) {
        _hiddenKeys.remove(key);
      } else {
        _hiddenKeys.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final all = widget.slices;
    if (all.isEmpty) {
      return ChartEmptyPlaceholder(
        message: widget.emptyMessage ?? l10n.noMatchingExpenses,
        icon: widget.emptyIcon,
        height: widget.chartHeight * 0.55,
      );
    }

    final visible = all
        .where((s) => !_hiddenKeys.contains(s.key))
        .toList(growable: false);
    final total = visible.fold<int>(0, (sum, s) => sum + s.amountMinor);
    // Totals never show cents; if the full amount still doesn't fit its
    // overlay, fall back to a compact form (`$20,000` -> `$20K`).
    final totalPrimaryText = formatMoneyOf(
      context,
      ref,
      amountMinor: total,
      currencyCode: widget.displayCurrency,
      hideFraction: true,
    );
    final totalCompactText = formatMoneyOf(
      context,
      ref,
      amountMinor: total,
      currencyCode: widget.displayCurrency,
      hideFraction: true,
      compact: true,
    );

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final fade = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                );
                final slide = Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(fade);
                return FadeTransition(
                  opacity: fade,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(widget.chartType),
                child: widget.chartType == ExpenseChartType.donut
                    ? DonutBreakdownChart(
                        slices: visible,
                        displayCurrency: widget.displayCurrency,
                        onSegmentTap: widget.onSegmentTap,
                        showTotal: false,
                        hideCenterTotal: true,
                        hideSegmentAmounts: widget.hideSegmentAmounts,
                        chartHeight: widget.chartHeight,
                        showLegend: false,
                        emptyMessage: widget.emptyMessage,
                      )
                    : ColumnBreakdownChart(
                        slices: visible,
                        displayCurrency: widget.displayCurrency,
                        onSegmentTap: widget.onSegmentTap,
                        hideSegmentAmounts: widget.hideSegmentAmounts,
                        chartHeight: widget.chartHeight,
                        emptyMessage: widget.emptyMessage,
                      ),
              ),
            ),
            if (widget.showTotal &&
                !widget.hideCenterTotal &&
                visible.isNotEmpty)
              if (widget.chartType == ExpenseChartType.donut)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: _ChartCenterTotal(
                        label: l10n.summaryTotal,
                        primaryText: totalPrimaryText,
                        compactText: totalCompactText,
                      ),
                    ),
                  ),
                )
              else
                Positioned(
                  top: 0,
                  left: 0,
                  child: _ChartTotalBadge(
                    label: l10n.summaryTotal,
                    primaryText: totalPrimaryText,
                    compactText: totalCompactText,
                  ),
                ),
            Positioned(
              top: 0,
              right: 0,
              child: Material(
                color: theme.colorScheme.surface.withValues(alpha: 0.88),
                elevation: 0,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ChartTypeIcon(
                        tooltip: l10n.chartTypeDonut,
                        selected: widget.chartType == ExpenseChartType.donut,
                        icon: Icons.pie_chart_outline,
                        onPressed: () =>
                            widget.onChartTypeChanged(ExpenseChartType.donut),
                      ),
                      _ChartTypeIcon(
                        tooltip: l10n.chartTypeColumn,
                        selected: widget.chartType == ExpenseChartType.column,
                        icon: Icons.bar_chart,
                        onPressed: () =>
                            widget.onChartTypeChanged(ExpenseChartType.column),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BreakdownChartLegend(
          items: [
            for (final s in all) (key: s.key, label: s.label, color: s.color),
          ],
          hiddenKeys: _hiddenKeys,
          onToggle: _toggle,
        ),
      ],
    );
  }
}

/// True when [text] rendered with [style] fits within [maxWidth] on one line.
bool _textFitsWidth(String text, TextStyle? style, double maxWidth) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.width <= maxWidth;
}

/// Total shown centered in the donut hole. Never wider than the hole itself
/// (falls back to [compactText], then lets [FittedBox] scale down as a last
/// resort) so the text can never spill outside the ring.
class _ChartCenterTotal extends StatelessWidget {
  final String label;
  final String primaryText;
  final String compactText;

  // Hole diameter is 2 * kDonutCenterSpaceRadius; keep a margin so the text
  // never visually touches the ring.
  static const _maxWidth = kDonutCenterSpaceRadius * 2 * 0.82;

  const _ChartCenterTotal({
    required this.label,
    required this.primaryText,
    required this.compactText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final amountText = _textFitsWidth(primaryText, amountStyle, _maxWidth)
        ? primaryText
        : compactText;
    return SizedBox(
      width: _maxWidth,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(amountText, maxLines: 1, style: amountStyle),
          ],
        ),
      ),
    );
  }
}

/// Total shown as a small corner badge (non-donut charts): hugs its content
/// when short, falls back to [compactText] (then scale-down) when it grows
/// past a reasonable pill width.
class _ChartTotalBadge extends StatelessWidget {
  final String label;
  final String primaryText;
  final String compactText;

  static const _maxWidth = 120.0;

  const _ChartTotalBadge({
    required this.label,
    required this.primaryText,
    required this.compactText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final amountText = _textFitsWidth(primaryText, amountStyle, _maxWidth)
        ? primaryText
        : compactText;
    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(amountText, maxLines: 1, style: amountStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartTypeIcon extends StatelessWidget {
  final String tooltip;
  final bool selected;
  final IconData icon;
  final VoidCallback onPressed;

  const _ChartTypeIcon({
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
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 20,
        color: selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
