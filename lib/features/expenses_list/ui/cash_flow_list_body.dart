import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/expense/model/expense_tags_provider.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/income/model/income_provider.dart';
import 'package:valtero/entities/income/model/income_tags_provider.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/entities/integrations/telegram/model/telegram_integration.dart';
import 'package:valtero/entities/payment_method/model/payment_methods_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_list_export.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_list_selection.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_selection_key.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_summary_aggregator.dart';
import 'package:valtero/features/expenses_list/model/duplicate_expenses_provider.dart';
import 'package:valtero/features/expenses_list/model/duplicate_income_provider.dart';
import 'package:valtero/features/expenses_list/model/expense_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/model/expenses_list_display_prefs.dart';
import 'package:valtero/features/expenses_list/model/grouping/cash_flow_grouper.dart';
import 'package:valtero/features/expenses_list/model/grouping/cash_flow_grouper_for.dart';
import 'package:valtero/features/expenses_list/model/income_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/recent_operation.dart';
import 'package:valtero/features/expenses_list/ui/cash_flow_empty_placeholder.dart';
import 'package:valtero/features/expenses_list/ui/cash_flow_sheet_listing_views.dart';
import 'package:valtero/features/expenses_list/ui/cash_flow_summary_row.dart';
import 'package:valtero/features/expenses_list/ui/duplicate_review_sheet.dart';
import 'package:valtero/features/expenses_list/ui/expenses_display_rates_controller.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_summary_bar.dart';
import 'package:valtero/features/expenses_list/ui/expenses_listing_card.dart';
import 'package:valtero/features/expenses_list/ui/expenses_sheet_filter_flow.dart';
import 'package:valtero/features/expenses_list/ui/income_duplicate_review_sheet.dart';
import 'package:valtero/features/expenses_list/ui/possible_duplicates_banner.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/features/export_expenses/model/export_destination.dart';
import 'package:valtero/features/export_expenses/ui/export_flow.dart';
import 'package:valtero/features/google_drive_sync/ui/google_drive_pull_to_sync.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/payment_method_label.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/app_toast.dart';
import 'package:valtero/widgets/infinite_scroll_ellipsis.dart';

const _kCashFlowListInitial = 25;
const _kCashFlowListBatch = 15;

/// Full cash-flow listing: filters, summary (+ convert), list/group/chart views,
/// sort, export, duplicates — mirrors [IncomeListBody].
class CashFlowListBody extends ConsumerStatefulWidget {
  final ExpenseListQuery initial;

  const CashFlowListBody({super.key, required this.initial});

  @override
  ConsumerState<CashFlowListBody> createState() => _CashFlowListBodyState();
}

class _CashFlowListBodyState extends ConsumerState<CashFlowListBody> {
  late ExpenseListQuery _draft;
  late ExpenseListQuery _applied;
  ExpenseListViewMode _view = ExpenseListViewMode.list;
  ExpenseChartBreakdown _chartDatePeriod = ExpenseChartBreakdown.month;
  ExpenseChartType _chartType = ExpenseChartType.donut;
  int _visibleCount = _kCashFlowListInitial;
  bool _loadMoreScheduled = false;
  bool _displayPrefsLoaded = false;
  late final ExpensesDisplayRatesController _displayRates;

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
    _applied = widget.initial;
    if (widget.initial.group != ExpenseListGroup.none) {
      _view = ExpenseListViewMode.grouping;
    }
    _displayRates = ExpensesDisplayRatesController(
      onChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  void _scheduleDisplayPrefsLoad() {
    if (_displayPrefsLoaded) return;
    if (ref.read(appSettingsProvider).value == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _displayPrefsLoaded) return;
      final settings = ref.read(appSettingsProvider).value;
      if (settings == null) return;
      _displayPrefsLoaded = true;
      final view = cashFlowViewModeFromSettings(settings);
      final group = cashFlowGroupFromSettings(settings);
      setState(() {
        _view = view;
        _chartDatePeriod = cashFlowChartDatePeriodFromSettings(settings);
        _chartType = cashFlowChartTypeFromSettings(settings);
        _applied = _applied.copyWith(
          group: view == ExpenseListViewMode.list
              ? ExpenseListGroup.none
              : group,
        );
      });
    });
  }

  void _persistDisplayPrefs({
    ExpenseListViewMode? view,
    ExpenseListGroup? group,
    ExpenseChartBreakdown? chartDatePeriod,
    ExpenseChartType? chartType,
  }) {
    final values = cashFlowListDisplayPersistValues(
      view: view ?? _view,
      appliedGroup: group ?? _applied.group,
      chartDatePeriod: chartDatePeriod ?? _chartDatePeriod,
      chartType: chartType ?? _chartType,
    );
    ref.read(appSettingsProvider.notifier).setCashFlowListDisplay(
          view: values.view,
          group: values.group,
          chartDatePeriod: values.chartDatePeriod,
          chartType: values.chartType,
        );
  }

  List<RecentOperation> _filteredOperations({
    required List<Expense> expenses,
    required List<Income> incomes,
    required Map<int, List<int>> expenseTags,
    required Map<int, List<int>> incomeTags,
    required Set<int> possibleDuplicateExpenseIds,
    required Set<int> possibleDuplicateIncomeIds,
    required String timeZoneId,
  }) =>
      sortCashFlowOperations(
        list: filterCashFlowOperations(
          expenses: expenses,
          incomes: incomes,
          query: _applied,
          expenseTags: expenseTags,
          incomeTags: incomeTags,
          possibleDuplicateExpenseIds: possibleDuplicateExpenseIds,
          possibleDuplicateIncomeIds: possibleDuplicateIncomeIds,
          timeZoneId: timeZoneId,
        ),
        query: _applied,
        displayRates: _displayRates.displayRates,
        displayCurrency: _displayRates.displayCurrency,
      );

  Future<void> _openFilters({
    required List<String> currencyOptions,
    required Map<int, String> tagLabels,
    required Map<int, String> paymentLabels,
    required List<Tag> tags,
    required List<PaymentMethod> paymentMethods,
  }) async {
    final result = await openExpensesFilterSheet(
      context: context,
      draft: _draft,
      currencyOptions: currencyOptions,
      tagLabels: tagLabels,
      paymentLabels: paymentLabels,
      tags: tags,
      paymentMethods: paymentMethods,
    );
    if (result == null || !mounted) return;
    setState(() {
      _draft = result;
      _applied = result.copyWith(
        group: _applied.group,
        sort: _applied.sort,
        ascending: _applied.ascending,
      );
      _visibleCount = _kCashFlowListInitial;
    });
    ref.read(cashFlowListSelectionProvider.notifier).clear();
    showAppToast(context, AppLocalizations.of(context)!.filtersApplied);
  }

  Future<void> _export(
    ExportFormat format, {
    required ExportDestination destination,
  }) async {
    await performExport(
      context,
      ref,
      format: format,
      destination: destination,
      run: () => exportFilteredCashFlow(
        ref,
        context,
        format: format,
        destination: destination,
        query: _applied,
        displayRates: _displayRates.displayRates,
        displayCurrency: _displayRates.displayCurrency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ref.watch(appSettingsProvider);
    _scheduleDisplayPrefsLoad();
    final expensesAsync = ref.watch(allExpensesProvider);
    final incomesAsync = ref.watch(allIncomeProvider);
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final paymentMethods =
        ref.watch(paymentMethodsStreamProvider).value ?? const [];
    final expenseTags = ref.watch(expenseTagIdsProvider).value ?? const {};
    final incomeTags = ref.watch(incomeTagIdsProvider).value ?? const {};
    final expenseDupState = ref.watch(duplicateExpensesProvider);
    final incomeDupState = ref.watch(duplicateIncomeProvider);
    final settings = ref.watch(appSettingsProvider).value;
    final primary = settings?.primaryCurrency ?? 'RUB';
    final timeZoneId = settings?.timeZoneId ?? kSystemTimeZoneId;
    final tagLabels = {
      for (final t in tags) t.id: localizedTagLabel(context, t),
    };
    final paymentLabels = {
      for (final m in paymentMethods)
        m.id: localizedPaymentMethodLabel(context, m),
    };
    final scrollController = PrimaryScrollController.maybeOf(context);
    final resolver = ref.watch(rateResolverProvider);

    if (expensesAsync.isLoading || incomesAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (expensesAsync.hasError) {
      return Center(child: Text('${expensesAsync.error}'));
    }
    if (incomesAsync.hasError) {
      return Center(child: Text('${incomesAsync.error}'));
    }

    final allExpenses = expensesAsync.value ?? const [];
    final allIncomes = incomesAsync.value ?? const [];
    final hasAnyData = allExpenses.isNotEmpty || allIncomes.isNotEmpty;

    final currencyOptions = <String>{
      for (final e in allExpenses) e.storedCurrencyCode,
      for (final i in allIncomes) i.storedCurrencyCode,
    }.toList()
      ..sort();

    final possibleDuplicateExpenseIds =
        expenseDupState.groupByExpenseId.keys.toSet();
    final possibleDuplicateIncomeIds =
        incomeDupState.groupByIncomeId.keys.toSet();

    final filtered = _filteredOperations(
      expenses: allExpenses,
      incomes: allIncomes,
      expenseTags: expenseTags,
      incomeTags: incomeTags,
      possibleDuplicateExpenseIds: possibleDuplicateExpenseIds,
      possibleDuplicateIncomeIds: possibleDuplicateIncomeIds,
      timeZoneId: timeZoneId,
    );

    final chartQuery = cashFlowChartQueryOf(_applied);
    final chartExpenses = filterExpenses(
      all: allExpenses,
      query: chartQuery,
      expenseTags: expenseTags,
      timeZoneId: timeZoneId,
    );
    final chartIncomes = filterIncomes(
      all: allIncomes,
      query: chartQuery,
      incomeTags: incomeTags,
      timeZoneId: timeZoneId,
    );

    final sourceCurrencies = {
      for (final op in filtered) op.currencyCode.toUpperCase(),
    };
    final displayCurrency = _displayRates.displayCurrency;
    final summaryCurrency = displayCurrency ?? primary;
    final snapshotKey = cashFlowSnapshotKey(filtered);
    final byCurrency = aggregateCashFlowByCurrency(filtered);
    if (displayCurrency != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _displayRates.syncDisplayRates(
          context: context,
          ref: ref,
          sources: sourceCurrencies,
          isMounted: () => mounted,
        );
      });
    }
    final visibleCount = _visibleCount.clamp(0, filtered.length);
    final pageItems = filtered.take(visibleCount).toList();
    final hasMoreList =
        _view == ExpenseListViewMode.list && visibleCount < filtered.length;
    final groupRows = _view == ExpenseListViewMode.grouping
        ? cashFlowGrouperFor(
            _applied.group == ExpenseListGroup.none
                ? ExpenseListGroup.currency
                : _applied.group,
          ).aggregate(
            filtered,
            CashFlowGroupingContext(
              paymentMethodLabels: paymentLabels,
              unspecifiedCountryLabel: l10n.tagKindUnspecifiedCountry,
              unspecifiedPaymentLabel: l10n.paymentMethodUnspecified,
              ascending: _applied.ascending,
              timeZoneId: timeZoneId,
            ),
          )
        : null;

    final selectedKeys = ref.watch(cashFlowListSelectionProvider);
    final selection = ref.read(cashFlowListSelectionProvider.notifier);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!hasMoreList || _loadMoreScheduled) return false;
        if (!isNearScrollBottom(notification)) return false;
        _loadMoreScheduled = true;
        final total = filtered.length;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _visibleCount =
                (_visibleCount + _kCashFlowListBatch).clamp(0, total);
          });
          _loadMoreScheduled = false;
        });
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => triggerPullToRefreshSync(context, ref),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    if (expenseDupState.flaggedCount > 0) ...[
                      const SizedBox(height: 8),
                      PossibleDuplicatesBanner(
                        flaggedCount: expenseDupState.flaggedCount,
                        onTap: () => showDuplicateReviewSheet(context),
                      ),
                    ],
                    if (incomeDupState.flaggedCount > 0) ...[
                      const SizedBox(height: 8),
                      PossibleDuplicatesBanner(
                        flaggedCount: incomeDupState.flaggedCount,
                        onTap: () => showIncomeDuplicateReviewSheet(context),
                      ),
                    ],
                    if (hasAnyData) ...[
                      const SizedBox(height: 12),
                      CashFlowSummaryRow(
                        key: ValueKey(
                          'cash-flow-summary-$snapshotKey-'
                          '${displayCurrency ?? ''}-'
                          '${_displayRates.displayRatesSourcesKey}',
                        ),
                        byCurrency: byCurrency,
                        totalCount: filtered.length,
                        displayCurrency: displayCurrency,
                        convertedTotalFuture: displayCurrency == null
                            ? null
                            : sumCashFlowInCurrency(
                                operations: filtered,
                                targetCurrency: summaryCurrency,
                                resolver: resolver,
                              ),
                        onConvert: () => _displayRates.pickDisplayCurrency(
                          context: context,
                          ref: ref,
                          sources: sourceCurrencies,
                          isMounted: () => mounted,
                        ),
                      ),
                      if (_displayRates.syncingDisplayRates)
                        const LinearProgressIndicator(),
                      const SizedBox(height: 12),
                      ExpensesListingCard(
                        view: _view,
                        group: _applied.group == ExpenseListGroup.none
                            ? ExpenseListGroup.currency
                            : _applied.group,
                        sort: _applied.sort,
                        ascending: _applied.ascending,
                        groupOptions: cashFlowGroupOptions,
                        showTelegram: ref.watch(
                          isIntegrationConfiguredProvider(
                            kTelegramIntegrationId,
                          ),
                        ),
                        showExpensesExport: false,
                        showIncomeExport: false,
                        showCashFlowExport: true,
                        onSortChanged: (field, ascending) {
                          setState(() {
                            _applied = _applied.copyWith(
                              sort: field,
                              ascending: ascending,
                            );
                            _visibleCount = _kCashFlowListInitial;
                          });
                        },
                        onViewChanged: (v) {
                          setState(() {
                            _view = v;
                            _visibleCount = _kCashFlowListInitial;
                            if (v == ExpenseListViewMode.grouping &&
                                _applied.group == ExpenseListGroup.none) {
                              _applied = _applied.copyWith(
                                group: ExpenseListGroup.currency,
                              );
                            }
                            if (v == ExpenseListViewMode.list) {
                              _applied = _applied.copyWith(
                                group: ExpenseListGroup.none,
                              );
                            }
                          });
                          ref
                              .read(cashFlowListSelectionProvider.notifier)
                              .clear();
                          _persistDisplayPrefs(view: v);
                        },
                        onGroupChanged: (g) {
                          setState(
                            () => _applied = _applied.copyWith(group: g),
                          );
                          _persistDisplayPrefs(group: g);
                        },
                        onExport: _export,
                        child: filtered.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Text(l10n.noMatchingOperations),
                                ),
                              )
                            : CashFlowSheetListingViews(
                                view: _view,
                                filteredExpenses: chartExpenses,
                                filteredIncomes: chartIncomes,
                                pageItems: pageItems,
                                filtered: filtered,
                                hasMoreList: hasMoreList,
                                groupRows: groupRows,
                                selectedKeys: selectedKeys,
                                onToggleSelected: selection.toggle,
                                onToggleSelectAll: () => selection.toggleAll(
                                  filtered.map(CashFlowSelectionKey.fromOperation),
                                ),
                                allSelectableSelected: filtered.isNotEmpty &&
                                    filtered.every(
                                      (op) => selectedKeys.contains(
                                        CashFlowSelectionKey.fromOperation(op),
                                      ),
                                    ),
                                paymentLabels: paymentLabels,
                                displayCurrency: displayCurrency,
                                convertedMinor: (op) => cashFlowConvertedMinor(
                                  op,
                                  displayRates: _displayRates.displayRates,
                                  displayCurrency:
                                      _displayRates.displayCurrency,
                                ),
                                summaryCurrency: summaryCurrency,
                                snapshotKey: snapshotKey,
                                resolver: resolver,
                                chartDatePeriod: _chartDatePeriod,
                                chartType: _chartType,
                                timeZoneId: timeZoneId,
                                onChartDatePeriodChanged: (period) {
                                  setState(() => _chartDatePeriod = period);
                                  _persistDisplayPrefs(
                                    chartDatePeriod: period,
                                  );
                                },
                                onChartTypeChanged: (type) {
                                  setState(() => _chartType = type);
                                  _persistDisplayPrefs(chartType: type);
                                },
                                emptyMessage: l10n.noMatchingOperations,
                              ),
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      const CashFlowEmptyPlaceholder(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
