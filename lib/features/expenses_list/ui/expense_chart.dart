import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_aggregator.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_drill_down.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/ui/breakdown_chart_view.dart';
import 'package:valtero/features/expenses_list/ui/chart_breakdown_icons.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/feature_help_sheet.dart';

/// Expenses-list chart view: loads slices then renders [BreakdownChartView].
class ExpenseChart extends StatelessWidget {
  final Future<ExpenseChartAggregation> future;
  final String primaryCurrency;
  final ExpenseChartBreakdown chartBreakdown;
  final ExpenseChartType chartType;
  final ValueChanged<ExpenseChartBreakdown> onChartBreakdownChanged;
  final ValueChanged<ExpenseChartType> onChartTypeChanged;
  final ValueChanged<DonutChartSlice>? onSegmentTap;

  const ExpenseChart({
    super.key,
    required this.future,
    required this.primaryCurrency,
    required this.chartBreakdown,
    required this.chartType,
    required this.onChartBreakdownChanged,
    required this.onChartTypeChanged,
    this.onSegmentTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<ExpenseChartAggregation>(
      future: future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snap.data!;
        final slices = data.slices;
        final missingRates = data.missingRateCount;
        final hideSegmentAmounts = missingRates > 0 &&
            chartBreakdown != ExpenseChartBreakdown.currency;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              if (missingRates > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MaterialBanner(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    leading: Icon(
                      Icons.warning_amber_outlined,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    content: Text(l10n.chartMissingRatesAlert(missingRates)),
                    actions: [
                      TextButton(
                        onPressed: () => showFeatureHelpSheet(
                          context,
                          title: l10n.chartHelpTitle,
                          body: l10n.chartHelpBody,
                        ),
                        child: Text(l10n.chartHelpTitle),
                      ),
                    ],
                  ),
                ),
              BreakdownChartView(
                key: ValueKey(
                  '${chartBreakdown.name}_'
                  '${slices.map((s) => s.key).join('|')}',
                ),
                slices: slices,
                displayCurrency: primaryCurrency,
                chartType: chartType,
                onChartTypeChanged: onChartTypeChanged,
                hideCenterTotal: missingRates > 0 ||
                    chartBreakdown == ExpenseChartBreakdown.currency,
                hideSegmentAmounts: hideSegmentAmounts,
                onSegmentTap: onSegmentTap,
                emptyMessage: l10n.noMatchingExpenses,
              ),
              const SizedBox(height: 8),
              ChartBreakdownIcons(
                selected: chartBreakdown,
                onChanged: onChartBreakdownChanged,
              ),
              if (expenseChartBreakdownUsesTagKind(chartBreakdown) ||
                  expenseChartBreakdownUsesPayment(chartBreakdown)) ...[
                const SizedBox(height: 4),
                Text(
                  expenseChartBreakdownUsesPayment(chartBreakdown)
                      ? l10n.chartPaymentHint
                      : l10n.chartTagKindHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
