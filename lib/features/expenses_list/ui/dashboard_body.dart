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
import 'package:valtero/features/expenses_list/ui/directional_slide_switcher.dart';
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

/// Scrollable dashboard content: direction tabs stay fixed; filters, chart,
/// and recent list slide horizontally when [direction] changes.
class DashboardBody extends ConsumerStatefulWidget {
  final TransactionDirection direction;
  final ValueChanged<TransactionDirection> onDirectionChanged;

  /// Slide direction for the last tab change (true = next / from the right).
  final bool directionSlideForward;
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

  /// True while chart aggregation is in flight. Keeps the previous chart
  /// visible when possible instead of replacing the plot with a spinner.
  final bool chartLoading;

  /// True when the user has any rows of the active kind (before filters).
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
    this.directionSlideForward = true,
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

  late ScrollController _scrollController;
  double _preservedOffset = 0;
  final List<ScrollController> _pendingDispose = [];

  List<DonutChartSlice>? _cachedSlices;
  ChartTimeSeriesAggregation? _cachedTimeSeries;
  List<CashFlowBucket>? _cachedBuckets;
  int? _cachedMissingRates;
  ExpenseChartBreakdown? _cachedBreakdown;
  ExpenseChartType? _cachedChartType;
  TransactionDirection? _cachedDirection;
  bool? _cachedShowSubcategories;
  bool? _cachedIsSample;
  bool? _cachedHasSourceData;
  String? _cachedDisplayCurrency;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: _preservedOffset,
    );
    _scrollController.addListener(_rememberOffset);
    _cacheChartIfReady();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_rememberOffset);
    _scrollController.dispose();
    for (final c in _pendingDispose) {
      c.dispose();
    }
    super.dispose();
  }

  void _rememberOffset() {
    if (_scrollController.hasClients) {
      _preservedOffset = _scrollController.offset;
    }
  }

  void _cacheChartIfReady() {
    if (widget.chartLoading) return;
    _cachedSlices = widget.slices;
    _cachedTimeSeries = widget.timeSeries;
    _cachedBuckets = widget.cashFlowBuckets;
    _cachedMissingRates = widget.missingRateCount;
    _cachedBreakdown = widget.breakdown;
    _cachedChartType = widget.chartType;
    _cachedDirection = widget.direction;
    _cachedShowSubcategories = widget.showSubcategories;
    _cachedIsSample = widget.isSample;
    _cachedHasSourceData = widget.hasSourceData;
    _cachedDisplayCurrency = widget.displayCurrency;
  }

  bool get _hasCachedChart =>
      _cachedDirection == widget.direction &&
      (_cachedSlices != null ||
          _cachedTimeSeries != null ||
          _cachedBuckets != null);

  @override
  void didUpdateWidget(covariant DashboardBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.direction != widget.direction) {
      final oldController = _scrollController;
      _preservedOffset =
          oldController.hasClients ? oldController.offset : _preservedOffset;
      oldController.removeListener(_rememberOffset);
      _pendingDispose.add(oldController);
      _scrollController = ScrollController(
        initialScrollOffset: _preservedOffset,
      );
      _scrollController.addListener(_rememberOffset);
      Future<void>.delayed(kDirectionalSlideDuration * 2, () {
        if (!mounted) return;
        for (final c in List<ScrollController>.from(_pendingDispose)) {
          c.dispose();
          _pendingDispose.remove(c);
        }
      });
      // New direction: keep pagination count; clear chart cache if direction
      // mismatch so we don't flash the wrong chart during load.
      if (_cachedDirection != widget.direction) {
        _cachedSlices = null;
        _cachedTimeSeries = null;
        _cachedBuckets = null;
      }
    }
    _cacheChartIfReady();
  }

  int _totalRecentCount() {
    return switch (widget.direction) {
      TransactionDirection.expenses => widget.recentExpenses.length,
      TransactionDirection.income => widget.recentIncomes.length,
      TransactionDirection.cashFlow =>
        widget.recentExpenses.length + widget.recentIncomes.length,
    };
  }

  Widget _buildChart(AppLocalizations l10n) {
    final useCache = widget.chartLoading && _hasCachedChart;
    if (widget.chartLoading && !_hasCachedChart) {
      return const SizedBox(
        height: 312,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final direction = useCache ? _cachedDirection! : widget.direction;
    final slices = useCache ? (_cachedSlices ?? const []) : widget.slices;
    final timeSeries = useCache ? _cachedTimeSeries : widget.timeSeries;
    final buckets = useCache
        ? (_cachedBuckets ?? const <CashFlowBucket>[])
        : widget.cashFlowBuckets;
    final missingRateCount =
        useCache ? (_cachedMissingRates ?? 0) : widget.missingRateCount;
    final breakdown = useCache ? _cachedBreakdown! : widget.breakdown;
    final chartType = useCache ? _cachedChartType! : widget.chartType;
    final showSubcategories =
        useCache ? (_cachedShowSubcategories ?? false) : widget.showSubcategories;
    final isSample = useCache ? (_cachedIsSample ?? false) : widget.isSample;
    final hasSourceData =
        useCache ? (_cachedHasSourceData ?? false) : widget.hasSourceData;
    final displayCurrency =
        useCache ? (_cachedDisplayCurrency ?? widget.displayCurrency) : widget.displayCurrency;

    final emptyYet = switch (direction) {
      TransactionDirection.income => l10n.noIncomeYet,
      TransactionDirection.expenses => l10n.noExpenses,
      TransactionDirection.cashFlow => l10n.noOperationsYet,
    };
    final emptyFiltered = switch (direction) {
      TransactionDirection.income => l10n.noMatchingIncome,
      TransactionDirection.expenses => l10n.noMatchingExpenses,
      TransactionDirection.cashFlow => l10n.noMatchingOperations,
    };
    final emptyMessage =
        isSample || !hasSourceData ? emptyYet : emptyFiltered;
    final emptyIcon = switch (direction) {
      TransactionDirection.income => Icons.south_west_outlined,
      TransactionDirection.expenses => Icons.north_east_outlined,
      TransactionDirection.cashFlow => Icons.pie_chart_outline,
    };
    if (direction == TransactionDirection.cashFlow) {
      return CashFlowChartView(
        buckets: buckets,
        displayCurrency: displayCurrency,
        chartType: chartType,
        onChartTypeChanged: widget.onChartTypeChanged,
        breakdown: breakdown,
        onBreakdownChanged: widget.onBreakdownChanged,
        hideAmounts: missingRateCount > 0,
        emptyMessage: emptyMessage,
        emptyIcon: emptyIcon,
      );
    }
    final missingRates = timeSeries?.missingRateCount ?? missingRateCount;
    return BreakdownChartView(
      key: ValueKey(
        'dash-${breakdown.name}-${slices.length}-'
        '${timeSeries?.points.length ?? 0}',
      ),
      slices: slices,
      timeSeries: timeSeries,
      displayCurrency: displayCurrency,
      chartType: chartType,
      onChartTypeChanged: widget.onChartTypeChanged,
      breakdown: breakdown,
      onBreakdownChanged: widget.onBreakdownChanged,
      showSubcategories: showSubcategories,
      onShowSubcategoriesChanged: widget.onShowSubcategoriesChanged,
      hideCenterTotal: missingRates > 0 ||
          breakdown == ExpenseChartBreakdown.currency,
      hideSegmentAmounts: missingRates > 0 &&
          breakdown != ExpenseChartBreakdown.currency,
      emptyMessage: emptyMessage,
      emptyIcon: emptyIcon,
      onSegmentTap: isSample ? null : widget.onSegmentTap,
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

  Widget _buildScrollBody(AppLocalizations l10n, ThemeData theme) {
    final totalRecent = _totalRecentCount();
    final visibleCount = _recentVisibleCount.clamp(0, totalRecent);
    final hasMoreRecent = visibleCount < totalRecent;

    return NotificationListener<ScrollNotification>(
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
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, kFabBottomPadding),
          children: [
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Align(
            alignment: Alignment.center,
            child: OperationDirectionTabs(
              selected: widget.direction,
              onChanged: widget.onDirectionChanged,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: InteractiveSlidePager(
            pageKey: widget.direction,
            externalForward: widget.directionSlideForward,
            expand: true,
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
            neighborBuilder: (forward) {
              final next = cycleIndex(
                TransactionDirection.values,
                widget.direction,
                forward: forward,
              );
              return IgnorePointer(
                child: _buildNeighborPeek(l10n, theme, next),
              );
            },
            child: _buildScrollBody(l10n, theme),
          ),
        ),
      ],
    );
  }

  /// Lightweight peek of the adjacent tab: filters + chart-sized placeholder +
  /// the recent list for that direction (all three lists are already loaded).
  Widget _buildNeighborPeek(
    AppLocalizations l10n,
    ThemeData theme,
    TransactionDirection direction,
  ) {
    final totalRecent = switch (direction) {
      TransactionDirection.expenses => widget.recentExpenses.length,
      TransactionDirection.income => widget.recentIncomes.length,
      TransactionDirection.cashFlow =>
        widget.recentExpenses.length + widget.recentIncomes.length,
    };
    final visibleCount = _recentVisibleCount.clamp(0, totalRecent);
    final recent = switch (direction) {
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

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, kFabBottomPadding),
      children: [
        ExpensesFilterSummaryBar(
          draft: widget.applied,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 312,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (!widget.isSample && totalRecent > 0) ...[
          const SizedBox(height: 20),
          Text(
            l10n.recentOperations,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          recent,
        ],
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dashboardSampleChartLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (onOpenGuide != null)
                  TextButton(
                    style: linkStyle,
                    onPressed: onOpenGuide,
                    child: Text(l10n.dashboardOpenGuide),
                  ),
                if (onRestoreFromBackup != null)
                  TextButton(
                    style: linkStyle,
                    onPressed: onRestoreFromBackup,
                    child: Text(l10n.dashboardRestoreFromBackup),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
