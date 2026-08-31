import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/money_text.dart';

/// Shared donut: amounts on segments, legend chips toggle visibility,
/// optional tap on a visible segment.
class DonutBreakdownChart extends ConsumerStatefulWidget {
  final List<DonutChartSlice> slices;
  final String displayCurrency;
  final ValueChanged<DonutChartSlice>? onSegmentTap;
  final bool showTotal;
  final bool hideCenterTotal;
  final bool hideSegmentAmounts;
  final bool showLegend;
  final double chartHeight;
  final double sectionRadius;
  final String? emptyMessage;

  const DonutBreakdownChart({
    super.key,
    required this.slices,
    required this.displayCurrency,
    this.onSegmentTap,
    this.showTotal = true,
    this.hideCenterTotal = false,
    this.hideSegmentAmounts = false,
    this.showLegend = true,
    this.chartHeight = 260,
    this.sectionRadius = 72,
    this.emptyMessage,
  });

  @override
  ConsumerState<DonutBreakdownChart> createState() =>
      _DonutBreakdownChartState();
}

class _DonutBreakdownChartState extends ConsumerState<DonutBreakdownChart> {
  final Set<String> _hiddenKeys = {};

  @override
  void didUpdateWidget(covariant DonutBreakdownChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextKeys = {for (final s in widget.slices) s.key};
    final oldKeys = {for (final s in oldWidget.slices) s.key};
    if (nextKeys.length != oldKeys.length ||
        !nextKeys.containsAll(oldKeys)) {
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
        SizedBox(
          height: widget.chartHeight,
          child: visible.isEmpty
              ? Center(child: Text(l10n.noMatchingExpenses))
              : PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 48,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (widget.onSegmentTap == null) return;
                        if (event is! FlTapUpEvent) return;
                        final index =
                            response?.touchedSection?.touchedSectionIndex;
                        if (index == null ||
                            index < 0 ||
                            index >= visible.length) {
                          return;
                        }
                        widget.onSegmentTap!(visible[index]);
                      },
                      mouseCursorResolver: (event, response) {
                        if (widget.onSegmentTap == null) {
                          return SystemMouseCursors.basic;
                        }
                        final index =
                            response?.touchedSection?.touchedSectionIndex;
                        if (index != null &&
                            index >= 0 &&
                            index < visible.length) {
                          return SystemMouseCursors.click;
                        }
                        return SystemMouseCursors.basic;
                      },
                    ),
                    sections: [
                      for (final slice in visible)
                        PieChartSectionData(
                          value: slice.amountMinor.toDouble().abs() == 0
                              ? 1
                              : slice.amountMinor.toDouble().abs(),
                          title: widget.hideSegmentAmounts
                              ? slice.label
                              : '${slice.label}\n${formatMoneyOf(
                                  context,
                                  ref,
                                  amountMinor: slice.amountMinor,
                                  currencyCode: slice.currencyCode ??
                                      widget.displayCurrency,
                                )}',
                          color: slice.color,
                          radius: widget.sectionRadius,
                          titleStyle: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            height: 1.15,
                          ),
                        ),
                    ],
                  ),
                ),
        ),
        if (widget.showLegend && all.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              for (final slice in all)
                _LegendChip(
                  label: slice.label,
                  color: slice.color,
                  visible: !_hiddenKeys.contains(slice.key),
                  onTap: () => _toggle(slice.key),
                ),
            ],
          ),
        ],
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
