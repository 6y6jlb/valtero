import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_aggregator.dart';
import 'package:valtero/features/expenses_list/model/chart_time_series.dart';
import 'package:valtero/features/expenses_list/model/cycle_index.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_drill_down.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/model/recent_operation.dart';
import 'package:valtero/features/expenses_list/model/transaction_direction.dart';
import 'package:valtero/features/expenses_list/ui/breakdown_chart_view.dart';
import 'package:valtero/features/expenses_list/ui/cash_flow_chart_view.dart';
import 'package:valtero/features/expenses_list/ui/chart_horizontal_cycle.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_summary_bar.dart';
import 'package:valtero/features/expenses_list/ui/operation_direction_tabs.dart';
import 'package:valtero/features/expenses_list/ui/recent_cash_flow_operations_list.dart';
import 'package:valtero/features/expenses_list/ui/recent_income_operations_list.dart';
import 'package:valtero/features/expenses_list/ui/recent_operations_list.dart';
import 'package:valtero/features/google_drive_sync/ui/google_drive_pull_to_sync.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_page_scaffold.dart';
import 'package:valtero/widgets/feature_help_sheet.dart';
import 'package:valtero/widgets/infinite_scroll_ellipsis.dart';

const kDashboardRecentInitial = 5;
const kDashboardRecentBatch = 5;

/// Scrollable dashboard content: direction tabs, sample banner, filters,
/// chart, recent list. [direction] switches the chart/list between
/// expenses, income, and combined cash flow (see [TransactionDirection]);
/// callers pass the matching slices/buckets/recent rows for the active
/// direction while keeping the expense-only path untouched by default.
class DashboardBody extends ConsumerStatefulWidget {
  final TransactionDirection direction;
  final ValueChanged<TransactionDirection> onDirectionChanged;
  final List<DonutChartSlice> slices;
  final ChartTimeSeriesAggregation? timeSeries;
  final int missingRateCount;
  final String displayCurrency;
  final ExpenseChartBreakdown breakdown;
  final ExpenseChartType chartType;
  final ExpenseListQuery applied;
  final List<Expense> recentExpenses;
  final Map<int, List<int>> expenseTags;
  final List<Income> recentIncomes;
  final Map<int, List<int>> incomeTags;
  final List<CashFlowBucket> cashFlowBuckets;
  final Map<int, String> tagLabels;
  final Map<int, String> paymentLabels;
  final bool isSample;
  /// True while chart aggregation is in flight — show a spinner in the chart
  /// slot instead of an empty stub (avoids flash on direction tab switch).
  final bool chartLoading;
  /// True when the user has any rows of the active kind (before filters).
  /// Used so empty charts say "nothing matches" vs "none yet".
  final bool hasSourceData;
  final ValueChanged<ExpenseChartBreakdown> onBreakdownChanged;
  final ValueChanged<ExpenseChartType> onChartTypeChanged;
  final bool showSubcategories;
  final ValueChanged<bool>? onShowSubcategoriesChanged;
  final VoidCallback onOpenFilters;
  final ValueChanged<DonutChartSlice>? onSegmentTap;
  final VoidCallback? onOpenGuide;
  final VoidCallback? onRestoreFromBackup;

  const DashboardBody({
    super.key,
    required this.direction,
    required this.onDirectionChanged,
    required this.slices,
    this.timeSeries,
    required this.missingRateCount,
    required this.displayCurrency,
    required this.breakdown,
    required this.chartType,
    required this.applied,
    required this.recentExpenses,
    required this.expenseTags,
    this.recentIncomes = const [],
    this.incomeTags = const {},
    this.cashFlowBuckets = const [],
    required this.tagLabels,
    required this.paymentLabels,
    required this.isSample,
    this.chartLoading = false,
    this.hasSourceData = false,
    required this.onBreakdownChanged,
    required this.onChartTypeChanged,
    this.showSubcategories = false,
    this.onShowSubcategoriesChanged,
    required this.onOpenFilters,
    this.onSegmentTap,
    this.onOpenGuide,
    this.onRestoreFromBackup,
  });

  @override
  ConsumerState<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends ConsumerState<DashboardBody> {
  int _recentVisibleCount = kDashboardRecentInitial;
  bool _recentLoadScheduled = false;

  int _totalRecentCount() {
    return switch (widget.direction) {
      TransactionDirection.expenses => widget.recentExpenses.length,
      TransactionDirection.income => widget.recentIncomes.length,
      TransactionDirection.cashFlow =>
        widget.recentExpenses.length + widget.recentIncomes.length,
    };
  }

  Widget _buildChart(AppLocalizations l10n) {
    if (widget.chartLoading) {
      // Match default chartHeight so the layout does not jump when data lands.
      return const SizedBox(
        height: 312,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final emptyYet = switch (widget.direction) {
      TransactionDirection.income => l10n.noIncomeYet,
      TransactionDirection.expenses => l10n.noExpenses,
      TransactionDirection.cashFlow => l10n.noOperationsYet,
    };
    final emptyFiltered = switch (widget.direction) {
      TransactionDirection.income => l10n.noMatchingIncome,
      TransactionDirection.expenses => l10n.noMatchingExpenses,
      TransactionDirection.cashFlow => l10n.noMatchingOperations,
    };
    final emptyMessage = widget.isSample || !widget.hasSourceData
        ? emptyYet
        : emptyFiltered;
    final emptyIcon = switch (widget.direction) {
      TransactionDirection.income => Icons.south_west_outlined,
      TransactionDirection.expenses => Icons.north_east_outlined,
      TransactionDirection.cashFlow => Icons.pie_chart_outline,
    };
    if (widget.direction == TransactionDirection.cashFlow) {
      return CashFlowChartView(
        buckets: widget.cashFlowBuckets,
        displayCurrency: widget.displayCurrency,
        chartType: widget.chartType,
        onChartTypeChanged: widget.onChartTypeChanged,
        breakdown: widget.breakdown,
        onBreakdownChanged: widget.onBreakdownChanged,
        hideAmounts: widget.missingRateCount > 0,
        emptyMessage: emptyMessage,
        emptyIcon: emptyIcon,
      );
    }
    final missingRates = widget.timeSeries?.missingRateCount ??
        widget.missingRateCount;
    return BreakdownChartView(
      key: ValueKey(
        'dash-${widget.breakdown.name}-${widget.slices.length}-'
        '${widget.timeSeries?.points.length ?? 0}',
      ),
      slices: widget.slices,
      timeSeries: widget.timeSeries,
      displayCurrency: widget.displayCurrency,
      chartType: widget.chartType,
      onChartTypeChanged: widget.onChartTypeChanged,
      breakdown: widget.breakdown,
      onBreakdownChanged: widget.onBreakdownChanged,
      showSubcategories: widget.showSubcategories,
      onShowSubcategoriesChanged: widget.onShowSubcategoriesChanged,
      hideCenterTotal: missingRates > 0 ||
          widget.breakdown == ExpenseChartBreakdown.currency,
      hideSegmentAmounts: missingRates > 0 &&
          widget.breakdown != ExpenseChartBreakdown.currency,
      emptyMessage: emptyMessage,
      emptyIcon: emptyIcon,
      onSegmentTap: widget.isSample ? null : widget.onSegmentTap,
    );
  }

  Widget _buildRecentList(int visibleCount) {
    return switch (widget.direction) {
      TransactionDirection.expenses => RecentOperationsList(
          expenses: ([...widget.recentExpenses]
                ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt)))
              .take(visibleCount)
              .toList(),
          expenseTags: widget.expenseTags,
          tagLabels: widget.tagLabels,
          paymentLabels: widget.paymentLabels,
        ),
      TransactionDirection.income => RecentIncomeOperationsList(
          incomes: ([...widget.recentIncomes]
                ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt)))
              .take(visibleCount)
              .toList(),
          incomeTags: widget.incomeTags,
          tagLabels: widget.tagLabels,
          paymentLabels: widget.paymentLabels,
        ),
      TransactionDirection.cashFlow => RecentCashFlowOperationsList(
          operations: mergeRecentOperations(
            expenses: widget.recentExpenses,
            incomes: widget.recentIncomes,
          ).take(visibleCount).toList(),
          paymentLabels: widget.paymentLabels,
          expenseTags: widget.expenseTags,
          incomeTags: widget.incomeTags,
          tagLabels: widget.tagLabels,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final totalRecent = _totalRecentCount();
    final visibleCount = _recentVisibleCount.clamp(0, totalRecent);
    final hasMoreRecent = visibleCount < totalRecent;

    return ChartHorizontalCycle(
      onNext: () => widget.onDirectionChanged(
        cycleIndex(
          TransactionDirection.values,
          widget.direction,
          forward: true,
        ),
      ),
      onPrevious: () => widget.onDirectionChanged(
        cycleIndex(
          TransactionDirection.values,
          widget.direction,
          forward: false,
        ),
      ),
      child: NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!hasMoreRecent || _recentLoadScheduled) return false;
        if (!isNearScrollBottom(notification)) return false;
        _recentLoadScheduled = true;
        final total = totalRecent;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _recentVisibleCount =
                (_recentVisibleCount + kDashboardRecentBatch).clamp(0, total);
          });
          _recentLoadScheduled = false;
        });
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => triggerPullToRefreshSync(context, ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, kFabBottomPadding),
          children: [
            Align(
              alignment: Alignment.center,
              child: OperationDirectionTabs(
                selected: widget.direction,
                onChanged: widget.onDirectionChanged,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.isSample && !widget.chartLoading) ...[
              _DashboardSampleBanner(
                onOpenGuide: widget.onOpenGuide,
                onRestoreFromBackup: widget.onRestoreFromBackup,
              ),
              const SizedBox(height: 16),
            ],
            if (!widget.isSample &&
                !widget.chartLoading &&
                widget.missingRateCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MaterialBanner(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: Icon(
                    Icons.warning_amber_outlined,
                    color: theme.colorScheme.error,
                  ),
                  content: Text(
                    widget.direction == TransactionDirection.expenses
                        ? l10n.chartMissingRatesAlert(widget.missingRateCount)
                        : l10n.chartMissingRatesAlertGeneric(
                            widget.missingRateCount,
                          ),
                  ),
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
            ExpensesFilterSummaryBar(
              draft: widget.applied,
              onTap: widget.onOpenFilters,
            ),
            const SizedBox(height: 12),
            _buildChart(l10n),
            if (!widget.chartLoading &&
                widget.direction != TransactionDirection.cashFlow &&
                (expenseChartBreakdownUsesTagKind(widget.breakdown) ||
                    expenseChartBreakdownUsesPayment(widget.breakdown))) ...[
              const SizedBox(height: 4),
              Text(
                expenseChartBreakdownUsesPayment(widget.breakdown)
                    ? l10n.chartPaymentHint
                    : chartTagKindHintText(
                        l10n,
                        showSubcategories: widget.showSubcategories,
                      ),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (!widget.isSample && totalRecent > 0) ...[
              const SizedBox(height: 20),
              Text(
                l10n.recentOperations,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              _buildRecentList(visibleCount),
              if (hasMoreRecent) const InfiniteScrollEllipsis(),
            ],
          ],
        ),
      ),
    ),
    );
  }
}

class _DashboardSampleBanner extends StatelessWidget {
  final VoidCallback? onOpenGuide;
  final VoidCallback? onRestoreFromBackup;

  const _DashboardSampleBanner({
    this.onOpenGuide,
    this.onRestoreFromBackup,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final linkStyle = TextButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return Material(
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dashboardSampleChartLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            if (onOpenGuide != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onOpenGuide,
                  style: linkStyle,
                  child: Text(l10n.dashboardOpenGuide),
                ),
              ),
            if (onRestoreFromBackup != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onRestoreFromBackup,
                  style: linkStyle,
                  child: Text(l10n.dashboardRestoreFromBackup),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
