import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/expense/model/expense_tags_provider.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/entities/tag/ui/tag_chip.dart';
import 'package:valtero/features/add_expense/model/add_expense_controller.dart';
import 'package:valtero/features/add_expense/ui/add_expense_sheet.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/ui/display_currency_flow.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/features/export_expenses/model/export_controller.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/money.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/money_text.dart';

const _pageSizeOptions = [10, 25, 50, 100];

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
  int _pageSize = 25;
  int _page = 0;
  String? _exportMessage;
  String? _displayCurrency;
  Map<String, double>? _displayRates;

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
    _applied = widget.initial;
    if (widget.initial.group != ExpenseListGroup.none) {
      _view = ExpenseListViewMode.grouping;
    }
  }

  DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _dayEnd(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  String _formatDay(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<Expense> _applyFilter(
    List<Expense> all,
    Map<int, List<int>> expenseTags,
  ) {
    return all.where((e) {
      if (_applied.currencyCode != null &&
          e.storedCurrencyCode != _applied.currencyCode) {
        return false;
      }
      if (_applied.from != null &&
          e.occurredAt.isBefore(_dayStart(_applied.from!))) {
        return false;
      }
      if (_applied.to != null && e.occurredAt.isAfter(_dayEnd(_applied.to!))) {
        return false;
      }
      if (_applied.tagIds.isNotEmpty) {
        final ids = expenseTags[e.id] ?? const <int>[];
        if (!_applied.tagIds.any(ids.contains)) return false;
      }
      return true;
    }).toList();
  }

  List<Expense> _applySort(List<Expense> list) {
    final sorted = [...list];
    int cmp(Expense a, Expense b) {
      final raw = switch (_applied.sort) {
        ExpenseListSortField.date => a.occurredAt.compareTo(b.occurredAt),
        ExpenseListSortField.amount =>
          _sortAmountMinor(a).compareTo(_sortAmountMinor(b)),
        ExpenseListSortField.currency =>
          a.storedCurrencyCode.compareTo(b.storedCurrencyCode),
      };
      return _applied.ascending ? raw : -raw;
    }

    sorted.sort(cmp);
    return sorted;
  }

  int _sortAmountMinor(Expense e) {
    final rates = _displayRates;
    final display = _displayCurrency;
    if (display == null || rates == null) return e.storedAmountMinor;
    final rate = rates[e.storedCurrencyCode.toUpperCase()];
    if (rate == null) return e.storedAmountMinor;
    return Money.convertMinor(originalMinor: e.storedAmountMinor, rate: rate);
  }

  int? _convertedMinor(Expense e) {
    final rates = _displayRates;
    final display = _displayCurrency;
    if (display == null || rates == null) return null;
    final rate = rates[e.storedCurrencyCode.toUpperCase()];
    if (rate == null) return null;
    return Money.convertMinor(originalMinor: e.storedAmountMinor, rate: rate);
  }

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
        });
    }
  }

  List<({String header, List<Expense> items})> _group(
    List<Expense> list,
    Map<int, List<int>> expenseTags,
    Map<int, String> tagLabels,
    String untaggedLabel,
  ) {
    final group = _applied.group == ExpenseListGroup.none
        ? ExpenseListGroup.currency
        : _applied.group;
    switch (group) {
      case ExpenseListGroup.none:
        return [(header: '', items: list)];
      case ExpenseListGroup.currency:
        final map = <String, List<Expense>>{};
        for (final e in list) {
          map.putIfAbsent(e.storedCurrencyCode, () => []).add(e);
        }
        final keys = map.keys.toList()..sort();
        return [for (final k in keys) (header: k, items: map[k]!)];
      case ExpenseListGroup.date:
        final map = <String, List<Expense>>{};
        for (final e in list) {
          map.putIfAbsent(_formatDay(e.occurredAt), () => []).add(e);
        }
        final keys = map.keys.toList()
          ..sort(
            (a, b) => _applied.ascending ? a.compareTo(b) : b.compareTo(a),
          );
        return [for (final k in keys) (header: k, items: map[k]!)];
      case ExpenseListGroup.tag:
        final map = <String, List<Expense>>{};
        for (final e in list) {
          final ids = expenseTags[e.id] ?? const <int>[];
          if (ids.isEmpty) {
            map.putIfAbsent(untaggedLabel, () => []).add(e);
          } else {
            for (final id in ids) {
              final label = tagLabels[id] ?? '?';
              map.putIfAbsent(label, () => []).add(e);
            }
          }
        }
        final keys = map.keys.toList()..sort();
        return [for (final k in keys) (header: k, items: map[k]!)];
    }
  }

  Future<void> _pickDraftDateRange() async {
    final now = DateTime.now();
    final initialStart = _draft.from ?? _draft.to ?? now;
    final initialEnd = _draft.to ?? _draft.from ?? now;
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: initialStart.isBefore(initialEnd) ? initialStart : initialEnd,
        end: initialStart.isBefore(initialEnd) ? initialEnd : initialStart,
      ),
    );
    if (range == null) return;
    setState(() {
      _draft = _draft.copyWith(from: range.start, to: range.end);
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
    setState(() {
      _draft = _draft.copyWith(
        tagIds: {},
        clearCurrencyCode: true,
        clearFrom: true,
        clearTo: true,
      );
      _applied = _applied.copyWith(
        tagIds: {},
        clearCurrencyCode: true,
        clearFrom: true,
        clearTo: true,
      );
      _page = 0;
    });
  }

  Future<void> _pickTags(List<Tag> tags) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = {..._draft.tagIds};
    final result = await showDialog<Set<int>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(l10n.selectTags),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final tag in tags)
                        TagChip(
                          tag: tag,
                          selected: selected.contains(tag.id),
                          onTap: () {
                            setLocal(() {
                              if (selected.contains(tag.id)) {
                                selected.remove(tag.id);
                              } else {
                                selected.add(tag.id);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => setLocal(() => selected.clear()),
                  child: Text(l10n.clearFilters),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, Set<int>.from(selected)),
                  child: Text(l10n.applyFilters),
                ),
              ],
            );
          },
        );
      },
    );
    if (result == null) return;
    setState(() => _draft = _draft.copyWith(tagIds: result));
  }

  Future<void> _export(ExportFormat format, {required bool share}) async {
    final expenses = ref.read(allExpensesProvider).value ?? const [];
    final tags = ref.read(tagsStreamProvider).value ?? const [];
    final expenseTags = ref.read(expenseTagIdsProvider).value ?? const {};
    final tagLabels = {
      for (final t in tags) t.id: localizedTagLabel(context, t),
    };
    final filtered = _applySort(_applyFilter(expenses, expenseTags));
    final tagsByExpense = {
      for (final e in filtered) e.id: expenseTags[e.id] ?? const <int>[],
    };
    final controller = ref.read(exportControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    try {
      if (share) {
        await controller.shareFor(
          format,
          expenses: filtered,
          tagNames: tagLabels,
          tagsByExpense: tagsByExpense,
        );
      } else {
        final path = await controller.saveFileFor(
          format,
          expenses: filtered,
          tagNames: tagLabels,
          tagsByExpense: tagsByExpense,
        );
        if (!mounted) return;
        setState(() => _exportMessage = path == null ? null : l10n.exportDone);
        return;
      }
      if (!mounted) return;
      setState(() => _exportMessage = l10n.exportDone);
    } catch (_) {
      if (!mounted) return;
      setState(() => _exportMessage = null);
    }
  }

  Future<({int totalMinor, int convertibleCount})> _sumInPrimary(
    List<Expense> expenses,
    String primary,
  ) async {
    final resolver = ref.read(rateResolverProvider);
    var total = 0;
    var convertible = 0;
    for (final e in expenses) {
      final rate = await resolver.getRate(e.storedCurrencyCode, primary);
      if (rate == null) {
        if (e.storedCurrencyCode == primary) {
          total += e.storedAmountMinor;
          convertible++;
        }
        continue;
      }
      total += Money.convertMinor(
        originalMinor: e.storedAmountMinor,
        rate: rate,
      );
      convertible++;
    }
    return (totalMinor: total, convertibleCount: convertible);
  }

  Future<Map<String, int>> _chartByCurrency(
    List<Expense> expenses,
    String primary,
  ) async {
    final resolver = ref.read(rateResolverProvider);
    final amounts = <String, int>{};
    for (final e in expenses) {
      final rate = await resolver.getRate(e.storedCurrencyCode, primary);
      final amount = rate == null
          ? (e.storedCurrencyCode == primary ? e.storedAmountMinor : 0)
          : Money.convertMinor(
              originalMinor: e.storedAmountMinor,
              rate: rate,
            );
      if (amount <= 0) continue;
      amounts[e.storedCurrencyCode] =
          (amounts[e.storedCurrencyCode] ?? 0) + amount;
    }
    return amounts;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final expensesAsync = ref.watch(allExpensesProvider);
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final expenseTags = ref.watch(expenseTagIdsProvider).value ?? const {};
    final settings = ref.watch(appSettingsProvider).value;
    final primary = settings?.primaryCurrency ?? 'RUB';
    final tagLabels = {
      for (final t in tags) t.id: localizedTagLabel(context, t),
    };
    final scrollController = PrimaryScrollController.maybeOf(context);

    final currencyOptions = <String>{
      for (final e in expensesAsync.value ?? const []) e.storedCurrencyCode,
    }.toList()
      ..sort();

    return expensesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (all) {
        final filtered = _applySort(_applyFilter(all, expenseTags));
        final sourceCurrencies = {
          for (final e in filtered) e.storedCurrencyCode.toUpperCase(),
        };
        final summaryCurrency = _displayCurrency ?? primary;
        final pageCount = filtered.isEmpty
            ? 1
            : ((filtered.length - 1) ~/ _pageSize) + 1;
        final safePage = _page.clamp(0, pageCount - 1);
        final pageItems = filtered
            .skip(safePage * _pageSize)
            .take(_pageSize)
            .toList();
        final sections = _view == ExpenseListViewMode.grouping
            ? _group(filtered, expenseTags, tagLabels, l10n.untagged)
            : null;

        return CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                    _FilterCard(
                      draft: _draft,
                      applied: _applied,
                      currencyOptions: currencyOptions,
                      formatDay: _formatDay,
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
                      onRemoveTag: (id) {
                        setState(() {
                          final next = {..._applied.tagIds}..remove(id);
                          _draft = _draft.copyWith(tagIds: next);
                          _applied = _applied.copyWith(tagIds: next);
                          _page = 0;
                        });
                      },
                      onClearCurrency: () {
                        setState(() {
                          _draft =
                              _draft.copyWith(clearCurrencyCode: true);
                          _applied =
                              _applied.copyWith(clearCurrencyCode: true);
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
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      count: filtered.length,
                      primaryCurrency: summaryCurrency,
                      currencyCount: sourceCurrencies.length,
                      totalFuture: _sumInPrimary(filtered, summaryCurrency),
                    ),
                    const SizedBox(height: 12),
                    _ListingCard(
                      totalCount: filtered.length,
                      pageSize: _pageSize,
                      page: safePage,
                      pageCount: pageCount,
                      view: _view,
                      group: _applied.group == ExpenseListGroup.none
                          ? ExpenseListGroup.currency
                          : _applied.group,
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
                      },
                      onGroupChanged: (g) {
                        setState(
                          () => _applied = _applied.copyWith(group: g),
                        );
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
                              ExpenseListViewMode.list => _ExpenseTable(
                                  items: pageItems,
                                  expenseTags: expenseTags,
                                  tagLabels: tagLabels,
                                  untaggedLabel: l10n.untagged,
                                  displayCurrency: _displayCurrency,
                                  convertedMinor: _convertedMinor,
                                  onDelete: _deleteExpense,
                                ),
                              ExpenseListViewMode.grouping =>
                                _GroupedExpenseTable(
                                  sections: sections!,
                                  expenseTags: expenseTags,
                                  tagLabels: tagLabels,
                                  untaggedLabel: l10n.untagged,
                                  displayCurrency: _displayCurrency,
                                  convertedMinor: _convertedMinor,
                                  onDelete: _deleteExpense,
                                ),
                              ExpenseListViewMode.chart => _ExpenseChart(
                                  future: _chartByCurrency(
                                    filtered,
                                    summaryCurrency,
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

  void _deleteExpense(int id) {
    ref.read(addExpenseControllerProvider).delete(id);
    ref.invalidate(expenseTagIdsProvider);
  }
}

class _FilterCard extends StatelessWidget {
  final ExpenseListQuery draft;
  final ExpenseListQuery applied;
  final List<String> currencyOptions;
  final String Function(DateTime) formatDay;
  final ExpenseListSortField sort;
  final bool ascending;
  final VoidCallback onPickPeriod;
  final ValueChanged<String?> onCurrencyChanged;
  final VoidCallback onPickTags;
  final void Function(ExpenseListSortField field, bool ascending)
      onSortChanged;
  final VoidCallback onApply;
  final VoidCallback onClear;
  final Map<int, String> tagLabels;
  final ValueChanged<int> onRemoveTag;
  final VoidCallback onClearCurrency;
  final VoidCallback onClearPeriod;

  const _FilterCard({
    required this.draft,
    required this.applied,
    required this.currencyOptions,
    required this.formatDay,
    required this.sort,
    required this.ascending,
    required this.onPickPeriod,
    required this.onCurrencyChanged,
    required this.onPickTags,
    required this.onSortChanged,
    required this.onApply,
    required this.onClear,
    required this.tagLabels,
    required this.onRemoveTag,
    required this.onClearCurrency,
    required this.onClearPeriod,
  });

  String get _sortKey => '${sort.name}:${ascending ? 'asc' : 'desc'}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasPeriod = applied.from != null || applied.to != null;
    final hasActive = hasPeriod ||
        applied.currencyCode != null ||
        applied.tagIds.isNotEmpty;

    String periodLabel() {
      if (draft.from == null && draft.to == null) return l10n.periodAll;
      if (draft.from != null && draft.to != null) {
        return l10n.periodFromTo(
          formatDay(draft.from!),
          formatDay(draft.to!),
        );
      }
      if (draft.from != null) {
        return '${l10n.periodFrom}: ${formatDay(draft.from!)}';
      }
      return '${l10n.periodTo}: ${formatDay(draft.to!)}';
    }

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: theme.colorScheme.outline),
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 8.0;
                const columns = 3;
                final cellWidth =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                Widget cell(Widget child) => SizedBox(
                      width: cellWidth,
                      child: child,
                    );

                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    cell(
                      _FilterOutlineButton(
                        label: l10n.periodRange,
                        value: periodLabel(),
                        icon: Icons.date_range,
                        border: border,
                        onTap: onPickPeriod,
                      ),
                    ),
                    cell(
                      DropdownButtonFormField<String?>(
                        // ignore: deprecated_member_use
                        value: draft.currencyCode,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.filterCurrency,
                          isDense: true,
                          border: border,
                          enabledBorder: border,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(l10n.all),
                          ),
                          for (final code in currencyOptions)
                            DropdownMenuItem<String?>(
                              value: code,
                              child: CurrencyCodeLabel(code),
                            ),
                        ],
                        onChanged: onCurrencyChanged,
                      ),
                    ),
                    cell(
                      _FilterOutlineButton(
                        label: l10n.selectTags,
                        value: draft.tagIds.isEmpty
                            ? l10n.all
                            : l10n.tagsSelected(draft.tagIds.length),
                        icon: Icons.label_outline,
                        border: border,
                        onTap: onPickTags,
                      ),
                    ),
                    cell(
                      DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _sortKey,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.sortBy,
                          isDense: true,
                          border: border,
                          enabledBorder: border,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        items: [
                          for (final field in ExpenseListSortField.values)
                            for (final asc in [false, true])
                              DropdownMenuItem(
                                value:
                                    '${field.name}:${asc ? 'asc' : 'desc'}',
                                child: Text(
                                  '${switch (field) {
                                    ExpenseListSortField.date =>
                                      l10n.sortDate,
                                    ExpenseListSortField.amount =>
                                      l10n.sortAmount,
                                    ExpenseListSortField.currency =>
                                      l10n.sortCurrency,
                                  }} · ${asc ? l10n.ascending : l10n.descending}',
                                ),
                              ),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          final parts = v.split(':');
                          final field = ExpenseListSortField.values
                              .firstWhere((e) => e.name == parts[0]);
                          onSortChanged(field, parts[1] == 'asc');
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton(
                  onPressed: onApply,
                  child: Text(l10n.applyFilters),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onClear,
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                  label: Text(l10n.clearFilters),
                ),
              ],
            ),
            if (hasActive) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (hasPeriod)
                    InputChip(
                      label: Text(
                        applied.from != null && applied.to != null
                            ? l10n.periodFromTo(
                                formatDay(applied.from!),
                                formatDay(applied.to!),
                              )
                            : applied.from != null
                                ? '${l10n.periodFrom}: ${formatDay(applied.from!)}'
                                : '${l10n.periodTo}: ${formatDay(applied.to!)}',
                      ),
                      onDeleted: onClearPeriod,
                    ),
                  if (applied.currencyCode != null)
                    InputChip(
                      label: Text(
                        '${l10n.filterCurrency}: ${applied.currencyCode}',
                      ),
                      onDeleted: onClearCurrency,
                    ),
                  for (final id in applied.tagIds)
                    InputChip(
                      label: Text(tagLabels[id] ?? '?'),
                      onDeleted: () => onRemoveTag(id),
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

class _FilterOutlineButton extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final InputBorder border;
  final VoidCallback onTap;

  const _FilterOutlineButton({
    required this.label,
    required this.value,
    required this.icon,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: border,
        enabledBorder: border,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final int count;
  final int currencyCount;
  final String primaryCurrency;
  final Future<({int totalMinor, int convertibleCount})> totalFuture;

  const _SummaryRow({
    required this.count,
    required this.currencyCount,
    required this.primaryCurrency,
    required this.totalFuture,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;
        final cards = [
          _SummaryCard(
            title: l10n.summaryCount,
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          _SummaryCard(
            title: l10n.summaryTotal,
            child: FutureBuilder(
              future: totalFuture,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const SizedBox(
                    height: 28,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                final data = snap.data!;
                return MoneyText(
                  amountMinor: data.totalMinor,
                  currencyCode: primaryCurrency,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                );
              },
            ),
          ),
          _SummaryCard(
            title: l10n.summaryCurrencies,
            child: Text(
              '$currencyCount',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ];
        if (wide) {
          return Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }
        return Column(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              cards[i],
            ],
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SummaryCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final int totalCount;
  final int pageSize;
  final int page;
  final int pageCount;
  final ExpenseListViewMode view;
  final ExpenseListGroup group;
  final String? displayCurrency;
  final String? exportMessage;
  final VoidCallback onDisplayIn;
  final ValueChanged<int> onPageSizeChanged;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<ExpenseListViewMode> onViewChanged;
  final ValueChanged<ExpenseListGroup> onGroupChanged;
  final Future<void> Function(ExportFormat format, {required bool share})
      onExport;
  final Widget child;

  const _ListingCard({
    required this.totalCount,
    required this.pageSize,
    required this.page,
    required this.pageCount,
    required this.view,
    required this.group,
    required this.displayCurrency,
    required this.exportMessage,
    required this.onDisplayIn,
    required this.onPageSizeChanged,
    required this.onPageChanged,
    required this.onViewChanged,
    required this.onGroupChanged,
    required this.onExport,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                  l10n.totalRecords(totalCount),
                  style: theme.textTheme.titleSmall,
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onDisplayIn,
                      icon: const Icon(Icons.currency_exchange, size: 18),
                      label: Text(
                        displayCurrency == null
                            ? l10n.displayIn
                            : '${l10n.displayIn}: $displayCurrency',
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${l10n.perPage}: '),
                        DropdownButton<int>(
                          value: pageSize,
                          underline: const SizedBox.shrink(),
                          items: [
                            for (final n in _pageSizeOptions)
                              DropdownMenuItem(value: n, child: Text('$n')),
                          ],
                          onChanged: (v) {
                            if (v != null) onPageSizeChanged(v);
                          },
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      tooltip: l10n.export,
                      onSelected: (key) {
                        switch (key) {
                          case 'csv_save':
                            onExport(ExportFormat.csv, share: false);
                          case 'csv_share':
                            onExport(ExportFormat.csv, share: true);
                          case 'json_save':
                            onExport(ExportFormat.json, share: false);
                          case 'json_share':
                            onExport(ExportFormat.json, share: true);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'csv_save',
                          child: Text(
                            '${l10n.exportCsv} · ${l10n.saveFile}',
                          ),
                        ),
                        PopupMenuItem(
                          value: 'csv_share',
                          child: Text('${l10n.exportCsv} · ${l10n.share}'),
                        ),
                        PopupMenuItem(
                          value: 'json_save',
                          child: Text(
                            '${l10n.exportJson} · ${l10n.saveFile}',
                          ),
                        ),
                        PopupMenuItem(
                          value: 'json_share',
                          child: Text('${l10n.exportJson} · ${l10n.share}'),
                        ),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.download_outlined, size: 18),
                            const SizedBox(width: 6),
                            Text(l10n.export),
                            const Icon(Icons.arrow_drop_down, size: 18),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${l10n.listingView}: '),
                        DropdownButton<ExpenseListViewMode>(
                          value: view,
                          underline: const SizedBox.shrink(),
                          items: [
                            DropdownMenuItem(
                              value: ExpenseListViewMode.list,
                              child: Text(l10n.viewList),
                            ),
                            DropdownMenuItem(
                              value: ExpenseListViewMode.grouping,
                              child: Text(l10n.viewGrouping),
                            ),
                            DropdownMenuItem(
                              value: ExpenseListViewMode.chart,
                              child: Text(l10n.viewChart),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) onViewChanged(v);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (view == ExpenseListViewMode.grouping ||
              (view == ExpenseListViewMode.list && pageCount > 1))
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (view == ExpenseListViewMode.grouping)
                    DropdownButton<ExpenseListGroup>(
                      value: group,
                      underline: const SizedBox.shrink(),
                      items: [
                        DropdownMenuItem(
                          value: ExpenseListGroup.currency,
                          child: Text(
                            '${l10n.groupBy}: ${l10n.groupCurrency}',
                          ),
                        ),
                        DropdownMenuItem(
                          value: ExpenseListGroup.date,
                          child: Text('${l10n.groupBy}: ${l10n.groupDate}'),
                        ),
                        DropdownMenuItem(
                          value: ExpenseListGroup.tag,
                          child: Text('${l10n.groupBy}: ${l10n.groupTag}'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) onGroupChanged(v);
                      },
                    ),
                  if (view == ExpenseListViewMode.list && pageCount > 1)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: page > 0
                              ? () => onPageChanged(page - 1)
                              : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text('${page + 1} / $pageCount'),
                        IconButton(
                          onPressed: page < pageCount - 1
                              ? () => onPageChanged(page + 1)
                              : null,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          if (exportMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(exportMessage!),
            ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }
}

class _ExpenseTable extends StatelessWidget {
  final List<Expense> items;
  final Map<int, List<int>> expenseTags;
  final Map<int, String> tagLabels;
  final String untaggedLabel;
  final String? displayCurrency;
  final int? Function(Expense expense) convertedMinor;
  final ValueChanged<int> onDelete;

  const _ExpenseTable({
    required this.items,
    required this.expenseTags,
    required this.tagLabels,
    required this.untaggedLabel,
    required this.displayCurrency,
    required this.convertedMinor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  l10n.columnDate,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  l10n.columnAmount,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  l10n.columnTags,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
        const Divider(height: 1),
        for (final expense in items)
          _ExpenseRow(
            expense: expense,
            tagLabel: _tagLabel(expense.id),
            displayCurrency: displayCurrency,
            convertedAmountMinor: convertedMinor(expense),
            onDelete: () => onDelete(expense.id),
          ),
      ],
    );
  }

  String _tagLabel(int expenseId) {
    final ids = expenseTags[expenseId] ?? const <int>[];
    if (ids.isEmpty) return untaggedLabel;
    return ids.map((id) => tagLabels[id] ?? '?').join(', ');
  }
}

class _GroupedExpenseTable extends StatelessWidget {
  final List<({String header, List<Expense> items})> sections;
  final Map<int, List<int>> expenseTags;
  final Map<int, String> tagLabels;
  final String untaggedLabel;
  final String? displayCurrency;
  final int? Function(Expense expense) convertedMinor;
  final ValueChanged<int> onDelete;

  const _GroupedExpenseTable({
    required this.sections,
    required this.expenseTags,
    required this.tagLabels,
    required this.untaggedLabel,
    required this.displayCurrency,
    required this.convertedMinor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final section in sections) ...[
          Container(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              '${section.header} · ${section.items.length}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          for (final expense in section.items)
            _ExpenseRow(
              expense: expense,
              tagLabel: _tagLabel(expense.id),
              displayCurrency: displayCurrency,
              convertedAmountMinor: convertedMinor(expense),
              onDelete: () => onDelete(expense.id),
            ),
        ],
      ],
    );
  }

  String _tagLabel(int expenseId) {
    final ids = expenseTags[expenseId] ?? const <int>[];
    if (ids.isEmpty) return untaggedLabel;
    return ids.map((id) => tagLabels[id] ?? '?').join(', ');
  }
}

class _ExpenseRow extends StatelessWidget {
  final Expense expense;
  final String tagLabel;
  final String? displayCurrency;
  final int? convertedAmountMinor;
  final VoidCallback onDelete;

  const _ExpenseRow({
    required this.expense,
    required this.tagLabel,
    required this.displayCurrency,
    required this.convertedAmountMinor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date =
        '${expense.occurredAt.year}-'
        '${expense.occurredAt.month.toString().padLeft(2, '0')}-'
        '${expense.occurredAt.day.toString().padLeft(2, '0')}';
    final showConverted =
        displayCurrency != null && convertedAmountMinor != null;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(date, style: theme.textTheme.bodyMedium),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MoneyText(
                        amountMinor: showConverted
                            ? convertedAmountMinor!
                            : expense.storedAmountMinor,
                        currencyCode: showConverted
                            ? displayCurrency!
                            : expense.storedCurrencyCode,
                        style: theme.textTheme.titleSmall,
                      ),
                      if (showConverted &&
                          expense.storedCurrencyCode.toUpperCase() !=
                              displayCurrency!.toUpperCase())
                        Text(
                          '${Money.formatMinor(expense.storedAmountMinor)} '
                          '${expense.storedCurrencyCode}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text(
                      tagLabel,
                      overflow: TextOverflow.ellipsis,
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _ExpenseChart extends StatelessWidget {
  final Future<Map<String, int>> future;
  final String primaryCurrency;

  const _ExpenseChart({
    required this.future,
    required this.primaryCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<Map<String, int>>(
      future: future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snap.data!;
        if (data.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(AppLocalizations.of(context)!.noMatchingExpenses),
            ),
          );
        }
        final entries = data.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final total = entries.fold<int>(0, (s, e) => s + e.value);
        final colors = [
          theme.colorScheme.primary,
          theme.colorScheme.secondary,
          theme.colorScheme.tertiary,
          theme.colorScheme.error,
          theme.colorScheme.primaryContainer,
          theme.colorScheme.secondaryContainer,
        ];

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 48,
                    sections: [
                      for (var i = 0; i < entries.length; i++)
                        PieChartSectionData(
                          color: colors[i % colors.length],
                          value: entries[i].value.toDouble(),
                          title: entries[i].key,
                          radius: 56,
                          titleStyle: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              MoneyText(
                amountMinor: total,
                currencyCode: primaryCurrency,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  for (var i = 0; i < entries.length; i++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors[i % colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${entries[i].key}: '
                          '${Money.formatMinor(entries[i].value)} '
                          '$primaryCurrency',
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
