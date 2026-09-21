import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/income/model/income_provider.dart';
import 'package:valtero/entities/income/model/income_tags_provider.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/entities/integrations/telegram/model/telegram_integration.dart';
import 'package:valtero/entities/payment_method/model/payment_methods_provider.dart';
import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/duplicate_income_provider.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_drill_down.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/model/expenses_list_display_prefs.dart';
import 'package:valtero/features/expenses_list/model/grouping/income_grouper_for.dart';
import 'package:valtero/features/expenses_list/model/grouping/income_grouper.dart';
import 'package:valtero/features/expenses_list/model/income_chart_aggregator.dart';
import 'package:valtero/features/expenses_list/model/income_list_export.dart';
import 'package:valtero/features/expenses_list/model/income_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/income_list_selection.dart';
import 'package:valtero/features/expenses_list/model/income_summary_aggregator.dart';
import 'package:valtero/features/expenses_list/ui/expenses_display_rates_controller.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_summary_bar.dart';
import 'package:valtero/features/expenses_list/ui/expenses_listing_card.dart';
import 'package:valtero/features/expenses_list/ui/expenses_sheet_filter_flow.dart';
import 'package:valtero/features/expenses_list/ui/expenses_summary_row.dart';
import 'package:valtero/features/expenses_list/ui/income_duplicate_review_sheet.dart';
import 'package:valtero/features/expenses_list/ui/income_empty_placeholder.dart';
import 'package:valtero/features/expenses_list/ui/income_sheet_listing_views.dart';
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

const _kIncomeListInitial = 25;
const _kIncomeListBatch = 15;

/// Full income listing: filters, summary (+ convert), list/group/chart views,
/// sort, export, duplicates, and list multi-select bulk actions.
class IncomeListBody extends ConsumerStatefulWidget {
  final ExpenseListQuery initial;

  const IncomeListBody({super.key, required this.initial});

  @override
  ConsumerState<IncomeListBody> createState() => _IncomeListBodyState();
}

class _IncomeListBodyState extends ConsumerState<IncomeListBody> {
  late ExpenseListQuery _draft;
  late ExpenseListQuery _applied;
  ExpenseListViewMode _view = ExpenseListViewMode.list;
  ExpenseChartBreakdown _chartBreakdown = ExpenseChartBreakdown.currency;
  ExpenseChartBreakdown _chartDatePeriod = ExpenseChartBreakdown.month;
  ExpenseChartType _chartType = ExpenseChartType.donut;
  int _visibleCount = _kIncomeListInitial;
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
      final view = incomeViewModeFromSettings(settings);
      final group = incomeGroupFromSettings(settings);
      setState(() {
        _view = view;
        _chartBreakdown = incomeChartBreakdownFromSettings(settings);
        _chartType = incomeChartTypeFromSettings(settings);
        _chartDatePeriod = incomeChartDatePeriodFromSettings(settings);
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
    ExpenseChartBreakdown? chartBreakdown,
    ExpenseChartType? chartType,
    ExpenseChartBreakdown? chartDatePeriod,
  }) {
    final values = incomeListDisplayPersistValues(
      view: view ?? _view,
      appliedGroup: group ?? _applied.group,
      chartBreakdown: chartBreakdown ?? _chartBreakdown,
      chartType: chartType ?? _chartType,
      chartDatePeriod: chartDatePeriod ?? _chartDatePeriod,
    );
    ref.read(appSettingsProvider.notifier).setIncomeListDisplay(
          view: values.view,
          group: values.group,
          chartBreakdown: values.chartBreakdown,
          chartType: values.chartType,
          chartDatePeriod: values.chartDatePeriod,
        );
  }

  List<Income> _filteredIncomes(
    List<Income> all,
    Map<int, List<int>> incomeTags, {
    required String timeZoneId,
  }) =>
      sortIncomes(
        list: filterIncomes(
          all: all,
          query: _applied,
          incomeTags: incomeTags,
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
      tagKinds: const [TagKind.income],
    );
    if (result == null || !mounted) return;
    setState(() {
      _draft = result;
      _applied = result.copyWith(
        group: _applied.group,
        sort: _applied.sort,
        ascending: _applied.ascending,
      );
      _visibleCount = _kIncomeListInitial;
    });
    ref.read(incomeListSelectionProvider.notifier).clear();
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
      run: () => exportFilteredIncomes(
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

  void _applyChartSegmentFilter(DonutChartSlice slice) {
    final next = expenseChartDrillDownQuery(
      base: _applied,
      breakdown: _chartBreakdown,
      sliceKey: slice.key,
    );
    if (next == null) return;
    setState(() {
      _draft = next;
      _applied = next;
      _visibleCount = _kIncomeListInitial;
      _view = ExpenseListViewMode.list;
    });
    ref.read(incomeListSelectionProvider.notifier).clear();
    _persistDisplayPrefs(view: ExpenseListViewMode.list);
    showAppToast(context, AppLocalizations.of(context)!.filtersApplied);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ref.watch(appSettingsProvider);
    _scheduleDisplayPrefsLoad();
    final incomesAsync = ref.watch(allIncomeProvider);
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final paymentMethods =
        ref.watch(paymentMethodsStreamProvider).value ?? const [];
    final incomeTags = ref.watch(incomeTagIdsProvider).value ?? const {};
    final dupState = ref.watch(duplicateIncomeProvider);
    final settings = ref.watch(appSettingsProvider).value;
    final primary = settings?.primaryCurrency ?? 'RUB';
    final timeZoneId = settings?.timeZoneId ?? kSystemTimeZoneId;
    final showSubcategories = settings == null
        ? false
        : incomeShowSubcategoriesFromSettings(settings);
    final tagLabels = {
      for (final t in tags) t.id: localizedTagLabel(context, t),
    };
    final paymentLabels = {
      for (final m in paymentMethods)
        m.id: localizedPaymentMethodLabel(context, m),
    };
    final scrollController = PrimaryScrollController.maybeOf(context);
    final resolver = ref.watch(rateResolverProvider);

    final currencyOptions = <String>{
      for (final i in incomesAsync.value ?? const []) i.storedCurrencyCode,
    }.toList()
      ..sort();

    return incomesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (all) {
        final filtered = _filteredIncomes(
          all,
          incomeTags,
          timeZoneId: timeZoneId,
        );
        final sourceCurrencies = {
          for (final i in filtered) i.storedCurrencyCode.toUpperCase(),
        };
        final displayCurrency = _displayRates.displayCurrency;
        final summaryCurrency = displayCurrency ?? primary;
        final snapshotKey = incomesSnapshotKey(filtered);
        final byCurrency = aggregateIncomesByCurrency(filtered);
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
            ? incomeGrouperFor(
                _applied.group == ExpenseListGroup.none
                    ? ExpenseListGroup.currency
                    : _applied.group,
              ).aggregate(
                filtered,
                IncomeGroupingContext(
                  incomeTags: incomeTags,
                  tagLabels: tagLabels,
                  tagById: {for (final t in tags) t.id: t},
                  paymentMethodLabels: paymentLabels,
                  unspecifiedCountryLabel: l10n.tagKindUnspecifiedCountry,
                  unspecifiedIncomeLabel: l10n.tagKindUnspecifiedIncome,
                  unspecifiedPaymentLabel: l10n.paymentMethodUnspecified,
                  ascending: _applied.ascending,
                  timeZoneId: timeZoneId,
                  includeSubcategories: showSubcategories,
                ),
              )
            : null;

        final selectedIds = ref.watch(incomeListSelectionProvider);
        final selection = ref.read(incomeListSelectionProvider.notifier);

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
                    (_visibleCount + _kIncomeListBatch).clamp(0, total);
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
                        if (dupState.flaggedCount > 0) ...[
                          const SizedBox(height: 8),
                          PossibleDuplicatesBanner(
                            flaggedCount: dupState.flaggedCount,
                            onTap: () => showIncomeDuplicateReviewSheet(context),
                          ),
                        ],
                        if (all.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ExpensesSummaryRow(
                            key: ValueKey(
                              'income-summary-$snapshotKey-'
                              '${displayCurrency ?? ''}-'
                              '${_displayRates.displayRatesSourcesKey}',
                            ),
                            titleLabel: l10n.cashFlowIncome,
                            perCurrencyCountLabel:
                                l10n.summaryPerCurrencyIncomeCount,
                            helpTitle: l10n.incomeSummaryHelpTitle,
                            helpBody: l10n.incomeSummaryHelpBody,
                            byCurrency: [
                              for (final s in byCurrency)
                                (
                                  currency: s.currency,
                                  count: s.count,
                                  totalMinor: s.totalMinor,
                                ),
                            ],
                            totalCount: filtered.length,
                            displayCurrency: displayCurrency,
                            convertedTotalFuture: displayCurrency == null
                                ? null
                                : sumIncomesInCurrency(
                                    incomes: filtered,
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
                            showTelegram: ref.watch(
                              isIntegrationConfiguredProvider(
                                kTelegramIntegrationId,
                              ),
                            ),
                            showExpensesExport: false,
                            showIncomeExport: true,
                            onSortChanged: (field, ascending) {
                              setState(() {
                                _applied = _applied.copyWith(
                                  sort: field,
                                  ascending: ascending,
                                );
                                _visibleCount = _kIncomeListInitial;
                              });
                            },
                            onViewChanged: (v) {
                              setState(() {
                                _view = v;
                                _visibleCount = _kIncomeListInitial;
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
                                  .read(incomeListSelectionProvider.notifier)
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
                                      child: Text(l10n.noMatchingIncome),
                                    ),
                                  )
                                : IncomeSheetListingViews(
                                    view: _view,
                                    filtered: filtered,
                                    pageItems: pageItems,
                                    hasMoreList: hasMoreList,
                                    groupRows: groupRows,
                                    incomeTags: incomeTags,
                                    tagLabels: tagLabels,
                                    paymentLabels: paymentLabels,
                                    tags: tags,
                                    paymentMethods: paymentMethods,
                                    possibleDuplicateIds: dupState
                                        .groupByIncomeId.keys
                                        .toSet(),
                                    selectedIds: selectedIds,
                                    onToggleSelected: selection.toggle,
                                    onToggleSelectAll: () => selection.toggleAll(
                                      filtered.map((e) => e.id),
                                    ),
                                    allSelectableSelected: filtered.isNotEmpty &&
                                        filtered.every(
                                          (e) => selectedIds.contains(e.id),
                                        ),
                                    displayCurrency: displayCurrency,
                                    convertedMinor: (income) =>
                                        incomeConvertedMinor(
                                      income,
                                      displayRates: _displayRates.displayRates,
                                      displayCurrency:
                                          _displayRates.displayCurrency,
                                    ),
                                    summaryCurrency: summaryCurrency,
                                    snapshotKey: snapshotKey,
                                    resolver: resolver,
                                    chartBreakdown: _chartBreakdown,
                                    chartType: _chartType,
                                    timeZoneId: timeZoneId,
                                    periodFrom: _applied.from,
                                    periodTo: _applied.to,
                                    includeSubcategories: showSubcategories,
                                    showSubcategories: showSubcategories,
                                    onShowSubcategoriesChanged: (v) => ref
                                        .read(appSettingsProvider.notifier)
                                        .setIncomeShowSubcategories(v),
                                    onChartBreakdownChanged: (b) {
                                      setState(() {
                                        _chartBreakdown = b;
                                        if (isDateChartBreakdown(b)) {
                                          _chartDatePeriod = b;
                                        }
                                      });
                                      _persistDisplayPrefs(
                                        chartBreakdown: b,
                                        chartDatePeriod:
                                            isDateChartBreakdown(b) ? b : null,
                                      );
                                    },
                                    onChartTypeChanged: (t) {
                                      setState(() => _chartType = t);
                                      _persistDisplayPrefs(chartType: t);
                                    },
                                    onSegmentTap: _applyChartSegmentFilter,
                                    emptyMessage: l10n.noMatchingIncome,
                                  ),
                          ),
                        ] else ...[
                          const SizedBox(height: 12),
                          const IncomeEmptyPlaceholder(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
