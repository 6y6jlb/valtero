import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/income/model/income_provider.dart';
import 'package:valtero/entities/income/model/income_tags_provider.dart';
import 'package:valtero/entities/payment_method/model/payment_methods_provider.dart';
import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/expenses_list/model/duplicate_income_provider.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/income_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/income_summary_aggregator.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_summary_bar.dart';
import 'package:valtero/features/expenses_list/ui/expenses_sheet_filter_flow.dart';
import 'package:valtero/features/expenses_list/ui/income_duplicate_review_sheet.dart';
import 'package:valtero/features/expenses_list/ui/possible_duplicates_banner.dart';
import 'package:valtero/features/expenses_list/ui/recent_income_operations_list.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/payment_method_label.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/app_toast.dart';
import 'package:valtero/widgets/infinite_scroll_ellipsis.dart';
import 'package:valtero/widgets/money_text.dart';

const _kIncomeListInitial = 25;
const _kIncomeListBatch = 15;

/// Simplified income listing for the Expenses/Income list page: filter bar,
/// possible-duplicates banner, per-currency summary, and the day-grouped
/// income list (tap a row to edit). Mirrors [ExpensesSheetBody]'s shape
/// without the grouping/chart/export machinery — kept intentionally lean
/// per the income direction's v1 scope.
class IncomeListBody extends ConsumerStatefulWidget {
  final ExpenseListQuery initial;

  const IncomeListBody({super.key, required this.initial});

  @override
  ConsumerState<IncomeListBody> createState() => _IncomeListBodyState();
}

class _IncomeListBodyState extends ConsumerState<IncomeListBody> {
  late ExpenseListQuery _applied;
  int _visibleCount = _kIncomeListInitial;
  bool _loadMoreScheduled = false;

  @override
  void initState() {
    super.initState();
    _applied = widget.initial;
  }

  Future<void> _openFilters({
    required List<String> currencyOptions,
    required Map<int, String> tagLabels,
    required Map<int, String> paymentLabels,
    required List<Tag> tags,
    required List<PaymentMethod> paymentMethods,
  }) async {
    final result = await openExpensesFilterSheet(
      context: context,
      draft: _applied,
      currencyOptions: currencyOptions,
      tagLabels: tagLabels,
      paymentLabels: paymentLabels,
      tags: tags,
      paymentMethods: paymentMethods,
      tagKinds: const [TagKind.income],
    );
    if (result == null || !mounted) return;
    setState(() {
      _applied = result;
      _visibleCount = _kIncomeListInitial;
    });
    showAppToast(context, AppLocalizations.of(context)!.filtersApplied);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final incomesAsync = ref.watch(allIncomeProvider);
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final paymentMethods =
        ref.watch(paymentMethodsStreamProvider).value ?? const [];
    final incomeTags = ref.watch(incomeTagIdsProvider).value ?? const {};
    final dupState = ref.watch(duplicateIncomeProvider);
    final settings = ref.watch(appSettingsProvider).value;
    final timeZoneId = settings?.timeZoneId ?? kSystemTimeZoneId;
    final tagLabels = {
      for (final t in tags) t.id: localizedTagLabel(context, t),
    };
    final paymentLabels = {
      for (final m in paymentMethods)
        m.id: localizedPaymentMethodLabel(context, m),
    };

    return incomesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (all) {
        final currencyOptions = <String>{
          for (final i in all) i.storedCurrencyCode,
        }.toList()
          ..sort();
        final filtered = sortIncomes(
          list: filterIncomes(
            all: all,
            query: _applied,
            incomeTags: incomeTags,
            timeZoneId: timeZoneId,
          ),
          query: _applied,
        );
        final byCurrency = aggregateIncomesByCurrency(filtered);
        final visibleCount = _visibleCount.clamp(0, filtered.length);
        final pageItems = filtered.take(visibleCount).toList();
        final hasMore = visibleCount < filtered.length;

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (!hasMore || _loadMoreScheduled) return false;
            if (!isNearScrollBottom(notification)) return false;
            _loadMoreScheduled = true;
            final total = filtered.length;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _visibleCount =
                    (_visibleCount + _kIncomeListBatch).clamp(0, total);
              });
              _loadMoreScheduled = false;
            });
            return false;
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              ExpensesFilterSummaryBar(
                draft: _applied,
                onTap: () => _openFilters(
                  currencyOptions: currencyOptions,
                  tagLabels: tagLabels,
                  paymentLabels: paymentLabels,
                  tags: tags,
                  paymentMethods: paymentMethods,
                ),
              ),
              if (dupState.flaggedCount > 0) ...[
                const SizedBox(height: 8),
                PossibleDuplicatesBanner(
                  flaggedCount: dupState.flaggedCount,
                  onTap: () => showIncomeDuplicateReviewSheet(context),
                ),
              ],
              if (all.isNotEmpty) ...[
                const SizedBox(height: 12),
                _IncomeCurrencySummary(byCurrency: byCurrency),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(l10n.noMatchingIncome)),
                  )
                else
                  RecentIncomeOperationsList(
                    incomes: pageItems,
                    incomeTags: incomeTags,
                    tagLabels: tagLabels,
                    paymentLabels: paymentLabels,
                  ),
                if (hasMore) const InfiniteScrollEllipsis(),
              ] else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text(l10n.noMatchingIncome)),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Compact per-currency income totals card (no conversion — mirrors
/// [ExpensesSummaryRow]'s currency lines without the display-currency flow).
class _IncomeCurrencySummary extends StatelessWidget {
  final List<CurrencyIncomeSummary> byCurrency;

  const _IncomeCurrencySummary({required this.byCurrency});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.cashFlowIncome,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (byCurrency.isEmpty)
              Text(
                '0',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              for (var i = 0; i < byCurrency.length; i++) ...[
                if (i > 0) const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      byCurrency[i].currency,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.summaryPerCurrencyCount(byCurrency[i].count),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    MoneyText(
                      amountMinor: byCurrency[i].totalMinor,
                      currencyCode: byCurrency[i].currency,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
          ],
        ),
      ),
    );
  }
}
