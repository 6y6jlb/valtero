import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/ui/chart_breakdown_icons.dart';
import 'package:valtero/features/expenses_list/ui/donut_breakdown_chart.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Expenses-list chart view: loads slices then renders [DonutBreakdownChart].
class ExpenseChart extends StatelessWidget {
  final Future<List<DonutChartSlice>> future;
  final String primaryCurrency;
  final ExpenseChartBreakdown chartBreakdown;
  final ValueChanged<ExpenseChartBreakdown> onChartBreakdownChanged;
  final ValueChanged<DonutChartSlice>? onSegmentTap;

  const ExpenseChart({
    super.key,
    required this.future,
    required this.primaryCurrency,
    required this.chartBreakdown,
    required this.onChartBreakdownChanged,
    this.onSegmentTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<DonutChartSlice>>(
      future: future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              DonutBreakdownChart(
                key: ValueKey(
                  '${chartBreakdown.name}_'
                  '${snap.data!.map((s) => s.key).join('|')}',
                ),
                slices: snap.data!,
                displayCurrency: primaryCurrency,
                onSegmentTap: onSegmentTap,
                emptyMessage: l10n.noMatchingExpenses,
              ),
              const SizedBox(height: 8),
              ChartBreakdownIcons(
                selected: chartBreakdown,
                onChanged: onChartBreakdownChanged,
              ),
            ],
          ),
        );
      },
    );
  }
}
