import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_aggregator.dart';
import 'package:valtero/features/expenses_list/ui/chart_empty_placeholder.dart';
import 'package:valtero/features/expenses_list/ui/chart_overlay_controls.dart';
import 'package:valtero/features/expenses_list/ui/chart_selection_panel.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/money_text.dart';

/// Grouped bar chart comparing income vs. expenses per period
/// (day/week/month/year, see [CashFlowBucket]).
class CashFlowChart extends ConsumerStatefulWidget {
  final List<CashFlowBucket> buckets;
  final String displayCurrency;
  final double chartHeight;
  final String? emptyMessage;
  final IconData emptyIcon;
  final bool hideBarAmounts;

  const CashFlowChart({
    super.key,
    required this.buckets,
    required this.displayCurrency,
    this.chartHeight = 280,
    this.emptyMessage,
    this.emptyIcon = Icons.stacked_bar_chart_outlined,
    this.hideBarAmounts = false,
  });

  @override
  ConsumerState<CashFlowChart> createState() => _CashFlowChartState();
}

class _CashFlowChartState extends ConsumerState<CashFlowChart> {
  ChartSelectionDetail? _selection;

  @override
  void didUpdateWidget(covariant CashFlowChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.buckets, widget.buckets)) {
      _selection = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final incomeColor = theme.colorScheme.tertiary;
    final expenseColor = theme.colorScheme.error;
    final buckets = widget.buckets;
    final displayCurrency = widget.displayCurrency;
    final chartHeight = widget.chartHeight;
    final hideBarAmounts = widget.hideBarAmounts;

    if (buckets.isEmpty) {
      return ChartEmptyPlaceholder(
        message: widget.emptyMessage ?? l10n.noMatchingOperations,
        icon: widget.emptyIcon,
        height: chartHeight * 0.55,
      );
    }

    final maxY = buckets.fold<double>(0, (max, b) {
      final biggest = b.incomeTotalMinor > b.expenseTotalMinor
          ? b.incomeTotalMinor
          : b.expenseTotalMinor;
      return biggest > max ? biggest.toDouble() : max;
    });
    final showBottomTitles = buckets.length <= 10;

    return Column(
      children: [
        SizedBox(
          height: chartHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: kChartPlotPadding,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY <= 0 ? 1 : maxY * 1.15,
                    minY: 0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                            null,
                      ),
                      touchCallback: (event, response) {
                        final spot = response?.spot;
                        if (spot == null) {
                          if (event is FlPointerExitEvent) {
                            setState(() => _selection = null);
                          }
                          return;
                        }
                        final groupIndex = spot.touchedBarGroupIndex;
                        final rodIndex = spot.touchedRodDataIndex;
                        if (groupIndex < 0 || groupIndex >= buckets.length) {
                          return;
                        }
                        final bucket = buckets[groupIndex];
                        final isIncome = rodIndex == 0;
                        final amountMinor = isIncome
                            ? bucket.incomeTotalMinor
                            : bucket.expenseTotalMinor;
                        final kind = isIncome
                            ? l10n.cashFlowIncome
                            : l10n.cashFlowExpense;
                        setState(() {
                          _selection = ChartSelectionDetail(
                            title: bucket.label,
                            lines: [
                              ChartSelectionLine(
                                label: kind,
                                amountText: hideBarAmounts
                                    ? null
                                    : formatMoneyOf(
                                        context,
                                        ref,
                                        amountMinor: amountMinor,
                                        currencyCode: displayCurrency,
                                      ),
                                color: isIncome ? incomeColor : expenseColor,
                              ),
                            ],
                          );
                        });
                      },
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: showBottomTitles,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= buckets.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                buckets[i].label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 9,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      for (var i = 0; i < buckets.length; i++)
                        BarChartGroupData(
                          x: i,
                          barsSpace: 4,
                          barRods: [
                            BarChartRodData(
                              toY: buckets[i].incomeTotalMinor.toDouble(),
                              color: incomeColor,
                              width: 10,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(3),
                              ),
                            ),
                            BarChartRodData(
                              toY: buckets[i].expenseTotalMinor.toDouble(),
                              color: expenseColor,
                              width: 10,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(3),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  duration: Duration.zero,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: ChartSelectionPanel(detail: _selection),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            _LegendDot(
              color: incomeColor,
              label: l10n.cashFlowIncome,
              icon: Icons.south_west,
            ),
            _LegendDot(
              color: expenseColor,
              label: l10n.cashFlowExpense,
              icon: Icons.north_east,
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final IconData? icon;

  const _LegendDot({required this.color, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Icon(icon, size: 16, color: color)
        else
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}
