import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/chart_time_series.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_aggregator.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_drill_down.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/ui/breakdown_chart_view.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/feature_help_sheet.dart';

bool _usesTimeSeriesChart(ExpenseChartType type) {
  return type == ExpenseChartType.columnByDate ||
      type == ExpenseChartType.line;
}

/// Expenses-list chart view: loads slices or time-series then renders
/// [BreakdownChartView].
class ExpenseChart extends StatelessWidget {
  final Future<ExpenseChartAggregation>? slicesFuture;
  final Future<ChartTimeSeriesAggregation>? timeSeriesFuture;
  final String primaryCurrency;
  final ExpenseChartBreakdown chartBreakdown;
  final ExpenseChartType chartType;
  final ValueChanged<ExpenseChartBreakdown> onChartBreakdownChanged;
  final ValueChanged<ExpenseChartType> onChartTypeChanged;
  final ValueChanged<DonutChartSlice>? onSegmentTap;
  final bool showSubcategories;
  final ValueChanged<bool>? onShowSubcategoriesChanged;

  const ExpenseChart({
    super.key,
    this.slicesFuture,
    this.timeSeriesFuture,
    required this.primaryCurrency,
    required this.chartBreakdown,
    required this.chartType,
    required this.onChartBreakdownChanged,
    required this.onChartTypeChanged,
    this.onSegmentTap,
    this.showSubcategories = false,
    this.onShowSubcategoriesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_usesTimeSeriesChart(chartType)) {
      return FutureBuilder<ChartTimeSeriesAggregation>(
        future: timeSeriesFuture,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildContent(
            context,
            l10n,
            slices: const [],
            timeSeries: snap.data,
            missingRates: snap.data!.missingRateCount,
          );
        },
      );
    }
    return FutureBuilder<ExpenseChartAggregation>(
      future: slicesFuture,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snap.data!;
        return _buildContent(
          context,
          l10n,
          slices: data.slices,
          missingRates: data.missingRateCount,
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n, {
    required List<DonutChartSlice> slices,
    ChartTimeSeriesAggregation? timeSeries,
    required int missingRates,
  }) {
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
              '${slices.map((s) => s.key).join('|')}_'
              '${timeSeries?.points.length ?? 0}',
            ),
            slices: slices,
            timeSeries: timeSeries,
            displayCurrency: primaryCurrency,
            chartType: chartType,
            onChartTypeChanged: onChartTypeChanged,
            breakdown: chartBreakdown,
            onBreakdownChanged: onChartBreakdownChanged,
            showSubcategories: showSubcategories,
            onShowSubcategoriesChanged: onShowSubcategoriesChanged,
            hideCenterTotal: missingRates > 0 ||
                chartBreakdown == ExpenseChartBreakdown.currency,
            hideSegmentAmounts: hideSegmentAmounts,
            onSegmentTap: onSegmentTap,
            emptyMessage: l10n.noMatchingExpenses,
          ),
          if (expenseChartBreakdownUsesTagKind(chartBreakdown) ||
              expenseChartBreakdownUsesPayment(chartBreakdown)) ...[
            const SizedBox(height: 4),
            Text(
              expenseChartBreakdownUsesPayment(chartBreakdown)
                  ? l10n.chartPaymentHint
                  : chartTagKindHintText(
                      l10n,
                      showSubcategories: showSubcategories,
                    ),
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
  }
}
