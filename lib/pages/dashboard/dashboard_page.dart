import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/expense/model/expense_tags_provider.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/add_expense/ui/add_expense_sheet.dart';
import 'package:valtero/features/currency_settings/ui/rates_sheet.dart';
import 'package:valtero/features/expenses_list/model/expense_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/ui/expense_tag_filter_dialog.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_card.dart';
import 'package:valtero/features/export_expenses/ui/export_flow.dart';
import 'package:valtero/features/export_expenses/ui/export_menu.dart';
import 'package:valtero/pages/expenses/expenses_page.dart';
import 'package:valtero/pages/settings/settings_page.dart';
import 'package:valtero/pages/tags/tags_sheet.dart';
import 'package:valtero/shared/consts/palette.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/date_period.dart';
import 'package:valtero/shared/utils/money.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/app_toast.dart';
import 'package:valtero/widgets/header_clock.dart';
import 'package:valtero/widgets/money_text.dart';
import 'package:valtero/widgets/period_picker.dart';

enum DonutBreakdown { tags, month, currency }

final donutBreakdownProvider =
    StateProvider<DonutBreakdown>((ref) => DonutBreakdown.tags);

class _Slice {
  final String key;
  final String label;
  final int amountMinor;
  final Color color;

  const _Slice({
    required this.key,
    required this.label,
    required this.amountMinor,
    required this.color,
  });
}

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  late ExpenseListQuery _draft = ExpenseListQuery.sessionDefaults();
  late ExpenseListQuery _applied = ExpenseListQuery.sessionDefaults();

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
    );
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
    });
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
    });
    showAppToast(context, AppLocalizations.of(context)!.filtersApplied);
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
    });
    showAppToast(context, AppLocalizations.of(context)!.filtersCleared);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider).value;
    final expenses = ref.watch(allExpensesProvider).value ?? const [];
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final expenseTags = ref.watch(expenseTagIdsProvider).value ?? const {};
    final breakdown = ref.watch(donutBreakdownProvider);
    final displayCurrency = settings?.primaryCurrency ?? 'RUB';
    final tagById = {for (final t in tags) t.id: t};
    final tagLabels = {
      for (final t in tags) t.id: localizedTagLabel(context, t),
    };
    final currencyOptions = <String>{
      for (final e in expenses) e.storedCurrencyCode,
    }.toList()
      ..sort();

    final filtered = filterExpenses(
      all: expenses,
      query: _applied,
      expenseTags: expenseTags,
    );

    return Scaffold(
      appBar: AppBar(
        title: const HeaderClock(),
        actions: [
          IconButton(
            tooltip: l10n.navTags,
            onPressed: () => showTagsSheet(context),
            icon: const Icon(Icons.label_outline),
          ),
          IconButton(
            tooltip: l10n.viewRates,
            onPressed: () => showRatesSheet(context),
            icon: const Icon(Icons.currency_exchange),
          ),
          PopupMenuButton<String>(
            tooltip: l10n.settingsExport,
            onSelected: (key) async {
              final selected = parseExportMenuValue(key);
              if (selected == null) return;
              await performExport(
                context,
                ref,
                format: selected.format,
                destination: selected.destination,
              );
            },
            itemBuilder: (context) => buildExportMenuItems(l10n),
            icon: const Icon(Icons.ios_share_outlined),
          ),
          IconButton(
            tooltip: l10n.settings,
            onPressed: () => _openSettings(context),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'dashboard_show_expenses',
            onPressed: () => ExpensesPage.open(context),
            icon: const Icon(Icons.list_alt),
            label: Text(l10n.showExpenses),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'dashboard_add_expense',
            tooltip: l10n.addExpense,
            onPressed: () => showAddExpenseSheet(context),
            child: const Icon(Icons.add, size: 32),
          ),
        ],
      ),
      body: FutureBuilder<List<_Slice>>(
        future: _aggregate(
          ref: ref,
          expenses: filtered,
          expenseTags: expenseTags,
          tagById: tagById,
          tagLabels: tagLabels,
          displayCurrency: displayCurrency,
          breakdown: breakdown,
          untaggedLabel: l10n.untagged,
        ),
        builder: (context, snapshot) {
          final slices = snapshot.data ?? const <_Slice>[];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              ExpensesFilterCard(
                draft: _draft,
                currencyOptions: currencyOptions,
                onPickPeriod: _pickDraftDateRange,
                onCurrencyChanged: (v) {
                  setState(() {
                    _draft = v == null
                        ? _draft.copyWith(clearCurrencyCode: true)
                        : _draft.copyWith(currencyCode: v);
                  });
                },
                onPickTags: () => _pickTags(tags),
                onApply: _applyFilters,
                onClear: _clearFilters,
                tagLabels: tagLabels,
                onClearCurrency: () {
                  setState(() {
                    _draft = _draft.copyWith(clearCurrencyCode: true);
                  });
                },
                onClearPeriod: () {
                  setState(() {
                    _draft = _draft.copyWith(
                      clearFrom: true,
                      clearTo: true,
                    );
                  });
                },
                onClearTags: () {
                  setState(() {
                    _draft = _draft.copyWith(tagIds: {});
                  });
                },
              ),
              const SizedBox(height: 12),
              Text(l10n.chartBy, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<DonutBreakdown>(
                segments: [
                  ButtonSegment(
                    value: DonutBreakdown.tags,
                    label: Text(l10n.chartByTags),
                  ),
                  ButtonSegment(
                    value: DonutBreakdown.month,
                    label: Text(l10n.chartByMonth),
                  ),
                  ButtonSegment(
                    value: DonutBreakdown.currency,
                    label: Text(l10n.chartByCurrency),
                  ),
                ],
                selected: {breakdown},
                onSelectionChanged: (s) {
                  ref.read(donutBreakdownProvider.notifier).state = s.first;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: slices.isEmpty
                    ? Center(child: Text(l10n.noExpenses))
                    : PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 48,
                          sections: [
                            for (var i = 0; i < slices.length; i++)
                              PieChartSectionData(
                                value: slices[i].amountMinor.toDouble().abs() ==
                                        0
                                    ? 1
                                    : slices[i].amountMinor.toDouble().abs(),
                                title: slices[i].label,
                                color: slices[i].color,
                                radius: 72,
                                titleStyle: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
              if (slices.isNotEmpty) ...[
                const SizedBox(height: 8),
                for (final slice in slices)
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: slice.color,
                      radius: 8,
                    ),
                    title: Text(slice.label),
                    trailing: MoneyText(
                      amountMinor: slice.amountMinor,
                      currencyCode: displayCurrency,
                    ),
                  ),
              ],
              if (snapshot.connectionState == ConnectionState.waiting)
                const LinearProgressIndicator(),
            ],
          );
        },
      ),
    );
  }

  Future<List<_Slice>> _aggregate({
    required WidgetRef ref,
    required List<Expense> expenses,
    required Map<int, List<int>> expenseTags,
    required Map<int, Tag> tagById,
    required Map<int, String> tagLabels,
    required String displayCurrency,
    required DonutBreakdown breakdown,
    required String untaggedLabel,
  }) async {
    final resolver = ref.read(rateResolverProvider);

    final amounts = <String, int>{};
    final colors = <String, Color>{};
    final labels = <String, String>{};

    for (final expense in expenses) {
      final tagIds =
          List<int>.from(expenseTags[expense.id] ?? const <int>[]);

      final rate = await resolver.getRate(
        expense.storedCurrencyCode,
        displayCurrency,
      );
      final amount = rate == null
          ? (expense.storedCurrencyCode == displayCurrency
              ? expense.storedAmountMinor
              : 0)
          : Money.convertMinor(
              originalMinor: expense.storedAmountMinor,
              rate: rate,
            );

      switch (breakdown) {
        case DonutBreakdown.tags:
          if (tagIds.isEmpty) {
            const key = '__untagged__';
            amounts[key] = (amounts[key] ?? 0) + amount;
            labels[key] = untaggedLabel;
            colors[key] ??= chartColorAt(0);
          } else {
            final share = amount ~/ tagIds.length;
            var remainder = amount - share * tagIds.length;
            for (final tagId in tagIds) {
              final key = 'tag_$tagId';
              final part = share + (remainder > 0 ? 1 : 0);
              if (remainder > 0) remainder--;
              amounts[key] = (amounts[key] ?? 0) + part;
              labels[key] = tagLabels[tagId] ?? untaggedLabel;
              final tag = tagById[tagId];
              colors[key] ??=
                  colorFromValue(tag?.colorValue) ?? chartColorAt(tagId);
            }
          }
        case DonutBreakdown.month:
          final occurredAt = expense.occurredAt;
          final key =
              '${occurredAt.year}-${occurredAt.month.toString().padLeft(2, '0')}';
          amounts[key] = (amounts[key] ?? 0) + amount;
          labels[key] = key;
          colors[key] ??= chartColorAt(amounts.length);
        case DonutBreakdown.currency:
          final key = expense.storedCurrencyCode;
          amounts[key] = (amounts[key] ?? 0) + amount;
          labels[key] = key;
          colors[key] ??= chartColorAt(key.hashCode);
      }
    }

    final entries = amounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    var i = 0;
    return [
      for (final e in entries)
        _Slice(
          key: e.key,
          label: labels[e.key] ?? e.key,
          amountMinor: e.value,
          color: colors[e.key] ?? chartColorAt(i++),
        ),
    ];
  }
}
