import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_drill_down.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/ui/breakdown_chart_view.dart';
import 'package:valtero/features/expenses_list/ui/chart_breakdown_icons.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_summary_bar.dart';
import 'package:valtero/features/expenses_list/ui/recent_operations_list.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_page_scaffold.dart';
import 'package:valtero/widgets/feature_help_sheet.dart';
import 'package:valtero/widgets/infinite_scroll_ellipsis.dart';

const kDashboardRecentInitial = 5;
const kDashboardRecentBatch = 5;

/// Scrollable dashboard content: sample banner, chart, filters, recent list.
class DashboardBody extends StatefulWidget {
  final List<DonutChartSlice> slices;
  final int missingRateCount;
  final String displayCurrency;
  final ExpenseChartBreakdown breakdown;
  final ExpenseChartType chartType;
  final ExpenseListQuery applied;
  final List<Expense> recentExpenses;
  final Map<int, List<int>> expenseTags;
  final Map<int, String> tagLabels;
  final Map<int, String> paymentLabels;
  final bool isSample;
  final bool loading;
  final ValueChanged<ExpenseChartBreakdown> onBreakdownChanged;
  final ValueChanged<ExpenseChartType> onChartTypeChanged;
  final VoidCallback onOpenFilters;
  final ValueChanged<DonutChartSlice>? onSegmentTap;
  final VoidCallback? onOpenGuide;
  final VoidCallback? onRestoreFromBackup;

  const DashboardBody({
    super.key,
    required this.slices,
    required this.missingRateCount,
    required this.displayCurrency,
    required this.breakdown,
    required this.chartType,
    required this.applied,
    required this.recentExpenses,
    required this.expenseTags,
    required this.tagLabels,
    required this.paymentLabels,
    required this.isSample,
    required this.loading,
    required this.onBreakdownChanged,
    required this.onChartTypeChanged,
    required this.onOpenFilters,
    this.onSegmentTap,
    this.onOpenGuide,
    this.onRestoreFromBackup,
  });

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  int _recentVisibleCount = kDashboardRecentInitial;
  bool _recentLoadScheduled = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final recent = [...widget.recentExpenses]
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    final visibleCount = _recentVisibleCount.clamp(0, recent.length);
    final recentTop = recent.take(visibleCount).toList();
    final hasMoreRecent = visibleCount < recent.length;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!hasMoreRecent || _recentLoadScheduled) return false;
        if (!isNearScrollBottom(notification)) return false;
        _recentLoadScheduled = true;
        final total = recent.length;
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
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, kFabBottomPadding),
        children: [
          if (widget.isSample) ...[
            _DashboardSampleBanner(
              onOpenGuide: widget.onOpenGuide,
              onRestoreFromBackup: widget.onRestoreFromBackup,
            ),
            const SizedBox(height: 16),
          ],
          if (!widget.isSample && widget.missingRateCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MaterialBanner(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                leading: Icon(
                  Icons.warning_amber_outlined,
                  color: theme.colorScheme.error,
                ),
                content: Text(
                  l10n.chartMissingRatesAlert(widget.missingRateCount),
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
          BreakdownChartView(
            key: ValueKey(
              'dash-${widget.breakdown.name}-${widget.slices.length}',
            ),
            slices: widget.slices,
            displayCurrency: widget.displayCurrency,
            chartType: widget.chartType,
            onChartTypeChanged: widget.onChartTypeChanged,
            showTotal: false,
            hideCenterTotal: widget.missingRateCount > 0 ||
                widget.breakdown == ExpenseChartBreakdown.currency,
            hideSegmentAmounts: widget.missingRateCount > 0 &&
                widget.breakdown != ExpenseChartBreakdown.currency,
            emptyMessage: widget.isSample
                ? l10n.noExpenses
                : l10n.noMatchingExpenses,
            onSegmentTap: widget.isSample ? null : widget.onSegmentTap,
          ),
          const SizedBox(height: 8),
          ChartBreakdownIcons(
            selected: widget.breakdown,
            onChanged: widget.onBreakdownChanged,
            showYear: false,
          ),
          if (expenseChartBreakdownUsesTagKind(widget.breakdown) ||
              expenseChartBreakdownUsesPayment(widget.breakdown)) ...[
            const SizedBox(height: 4),
            Text(
              expenseChartBreakdownUsesPayment(widget.breakdown)
                  ? l10n.chartPaymentHint
                  : l10n.chartTagKindHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ExpensesFilterSummaryBar(
            draft: widget.applied,
            onTap: widget.onOpenFilters,
          ),
          if (widget.loading) const LinearProgressIndicator(),
          if (!widget.isSample && recentTop.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              l10n.recentOperations,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            RecentOperationsList(
              expenses: recentTop,
              expenseTags: widget.expenseTags,
              tagLabels: widget.tagLabels,
              paymentLabels: widget.paymentLabels,
            ),
            if (hasMoreRecent) const InfiniteScrollEllipsis(),
          ],
        ],
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
