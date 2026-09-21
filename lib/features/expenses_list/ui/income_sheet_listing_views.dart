import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_group_row.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/model/income_chart_aggregator.dart';
import 'package:valtero/features/expenses_list/ui/grouped_expense_table.dart';
import 'package:valtero/features/expenses_list/ui/income_chart.dart';
import 'package:valtero/features/add_income/ui/add_income_sheet.dart';
import 'package:valtero/features/add_income/ui/income_delete_flow.dart';
import 'package:valtero/features/expenses_list/ui/income_table.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/infinite_scroll_ellipsis.dart';

/// List / grouping / chart body inside the income listing card.
class IncomeSheetListingViews extends ConsumerWidget {
  final ExpenseListViewMode view;
  final List<Income> filtered;
  final List<Income> pageItems;
  final bool hasMoreList;
  final List<ExpenseGroupRow>? groupRows;
  final Map<int, List<int>> incomeTags;
  final Map<int, String> tagLabels;
  final Map<int, String> paymentLabels;
  final List<Tag> tags;
  final List<PaymentMethod> paymentMethods;
  final Set<int> possibleDuplicateIds;
  final Set<int> selectedIds;
  final ValueChanged<int> onToggleSelected;
  final VoidCallback onToggleSelectAll;
  final bool allSelectableSelected;
  final String? displayCurrency;
  final int? Function(Income income) convertedMinor;
  final String summaryCurrency;
  final String snapshotKey;
  final RateResolver resolver;
  final ExpenseChartBreakdown chartBreakdown;
  final ExpenseChartType chartType;
  final String timeZoneId;
  final DateTime? periodFrom;
  final DateTime? periodTo;
  final bool includeSubcategories;
  final bool showSubcategories;
  final ValueChanged<bool>? onShowSubcategoriesChanged;
  final ValueChanged<ExpenseChartBreakdown> onChartBreakdownChanged;
  final ValueChanged<ExpenseChartType> onChartTypeChanged;
  final ValueChanged<DonutChartSlice> onSegmentTap;
  final String emptyMessage;

  const IncomeSheetListingViews({
    super.key,
    required this.view,
    required this.filtered,
    required this.pageItems,
    required this.hasMoreList,
    required this.groupRows,
    required this.incomeTags,
    required this.tagLabels,
    required this.paymentLabels,
    required this.tags,
    required this.paymentMethods,
    required this.possibleDuplicateIds,
    required this.selectedIds,
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
    this.periodFrom,
    this.periodTo,
    this.includeSubcategories = false,
    this.showSubcategories = false,
    this.onShowSubcategoriesChanged,
    required this.onChartBreakdownChanged,
    required this.onChartTypeChanged,
    required this.onSegmentTap,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tagParentIds = {for (final t in tags) t.id: t.parentTagId};
    return switch (view) {
      ExpenseListViewMode.list => Column(
          children: [
            IncomeTable(
              items: pageItems,
              incomeTags: incomeTags,
              tagLabels: tagLabels,
              tagParentIds: tagParentIds,
              paymentLabels: paymentLabels,
              untaggedLabel: l10n.untagged,
              displayCurrency: displayCurrency,
              convertedMinor: convertedMinor,
              possibleDuplicateIds: possibleDuplicateIds,
              selectedIds: selectedIds,
              onToggleSelected: onToggleSelected,
              onToggleSelectAll: onToggleSelectAll,
              allSelectableSelected: allSelectableSelected,
              onDelete: (id) {
                final match = filtered.where((e) => e.id == id);
                confirmAndDeleteIncome(
                  context,
                  ref,
                  id,
                  income: match.isEmpty ? null : match.first,
                );
              },
              onOpen: (income) => showAddIncomeSheet(context, income: income),
              onEdit: (income) => showAddIncomeSheet(context, income: income),
            ),
            if (hasMoreList) const InfiniteScrollEllipsis(),
          ],
        ),
      ExpenseListViewMode.grouping => GroupedExpenseTable(rows: groupRows!),
      ExpenseListViewMode.chart => IncomeChart(
          key: ValueKey(
            'income-chart-$snapshotKey-${chartBreakdown.name}-$summaryCurrency-'
            '${chartType.name}-$includeSubcategories',
          ),
          slicesFuture: chartType == ExpenseChartType.columnByDate ||
                  chartType == ExpenseChartType.line
              ? null
              : aggregateIncomesForChart(
                  incomes: filtered,
                  primaryCurrency: summaryCurrency,
                  resolver: resolver,
                  breakdown: chartBreakdown,
                  incomeTags: incomeTags,
                  tagLabels: tagLabels,
                  tagById: {for (final t in tags) t.id: t},
                  paymentById: {for (final m in paymentMethods) m.id: m},
                  paymentLabels: paymentLabels,
                  untaggedLabel: chartBreakdown == ExpenseChartBreakdown.tagCustom
                      ? l10n.tagKindUnspecifiedIncome
                      : unspecifiedLabelForChartBreakdown(l10n, chartBreakdown),
                  countryLabel: (code) => countryDisplayName(
                    code,
                    languageCode: Localizations.localeOf(context).languageCode,
                  ),
                  timeZoneId: timeZoneId,
                  includeSubcategories: includeSubcategories,
                ),
          timeSeriesFuture: chartType == ExpenseChartType.columnByDate ||
                  chartType == ExpenseChartType.line
              ? aggregateIncomesForTimeSeries(
                  incomes: filtered,
                  primaryCurrency: summaryCurrency,
                  resolver: resolver,
                  targetBreakdown: chartBreakdown,
                  incomeTags: incomeTags,
                  tagLabels: tagLabels,
                  tagById: {for (final t in tags) t.id: t},
                  paymentById: {for (final m in paymentMethods) m.id: m},
                  paymentLabels: paymentLabels,
                  untaggedLabel: chartBreakdown == ExpenseChartBreakdown.tagCustom
                      ? l10n.tagKindUnspecifiedIncome
                      : unspecifiedLabelForChartBreakdown(l10n, chartBreakdown),
                  otherLabel: l10n.chartOtherSeries,
                  periodFrom: periodFrom,
                  periodTo: periodTo,
                  countryLabel: (code) => countryDisplayName(
                    code,
                    languageCode: Localizations.localeOf(context).languageCode,
                  ),
                  timeZoneId: timeZoneId,
                  includeSubcategories: includeSubcategories,
                )
              : null,
          primaryCurrency: summaryCurrency,
          chartBreakdown: chartBreakdown,
          chartType: chartType,
          onChartBreakdownChanged: onChartBreakdownChanged,
          onChartTypeChanged: onChartTypeChanged,
          onSegmentTap: onSegmentTap,
          emptyMessage: emptyMessage,
          showSubcategories: showSubcategories,
          onShowSubcategoriesChanged: chartBreakdown ==
                  ExpenseChartBreakdown.tagCustom
              ? onShowSubcategoriesChanged
              : null,
        ),
    };
  }
}
