import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_aggregator.dart';
import 'package:valtero/features/expenses_list/ui/chart_empty_placeholder.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/money_text.dart';

/// Grouped bar chart comparing income vs. expenses per period
/// (day/week/month/year, see [CashFlowBucket]).
class CashFlowChart extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final incomeColor = theme.colorScheme.tertiary;
    final expenseColor = theme.colorScheme.error;

    if (buckets.isEmpty) {
      return ChartEmptyPlaceholder(
        message: emptyMessage ?? l10n.noMatchingOperations,
        icon: emptyIcon,
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 12, 4),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY <= 0 ? 1 : maxY * 1.15,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => theme.colorScheme.inverseSurface
                        .withValues(alpha: 0.92),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (groupIndex < 0 || groupIndex >= buckets.length) {
                        return null;
                      }
                      final bucket = buckets[groupIndex];
                      final isIncome = rodIndex == 0;
                      final amount = formatMoneyOf(
                        context,
                        ref,
                        amountMinor: isIncome
                            ? bucket.incomeTotalMinor
                            : bucket.expenseTotalMinor,
                        currencyCode: displayCurrency,
                      );
                      final kind =
                          isIncome ? l10n.cashFlowIncome : l10n.cashFlowExpense;
                      return BarTooltipItem(
                        '${bucket.label}\n$kind: $amount',
                        TextStyle(
                          color: theme.colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
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
                    color:
                        theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            _LegendDot(color: incomeColor, label: l10n.cashFlowIncome),
            _LegendDot(color: expenseColor, label: l10n.cashFlowExpense),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
