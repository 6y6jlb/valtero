import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/features/add_expense/ui/add_expense_sheet.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_aggregator.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/model/expense_group_row.dart';
import 'package:valtero/features/expenses_list/ui/expense_chart.dart';
import 'package:valtero/features/expenses_list/ui/expense_delete_flow.dart';
import 'package:valtero/features/expenses_list/ui/expense_detail_sheet.dart';
import 'package:valtero/features/expenses_list/ui/expense_table.dart';
import 'package:valtero/features/expenses_list/ui/grouped_expense_table.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/infinite_scroll_ellipsis.dart';

/// List / grouping / chart body inside [ExpensesListingCard].
class ExpensesSheetListingViews extends ConsumerWidget {
  final ExpenseListViewMode view;
  final List<Expense> filtered;
  final List<Expense> pageItems;
  final bool hasMoreList;
  final List<ExpenseGroupRow>? groupRows;
  final Map<int, List<int>> expenseTags;
  final Map<int, String> tagLabels;
  final Map<int, String> paymentLabels;
  final List<Tag> tags;
  final List<PaymentMethod> paymentMethods;
  final Set<int> selectedIds;
  final Set<int> possibleDuplicateIds;
  final ValueChanged<int> onToggleSelected;
  final VoidCallback onToggleSelectAll;
  final bool allSelectableSelected;
  final String? displayCurrency;
  final int? Function(Expense expense) convertedMinor;
  final String summaryCurrency;
  final String snapshotKey;
  final RateResolver resolver;
  final ExpenseChartBreakdown chartBreakdown;
  final ExpenseChartType chartType;
  final String timeZoneId;
  final ValueChanged<ExpenseChartBreakdown> onChartBreakdownChanged;
  final ValueChanged<ExpenseChartType> onChartTypeChanged;
  final ValueChanged<DonutChartSlice> onSegmentTap;

  const ExpensesSheetListingViews({
    super.key,
    required this.view,
    required this.filtered,
    required this.pageItems,
    required this.hasMoreList,
    required this.groupRows,
    required this.expenseTags,
    required this.tagLabels,
    required this.paymentLabels,
    required this.tags,
    required this.paymentMethods,
    required this.selectedIds,
    required this.possibleDuplicateIds,
    required this.onToggleSelected,
    required this.onToggleSelectAll,
    required this.allSelectableSelected,
    required this.displayCurrency,
    required this.convertedMinor,
    required this.summaryCurrency,
    required this.snapshotKey,
    required this.resolver,
    required this.chartBreakdown,
    required this.chartType,
    required this.timeZoneId,
    required this.onChartBreakdownChanged,
    required this.onChartTypeChanged,
    required this.onSegmentTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return switch (view) {
      ExpenseListViewMode.list => Column(
          children: [
            ExpenseTable(
              items: pageItems,
              expenseTags: expenseTags,
              tagLabels: tagLabels,
              paymentLabels: paymentLabels,
              untaggedLabel: l10n.untagged,
              displayCurrency: displayCurrency,
              convertedMinor: convertedMinor,
              selectedIds: selectedIds,
              possibleDuplicateIds: possibleDuplicateIds,
              onToggleSelected: onToggleSelected,
              onToggleSelectAll: onToggleSelectAll,
              allSelectableSelected: allSelectableSelected,
              onDelete: (id) {
                final match = filtered.where((e) => e.id == id);
                confirmAndDeleteExpense(
                  context,
                  ref,
                  id,
                  expense: match.isEmpty ? null : match.first,
                );
              },
              onOpen: (expense) => openExpenseDetail(
                context,
                ref,
                expense: expense,
                expenseTags: expenseTags,
                tagLabels: tagLabels,
                paymentLabels: paymentLabels,
              ),
              onEdit: (expense) =>
                  showAddExpenseSheet(context, expense: expense),
            ),
            if (hasMoreList) const InfiniteScrollEllipsis(),
          ],
        ),
      ExpenseListViewMode.grouping => GroupedExpenseTable(rows: groupRows!),
      ExpenseListViewMode.chart => ExpenseChart(
          key: ValueKey(
            'chart-$snapshotKey-${chartBreakdown.name}-$summaryCurrency',
          ),
          future: aggregateExpensesForChart(
            expenses: filtered,
            primaryCurrency: summaryCurrency,
            resolver: resolver,
            breakdown: chartBreakdown,
            expenseTags: expenseTags,
            tagLabels: tagLabels,
            tagById: {for (final t in tags) t.id: t},
            paymentById: {for (final m in paymentMethods) m.id: m},
            paymentLabels: paymentLabels,
            untaggedLabel: unspecifiedLabelForChartBreakdown(
              l10n,
              chartBreakdown,
            ),
            countryLabel: (code) => countryDisplayName(
              code,
              languageCode: Localizations.localeOf(context).languageCode,
            ),
            timeZoneId: timeZoneId,
          ),
          primaryCurrency: summaryCurrency,
          chartBreakdown: chartBreakdown,
          chartType: chartType,
          onChartBreakdownChanged: onChartBreakdownChanged,
          onChartTypeChanged: onChartTypeChanged,
          onSegmentTap: onSegmentTap,
        ),
    };
  }
}
