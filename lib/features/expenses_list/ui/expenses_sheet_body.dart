import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/expense/model/expense_tags_provider.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/add_expense/ui/add_expense_sheet.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_aggregator.dart';
import 'package:valtero/features/expenses_list/model/expense_list_export.dart';
import 'package:valtero/features/expenses_list/model/expense_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/model/expenses_list_display_prefs.dart';
import 'package:valtero/features/expenses_list/model/grouping/expense_grouper_for.dart';
import 'package:valtero/features/expenses_list/model/grouping/expense_grouping_context.dart';
import 'package:valtero/features/expenses_list/ui/display_currency_flow.dart';
import 'package:valtero/features/expenses_list/ui/expense_chart.dart';
import 'package:valtero/features/expenses_list/ui/expense_delete_flow.dart';
import 'package:valtero/features/expenses_list/ui/expense_table.dart';
import 'package:valtero/features/expenses_list/ui/expense_tag_filter_dialog.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_card.dart';
import 'package:valtero/features/expenses_list/ui/expenses_listing_card.dart';
import 'package:valtero/features/expenses_list/ui/expenses_summary_row.dart';
import 'package:valtero/features/expenses_list/ui/grouped_expense_table.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/date_period.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/period_picker.dart';

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
  int _pageSize = 25;
  int _page = 0;
  String? _exportMessage;
  String? _displayCurrency;
  Map<String, double>? _displayRates;
  String? _displayRatesSourcesKey;
  bool _displayPrefsLoaded = false;

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
    setState(() {
      _view = view;
      _chartBreakdown = chart;
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
  }) {
    final nextView = view ?? _view;
    final nextGroup = group ??
        (_applied.group == ExpenseListGroup.none
            ? ExpenseListGroup.currency
            : _applied.group);
    final nextChart = chartBreakdown ?? _chartBreakdown;
    ref.read(appSettingsProvider.notifier).setExpensesListDisplay(
          view: nextView.name,
          group: nextGroup == ExpenseListGroup.none
              ? ExpenseListGroup.currency.name
              : nextGroup.name,
          chartBreakdown: nextChart.name,
        );
  }

  List<Expense> _filteredExpenses(
    List<Expense> all,
    Map<int, List<int>> expenseTags,
  ) {
    return sortExpenses(
      list: filterExpenses(
        all: all,
        query: _applied,
        expenseTags: expenseTags,
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
      _displayRatesSourcesKey = null;
      return;
    }
    final key = '${target.toUpperCase()}|${([...sources]..sort()).join(',')}';
    if (key == _displayRatesSourcesKey && _displayRates != null) return;
    _displayRatesSourcesKey = key;

    final ok = await ensureRatesForDisplay(
      context,
      ref,
      sourceCurrencies: sources,
      target: target,
    );
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _displayCurrency = null;
        _displayRates = null;
        _displayRatesSourcesKey = null;
      });
      return;
    }
    final rates = await loadDisplayRates(
      resolver: ref.read(rateResolverProvider),
      sourceCurrencies: sources,
      target: target,
    );
    if (!mounted) return;
    setState(() => _displayRates = rates);
  }

  Future<void> _pickTags(List<Tag> tags) async {
    final result = await showExpenseTagFilterDialog(
      context,
      tags: tags,
      initialSelection: _draft.tagIds,
    );
    if (result == null) return;
    setState(() => _draft = _draft.copyWith(tagIds: result));
  }

  Future<void> _export(
    ExportFormat format, {
    required ExpenseExportAction action,
  }) async {
    try {
      final message = await exportFilteredExpenses(
        ref,
        context,
        format: format,
        action: action,
        query: _applied,
        displayRates: _displayRates,
        displayCurrency: _displayCurrency,
      );
      if (!mounted) return;
      setState(() => _exportMessage = message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _exportMessage = null);
    }
  }

  Future<void> _pickDraftDateRange() async {
    final picked = await showPeriodPicker(
      context,
      initial: DatePeriod(from: _draft.from, to: _draft.to),
    );
    if (picked == null) return;
    setState(() {
      _draft = _draft.copyWith(
        from: picked.from,
        to: picked.to,
        clearFrom: picked.from == null,
        clearTo: picked.to == null,
      );
      _applied = _applied.copyWith(
        from: picked.from,
        to: picked.to,
        clearFrom: picked.from == null,
        clearTo: picked.to == null,
      );
      _page = 0;
    });
  }

  void _applyFilters() {
    setState(() {
      _applied = _applied.copyWith(
        tagIds: _draft.tagIds,
        currencyCode: _draft.currencyCode,
        clearCurrencyCode: _draft.currencyCode == null,
        from: _draft.from,
        clearFrom: _draft.from == null,
        to: _draft.to,
        clearTo: _draft.to == null,
      );
      _page = 0;
    });
  }

  void _clearFilters() {
    final defaults = ExpenseListQuery.sessionDefaults();
    setState(() {
      _draft = _draft.copyWith(
        tagIds: {},
        clearCurrencyCode: true,
        from: defaults.from,
        to: defaults.to,
        clearFrom: defaults.from == null,
        clearTo: defaults.to == null,
      );
      _applied = _applied.copyWith(
        tagIds: {},
        clearCurrencyCode: true,
        from: defaults.from,
        to: defaults.to,
        clearFrom: defaults.from == null,
        clearTo: defaults.to == null,
      );
      _page = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    ref.watch(appSettingsProvider);
    _scheduleDisplayPrefsLoad();
    final expensesAsync = ref.watch(allExpensesProvider);
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final expenseTags = ref.watch(expenseTagIdsProvider).value ?? const {};
    final settings = ref.watch(appSettingsProvider).value;
    final primary = settings?.primaryCurrency ?? 'RUB';
    final tagLabels = {
      for (final t in tags) t.id: localizedTagLabel(context, t),
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
        final filtered = _filteredExpenses(all, expenseTags);
        final sourceCurrencies = {
          for (final e in filtered) e.storedCurrencyCode.toUpperCase(),
        };
        final summaryCurrency = _displayCurrency ?? primary;
        if (_displayCurrency != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _syncDisplayRates(sourceCurrencies);
          });
        }
        final pageCount = filtered.isEmpty
            ? 1
            : ((filtered.length - 1) ~/ _pageSize) + 1;
        final safePage = _page.clamp(0, pageCount - 1);
        final pageItems = filtered
            .skip(safePage * _pageSize)
            .take(_pageSize)
            .toList();
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
                  untaggedLabel: l10n.untagged,
                  ascending: _applied.ascending,
                ),
              )
            : null;

        return CustomScrollView(
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
                    ExpensesFilterCard(
                      draft: _draft,
                      applied: _applied,
                      currencyOptions: currencyOptions,
                      sort: _applied.sort,
                      ascending: _applied.ascending,
                      onPickPeriod: _pickDraftDateRange,
                      onCurrencyChanged: (v) {
                        setState(() {
                          _draft = v == null
                              ? _draft.copyWith(clearCurrencyCode: true)
                              : _draft.copyWith(currencyCode: v);
                        });
                      },
                      onPickTags: () => _pickTags(tags),
                      onSortChanged: (field, ascending) {
                        setState(() {
                          _applied = _applied.copyWith(
                            sort: field,
                            ascending: ascending,
                          );
                        });
                      },
                      onApply: _applyFilters,
                      onClear: _clearFilters,
                      tagLabels: tagLabels,
                      onClearCurrency: () {
                        setState(() {
                          _draft = _draft.copyWith(clearCurrencyCode: true);
                          _applied = _applied.copyWith(clearCurrencyCode: true);
                          _page = 0;
                        });
                      },
                      onClearPeriod: () {
                        setState(() {
                          _draft = _draft.copyWith(
                            clearFrom: true,
                            clearTo: true,
                          );
                          _applied = _applied.copyWith(
                            clearFrom: true,
                            clearTo: true,
                          );
                          _page = 0;
                        });
                      },
                      onClearTags: () {
                        setState(() {
                          _draft = _draft.copyWith(tagIds: {});
                          _applied = _applied.copyWith(tagIds: {});
                          _page = 0;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ExpensesSummaryRow(
                      count: filtered.length,
                      primaryCurrency: summaryCurrency,
                      currencyCount: sourceCurrencies.length,
                      totalFuture: sumExpensesInCurrency(
                        expenses: filtered,
                        targetCurrency: summaryCurrency,
                        resolver: resolver,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ExpensesListingCard(
                      totalCount: filtered.length,
                      pageSize: _pageSize,
                      page: safePage,
                      pageCount: pageCount,
                      view: _view,
                      group: _applied.group == ExpenseListGroup.none
                          ? ExpenseListGroup.currency
                          : _applied.group,
                      chartBreakdown: _chartBreakdown,
                      displayCurrency: _displayCurrency,
                      exportMessage: _exportMessage,
                      onDisplayIn: () => _pickDisplayCurrency(sourceCurrencies),
                      onPageSizeChanged: (v) {
                        setState(() {
                          _pageSize = v;
                          _page = 0;
                        });
                      },
                      onPageChanged: (v) => setState(() => _page = v),
                      onViewChanged: (v) {
                        setState(() {
                          _view = v;
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
                        _persistDisplayPrefs(view: v);
                      },
                      onGroupChanged: (g) {
                        setState(
                          () => _applied = _applied.copyWith(group: g),
                        );
                        _persistDisplayPrefs(group: g);
                      },
                      onChartBreakdownChanged: (b) {
                        setState(() => _chartBreakdown = b);
                        _persistDisplayPrefs(chartBreakdown: b);
                      },
                      onExport: _export,
                      child: filtered.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Text(
                                  all.isEmpty
                                      ? l10n.noExpenses
                                      : l10n.noMatchingExpenses,
                                ),
                              ),
                            )
                          : switch (_view) {
                              ExpenseListViewMode.list => ExpenseTable(
                                  items: pageItems,
                                  expenseTags: expenseTags,
                                  tagLabels: tagLabels,
                                  untaggedLabel: l10n.untagged,
                                  displayCurrency: _displayCurrency,
                                  convertedMinor: _convertedMinor,
                                  onDelete: (id) =>
                                      confirmAndDeleteExpense(context, ref, id),
                                ),
                              ExpenseListViewMode.grouping =>
                                GroupedExpenseTable(rows: groupRows!),
                              ExpenseListViewMode.chart => ExpenseChart(
                                  future: aggregateExpensesForChart(
                                    expenses: filtered,
                                    primaryCurrency: summaryCurrency,
                                    resolver: resolver,
                                    breakdown: _chartBreakdown,
                                    expenseTags: expenseTags,
                                    tagLabels: tagLabels,
                                    untaggedLabel: l10n.untagged,
                                  ),
                                  primaryCurrency: summaryCurrency,
                                ),
                            },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
