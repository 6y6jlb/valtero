import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/ui/breakdown_chart_legend.dart';
import 'package:valtero/features/expenses_list/ui/column_breakdown_chart.dart';
import 'package:valtero/features/expenses_list/ui/donut_breakdown_chart.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/money_text.dart';

/// Donut / column chart with an overlay type toggle (top-right, no extra height).
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
    this.chartHeight = 260,
    this.emptyMessage,
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
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(widget.emptyMessage ?? l10n.noMatchingExpenses),
        ),
      );
    }

    final visible =
        all.where((s) => !_hiddenKeys.contains(s.key)).toList(growable: false);
    final total = visible.fold<int>(0, (sum, s) => sum + s.amountMinor);

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
                        onPressed: () => widget.onChartTypeChanged(
                          ExpenseChartType.donut,
                        ),
                      ),
                      _ChartTypeIcon(
                        tooltip: l10n.chartTypeColumn,
                        selected: widget.chartType == ExpenseChartType.column,
                        icon: Icons.bar_chart,
                        onPressed: () => widget.onChartTypeChanged(
                          ExpenseChartType.column,
                        ),
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
        if (widget.showTotal &&
            !widget.hideCenterTotal &&
            visible.isNotEmpty) ...[
          const SizedBox(height: 12),
          MoneyText(
            amountMinor: total,
            currencyCode: widget.displayCurrency,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ],
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
