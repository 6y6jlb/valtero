import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/payment_method/model/payment_methods_provider.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/expense/model/expense_tags_provider.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/entities/integrations/telegram/model/telegram_integration.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/add_expense/ui/add_expense_sheet.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_aggregator.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_drill_down.dart';
import 'package:valtero/features/expenses_list/model/expense_list_export.dart';
import 'package:valtero/features/expenses_list/model/expense_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_selection.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/model/expenses_list_display_prefs.dart';
import 'package:valtero/features/expenses_list/model/grouping/expense_grouper_for.dart';
import 'package:valtero/features/expenses_list/model/grouping/expense_grouping_context.dart';
import 'package:valtero/features/expenses_list/model/duplicate_expenses_provider.dart';
import 'package:valtero/features/expenses_list/ui/display_currency_flow.dart';
import 'package:valtero/features/expenses_list/ui/duplicate_review_sheet.dart';
import 'package:valtero/features/expenses_list/ui/expense_chart.dart';
import 'package:valtero/features/expenses_list/ui/expense_delete_flow.dart';
import 'package:valtero/features/expenses_list/ui/expense_table.dart';
import 'package:valtero/features/expenses_list/ui/expense_payment_filter_dialog.dart';
import 'package:valtero/features/expenses_list/ui/expense_tag_filter_dialog.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_sheet.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_summary_bar.dart';
import 'package:valtero/features/expenses_list/ui/expenses_listing_card.dart';
import 'package:valtero/features/expenses_list/model/expense_summary_aggregator.dart';
import 'package:valtero/features/expenses_list/ui/expenses_empty_placeholder.dart';
import 'package:valtero/features/expenses_list/ui/expenses_summary_row.dart';
import 'package:valtero/features/expenses_list/ui/grouped_expense_table.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/features/export_expenses/model/export_destination.dart';
import 'package:valtero/features/export_expenses/ui/export_flow.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/date_period.dart';
import 'package:valtero/shared/utils/payment_method_label.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/app_toast.dart';
import 'package:valtero/widgets/infinite_scroll_ellipsis.dart';
import 'package:valtero/widgets/period_picker.dart';

const _kListInitial = 25;
const _kListBatch = 5;

class ExpensesSheetBody extends ConsumerStatefulWidget {
  final ExpenseListQuery initial;
  final bool showTitleBar;

  const ExpensesSheetBody({
    super.key,
    required this.initial,
    this.showTitleBar = true,
  });

  @override
  ConsumerState<ExpensesSheetBody> createState() => _ExpensesSheetBodyState();
}

class _ExpensesSheetBodyState extends ConsumerState<ExpensesSheetBody> {
  late ExpenseListQuery _draft;
  late ExpenseListQuery _applied;
  ExpenseListViewMode _view = ExpenseListViewMode.list;
  ExpenseChartBreakdown _chartBreakdown = ExpenseChartBreakdown.currency;
  ExpenseChartType _chartType = ExpenseChartType.donut;
  int _visibleCount = _kListInitial;
  bool _loadMoreScheduled = false;
  String? _displayCurrency;
  Map<String, double>? _displayRates;
  String? _displayRatesSourcesKey;
  bool _displayPrefsLoaded = false;
  bool _syncingDisplayRates = false;
  int _displayRatesSyncGen = 0;
  String? _displayRatesSyncInFlightKey;

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
    _applied = widget.initial;
    if (widget.initial.group != ExpenseListGroup.none) {
      _view = ExpenseListViewMode.grouping;
    }
  }

  void _applyDisplayPrefsFromSettings() {
    if (_displayPrefsLoaded) return;
    final settings = ref.read(appSettingsProvider).value;
    if (settings == null) return;
    _displayPrefsLoaded = true;
    final view = expensesViewModeFromSettings(settings);
    final group = expensesGroupFromSettings(settings);
    final chart = expensesChartBreakdownFromSettings(settings);
    final chartType = expensesChartTypeFromSettings(settings);
    setState(() {
      _view = view;
      _chartBreakdown = chart;
      _chartType = chartType;
      if (view == ExpenseListViewMode.grouping) {
        _applied = _applied.copyWith(group: group);
      } else if (view == ExpenseListViewMode.list) {
        _applied = _applied.copyWith(group: ExpenseListGroup.none);
      } else {
        _applied = _applied.copyWith(group: group);
      }
    });
  }

  void _scheduleDisplayPrefsLoad() {
    if (_displayPrefsLoaded) return;
    if (ref.read(appSettingsProvider).value == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyDisplayPrefsFromSettings();
    });
  }

  void _persistDisplayPrefs({
    ExpenseListViewMode? view,
    ExpenseListGroup? group,
    ExpenseChartBreakdown? chartBreakdown,
    ExpenseChartType? chartType,
  }) {
    final nextView = view ?? _view;
    final nextGroup = group ??
        (_applied.group == ExpenseListGroup.none
            ? ExpenseListGroup.currency
            : _applied.group);
    final nextChart = chartBreakdown ?? _chartBreakdown;
    final nextChartType = chartType ?? _chartType;
    ref.read(appSettingsProvider.notifier).setExpensesListDisplay(
          view: nextView.name,
          group: nextGroup == ExpenseListGroup.none
              ? ExpenseListGroup.currency.name
              : nextGroup.name,
          chartBreakdown: nextChart.name,
          chartType: nextChartType.name,
        );
  }

  List<Expense> _filteredExpenses(
    List<Expense> all,
    Map<int, List<int>> expenseTags, {
    required String timeZoneId,
  }) {
    return sortExpenses(
      list: filterExpenses(
        all: all,
        query: _applied,
        expenseTags: expenseTags,
        timeZoneId: timeZoneId,
      ),
      query: _applied,
      displayRates: _displayRates,
      displayCurrency: _displayCurrency,
    );
  }

  int? _convertedMinor(Expense expense) => expenseConvertedMinor(
        expense,
        displayRates: _displayRates,
        displayCurrency: _displayCurrency,
      );

  Future<void> _pickDisplayCurrency(Set<String> sources) async {
    _displayRatesSyncGen++;
    if (mounted) {
      setState(() {
        _displayRatesSyncInFlightKey = null;
        _syncingDisplayRates = false;
      });
    }
    final pick = await showDisplayCurrencyPicker(
      context,
      ref,
      sourceCurrencies: sources,
      currentDisplayCurrency: _displayCurrency,
    );
    if (!mounted) return;
    switch (pick) {
      case DisplayCurrencyCancelled():
        return;
      case DisplayCurrencyCleared():
        setState(() {
          _displayCurrency = null;
          _displayRates = null;
          _displayRatesSourcesKey = null;
          _displayRatesSyncInFlightKey = null;
          _syncingDisplayRates = false;
        });
      case DisplayCurrencyChosen(:final code):
        final ok = await ensureRatesForDisplay(
          context,
          ref,
          sourceCurrencies: sources,
          target: code,
        );
        if (!ok || !mounted) return;
        final rates = await loadDisplayRates(
          resolver: ref.read(rateResolverProvider),
          sourceCurrencies: sources,
          target: code,
        );
        if (!mounted) return;
        setState(() {
          _displayCurrency = code;
          _displayRates = rates;
          _displayRatesSourcesKey =
              '${code.toUpperCase()}|${([...sources]..sort()).join(',')}';
        });
    }
  }

  Future<void> _syncDisplayRates(Set<String> sources) async {
    final target = _displayCurrency;
    if (target == null) {
      if (mounted) {
        setState(() {
          _displayRatesSourcesKey = null;
          _syncingDisplayRates = false;
        });
      }
      return;
    }
    final key = '${target.toUpperCase()}|${([...sources]..sort()).join(',')}';
    if (key == _displayRatesSourcesKey && _displayRates != null) return;
    if (key == _displayRatesSyncInFlightKey) return;

    final syncGen = ++_displayRatesSyncGen;
    _displayRatesSyncInFlightKey = key;
    if (mounted) setState(() => _syncingDisplayRates = true);

    final ok = await ensureRatesForDisplay(
      context,
      ref,
      sourceCurrencies: sources,
      target: target,
    );
    if (!_isActiveDisplaySync(syncGen, target)) {
      if (syncGen == _displayRatesSyncGen) {
        _displayRatesSyncInFlightKey = null;
      }
      return;
    }
    if (!ok) {
      _displayRatesSyncInFlightKey = null;
      setState(() {
        _displayCurrency = null;
        _displayRates = null;
        _displayRatesSourcesKey = null;
        _syncingDisplayRates = false;
      });
      return;
    }
    final rates = await loadDisplayRates(
      resolver: ref.read(rateResolverProvider),
      sourceCurrencies: sources,
      target: target,
    );
    if (!_isActiveDisplaySync(syncGen, target)) {
      if (syncGen == _displayRatesSyncGen) {
        _displayRatesSyncInFlightKey = null;
      }
      return;
    }
    setState(() {
      _displayRates = rates;
      _displayRatesSourcesKey = key;
      _displayRatesSyncInFlightKey = null;
      _syncingDisplayRates = false;
    });
  }

  bool _isActiveDisplaySync(int syncGen, String target) {
    if (!mounted) return false;
    if (syncGen != _displayRatesSyncGen) {
      return false;
    }
    if (_displayCurrency != target) {
      _displayRatesSyncInFlightKey = null;
      setState(() => _syncingDisplayRates = false);
      return false;
    }
    return true;
  }

  Future<void> _openFilters({
    required List<String> currencyOptions,
    required Map<int, String> tagLabels,
    required Map<int, String> paymentLabels,
    required List<Tag> tags,
    required List<PaymentMethod> paymentMethods,
  }) async {
    final result = await showExpensesFilterSheet(
      context: context,
      initial: _draft,
      currencyOptions: currencyOptions,
      tagLabels: tagLabels,
      paymentLabels: paymentLabels,
      onPickPeriod: (draft) async {
        final picked = await showPeriodPicker(
          context,
          initial: DatePeriod(from: draft.from, to: draft.to),
        );
        if (picked == null) return null;
        return draft.copyWith(
          from: picked.from,
          to: picked.to,
          clearFrom: picked.from == null,
          clearTo: picked.to == null,
        );
      },
      onPickTags: (draft) async {
        final selected = await showExpenseTagFilterDialog(
          context,
          tags: tags,
          initialSelection: draft.tagIds,
        );
        if (selected == null) return null;
        return draft.copyWith(tagIds: selected);
      },
      onPickPayment: (draft) async {
        final selected = await showExpensePaymentFilterDialog(
          context,
          methods: paymentMethods,
          initialSelection: draft.paymentMethodIds,
        );
        if (selected == null) return null;
        return draft.copyWith(paymentMethodIds: selected);
      },
    );
    if (result == null || !mounted) return;
    setState(() {
      _draft = result;
      _applied = result.copyWith(
        group: _applied.group,
        sort: _applied.sort,
        ascending: _applied.ascending,
      );
      _visibleCount = _kListInitial;
    });
    ref.read(expenseListSelectionProvider.notifier).clear();
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
      run: () => exportFilteredExpenses(
        ref,
        context,
        format: format,
        destination: destination,
        query: _applied,
        displayRates: _displayRates,
        displayCurrency: _displayCurrency,
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
      _visibleCount = _kListInitial;
      _view = ExpenseListViewMode.list;
    });
    ref.read(expenseListSelectionProvider.notifier).clear();
    _persistDisplayPrefs(view: ExpenseListViewMode.list);
    showAppToast(context, AppLocalizations.of(context)!.filtersApplied);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    ref.watch(appSettingsProvider);
    _scheduleDisplayPrefsLoad();
    final expensesAsync = ref.watch(allExpensesProvider);
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final paymentMethods =
        ref.watch(paymentMethodsStreamProvider).value ?? const [];
    final expenseTags = ref.watch(expenseTagIdsProvider).value ?? const {};
    final dupState = ref.watch(duplicateExpensesProvider);
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

    final currencyOptions = <String>{
      for (final e in expensesAsync.value ?? const []) e.storedCurrencyCode,
    }.toList()
      ..sort();

    return expensesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (all) {
        final filtered = _filteredExpenses(
          all,
          expenseTags,
          timeZoneId: timeZoneId,
        );
        final sourceCurrencies = {
          for (final e in filtered) e.storedCurrencyCode.toUpperCase(),
        };
        final summaryCurrency = _displayCurrency ?? primary;
        final snapshotKey = expensesSnapshotKey(filtered);
        final byCurrency = aggregateExpensesByCurrency(filtered);
        if (_displayCurrency != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _syncDisplayRates(sourceCurrencies);
          });
        }
        final visibleCount = _visibleCount.clamp(0, filtered.length);
        final pageItems = filtered.take(visibleCount).toList();
        final hasMoreList =
            _view == ExpenseListViewMode.list && visibleCount < filtered.length;
        final groupRows = _view == ExpenseListViewMode.grouping
            ? expenseGrouperFor(
                _applied.group == ExpenseListGroup.none
                    ? ExpenseListGroup.currency
                    : _applied.group,
              ).aggregate(
                filtered,
                ExpenseGroupingContext(
                  expenseTags: expenseTags,
                  tagLabels: tagLabels,
                  tagById: {for (final t in tags) t.id: t},
                  paymentMethodLabels: paymentLabels,
                  unspecifiedCountryLabel: l10n.tagKindUnspecifiedCountry,
                  unspecifiedCustomLabel: l10n.tagKindUnspecifiedCustom,
                  unspecifiedPaymentLabel: l10n.paymentMethodUnspecified,
                  ascending: _applied.ascending,
                  timeZoneId: timeZoneId,
                ),
              )
            : null;

        final selectedIds = ref.watch(expenseListSelectionProvider);
        final selection = ref.read(expenseListSelectionProvider.notifier);

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
                    (_visibleCount + _kListBatch).clamp(0, total);
              });
              _loadMoreScheduled = false;
            });
            return false;
          },
          child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.showTitleBar) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.navExpenses,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton.filled(
                            tooltip: l10n.addExpense,
                            onPressed: () => showAddExpenseSheet(context),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
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
                      Card(
                        margin: EdgeInsets.zero,
                        color: theme.colorScheme.errorContainer
                            .withValues(alpha: 0.55),
                        child: InkWell(
                          onTap: () => showDuplicateReviewSheet(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10n.possibleDuplicatesBannerTitle(
                                      dupState.flaggedCount,
                                    ),
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.onErrorContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (all.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ExpensesSummaryRow(
                        key: ValueKey(
                          'summary-$snapshotKey-'
                          '${_displayCurrency ?? ''}-$_displayRatesSourcesKey',
                        ),
                        byCurrency: byCurrency,
                        totalCount: filtered.length,
                        displayCurrency: _displayCurrency,
                        convertedTotalFuture: _displayCurrency == null
                            ? null
                            : sumExpensesInCurrency(
                                expenses: filtered,
                                targetCurrency: summaryCurrency,
                                resolver: resolver,
                              ),
                        onConvert: () =>
                            _pickDisplayCurrency(sourceCurrencies),
                      ),
                      if (_syncingDisplayRates)
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
                        onSortChanged: (field, ascending) {
                          setState(() {
                            _applied = _applied.copyWith(
                              sort: field,
                              ascending: ascending,
                            );
                            _visibleCount = _kListInitial;
                          });
                        },
                        onViewChanged: (v) {
                          setState(() {
                            _view = v;
                            _visibleCount = _kListInitial;
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
                          ref.read(expenseListSelectionProvider.notifier).clear();
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
                                  child: Text(l10n.noMatchingExpenses),
                                ),
                              )
                            : switch (_view) {
                                ExpenseListViewMode.list => Column(
                                    children: [
                                      ExpenseTable(
                                        items: pageItems,
                                        expenseTags: expenseTags,
                                        tagLabels: tagLabels,
                                        paymentLabels: paymentLabels,
                                        untaggedLabel: l10n.untagged,
                                        displayCurrency: _displayCurrency,
                                        convertedMinor: _convertedMinor,
                                        selectedIds: selectedIds,
                                        possibleDuplicateIds:
                                            dupState.groupByExpenseId.keys
                                                .toSet(),
                                        onToggleSelected: selection.toggle,
                                        onToggleSelectAll: () =>
                                            selection.toggleAll(
                                          filtered.map((e) => e.id),
                                        ),
                                        allSelectableSelected:
                                            filtered.isNotEmpty &&
                                                filtered.every(
                                                  (e) =>
                                                      selectedIds.contains(e.id),
                                                ),
                                        onDelete: (id) {
                                          final match = filtered.where(
                                            (e) => e.id == id,
                                          );
                                          confirmAndDeleteExpense(
                                            context,
                                            ref,
                                            id,
                                            expense: match.isEmpty
                                                ? null
                                                : match.first,
                                          );
                                        },
                                        onEdit: (expense) =>
                                            showAddExpenseSheet(
                                          context,
                                          expense: expense,
                                        ),
                                      ),
                                      if (hasMoreList)
                                        const InfiniteScrollEllipsis(),
                                    ],
                                  ),
                                ExpenseListViewMode.grouping =>
                                  GroupedExpenseTable(rows: groupRows!),
                                ExpenseListViewMode.chart => ExpenseChart(
                                    key: ValueKey(
                                      'chart-$snapshotKey-'
                                      '${_chartBreakdown.name}-$summaryCurrency',
                                    ),
                                    future: aggregateExpensesForChart(
                                      expenses: filtered,
                                      primaryCurrency: summaryCurrency,
                                      resolver: resolver,
                                      breakdown: _chartBreakdown,
                                      expenseTags: expenseTags,
                                      tagLabels: tagLabels,
                                      tagById: {
                                        for (final t in tags) t.id: t,
                                      },
                                      paymentById: {
                                        for (final m in paymentMethods) m.id: m,
                                      },
                                      paymentLabels: paymentLabels,
                                      untaggedLabel:
                                          unspecifiedLabelForChartBreakdown(
                                        l10n,
                                        _chartBreakdown,
                                      ),
                                      countryLabel: (code) => countryDisplayName(
                                        code,
                                        languageCode:
                                            Localizations.localeOf(context)
                                                .languageCode,
                                      ),
                                      timeZoneId: timeZoneId,
                                    ),
                                    primaryCurrency: summaryCurrency,
                                    chartBreakdown: _chartBreakdown,
                                    chartType: _chartType,
                                    onChartBreakdownChanged: (b) {
                                      setState(() => _chartBreakdown = b);
                                      _persistDisplayPrefs(chartBreakdown: b);
                                    },
                                    onChartTypeChanged: (t) {
                                      setState(() => _chartType = t);
                                      _persistDisplayPrefs(chartType: t);
                                    },
                                    onSegmentTap: _applyChartSegmentFilter,
                                  ),
                              },
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      const ExpensesEmptyPlaceholder(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        );
      },
    );
  }
}
