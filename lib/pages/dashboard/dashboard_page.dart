import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/expense/model/expense_tags_provider.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/currency_settings/ui/rates_sheet.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_drill_down.dart';
import 'package:valtero/features/expenses_list/model/expense_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/ui/donut_breakdown_chart.dart';
import 'package:valtero/features/expenses_list/ui/expense_tag_filter_dialog.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_sheet.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_summary_bar.dart';
import 'package:valtero/features/export_expenses/ui/export_flow.dart';
import 'package:valtero/features/export_expenses/ui/export_menu.dart';
import 'package:valtero/pages/expenses/expenses_page.dart';
import 'package:valtero/pages/platform_guide/platform_guide_page.dart';
import 'package:valtero/pages/settings/settings_page.dart';
import 'package:valtero/pages/tags/tags_sheet.dart';
import 'package:valtero/shared/consts/palette.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/date_period.dart';
import 'package:valtero/shared/utils/money.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/app_page_scaffold.dart';
import 'package:valtero/widgets/app_toast.dart';
import 'package:valtero/widgets/header_clock.dart';
import 'package:valtero/widgets/period_picker.dart';

enum DonutBreakdown { tags, month, currency }

final donutBreakdownProvider =
    StateProvider<DonutBreakdown>((ref) => DonutBreakdown.tags);

ExpenseChartBreakdown _toExpenseChartBreakdown(DonutBreakdown breakdown) {
  return switch (breakdown) {
    DonutBreakdown.tags => ExpenseChartBreakdown.tags,
    DonutBreakdown.month => ExpenseChartBreakdown.month,
    DonutBreakdown.currency => ExpenseChartBreakdown.currency,
  };
}

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  late ExpenseListQuery _draft = ExpenseListQuery.sessionDefaults();
  late ExpenseListQuery _applied = ExpenseListQuery.sessionDefaults();

  void _changeBreakdown(DonutBreakdown next) {
    ref.read(donutBreakdownProvider.notifier).state = next;
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
    );
  }

  Future<void> _openFilters({
    required List<String> currencyOptions,
    required Map<int, String> tagLabels,
    required List<Tag> tags,
  }) async {
    final result = await showExpensesFilterSheet(
      context: context,
      initial: _draft,
      currencyOptions: currencyOptions,
      tagLabels: tagLabels,
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
    );
    if (result == null || !mounted) return;
    setState(() {
      _draft = result;
      _applied = result;
    });
    showAppToast(context, AppLocalizations.of(context)!.filtersApplied);
  }

  void _openSliceExpenses(DonutChartSlice slice, DonutBreakdown breakdown) {
    final query = expenseChartDrillDownQuery(
      base: _applied,
      breakdown: _toExpenseChartBreakdown(breakdown),
      sliceKey: slice.key,
    );
    if (query == null) return;
    ExpensesPage.open(context, initial: query);
  }

  List<DonutChartSlice> _sampleSlices(
    AppLocalizations l10n,
    DonutBreakdown breakdown,
  ) {
    final now = DateTime.now();
    switch (breakdown) {
      case DonutBreakdown.tags:
        return [
          DonutChartSlice(
            key: 'sample_groceries',
            label: l10n.guideSampleGroceries,
            amountMinor: 420000,
            color: chartColorAt(0),
          ),
          DonutChartSlice(
            key: 'sample_transport',
            label: l10n.guideSampleTransport,
            amountMinor: 180000,
            color: chartColorAt(1),
          ),
          DonutChartSlice(
            key: 'sample_dining',
            label: l10n.guideSampleDining,
            amountMinor: 260000,
            color: chartColorAt(2),
          ),
        ];
      case DonutBreakdown.month:
        String monthKey(DateTime d) =>
            '${d.year}-${d.month.toString().padLeft(2, '0')}';
        return [
          DonutChartSlice(
            key: monthKey(DateTime(now.year, now.month - 2)),
            label: monthKey(DateTime(now.year, now.month - 2)),
            amountMinor: 310000,
            color: chartColorAt(0),
          ),
          DonutChartSlice(
            key: monthKey(DateTime(now.year, now.month - 1)),
            label: monthKey(DateTime(now.year, now.month - 1)),
            amountMinor: 450000,
            color: chartColorAt(1),
          ),
          DonutChartSlice(
            key: monthKey(now),
            label: monthKey(now),
            amountMinor: 280000,
            color: chartColorAt(2),
          ),
        ];
      case DonutBreakdown.currency:
        return [
          DonutChartSlice(
            key: 'RUB',
            label: 'RUB',
            amountMinor: 520000,
            color: chartColorAt(0),
          ),
          DonutChartSlice(
            key: 'USD',
            label: 'USD',
            amountMinor: 210000,
            color: chartColorAt(1),
          ),
          DonutChartSlice(
            key: 'EUR',
            label: 'EUR',
            amountMinor: 150000,
            color: chartColorAt(2),
          ),
        ];
    }
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
    final isSample = expenses.isEmpty;

    return AppPageScaffold(
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
      addExpenseHeroTag: 'dashboard_add_expense',
      extraFabs: [
        FloatingActionButton.extended(
          heroTag: 'dashboard_show_expenses',
          onPressed: () => ExpensesPage.open(context),
          icon: const Icon(Icons.list_alt),
          label: Text(l10n.showExpenses),
        ),
      ],
      body: isSample
          ? _buildDashboardBody(
              context: context,
              l10n: l10n,
              slices: _sampleSlices(l10n, breakdown),
              displayCurrency: displayCurrency,
              breakdown: breakdown,
              currencyOptions: currencyOptions,
              tagLabels: tagLabels,
              tags: tags,
              isSample: true,
              loading: false,
            )
          : FutureBuilder<List<DonutChartSlice>>(
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
                final slices = snapshot.data ?? const <DonutChartSlice>[];
                return _buildDashboardBody(
                  context: context,
                  l10n: l10n,
                  slices: slices,
                  displayCurrency: displayCurrency,
                  breakdown: breakdown,
                  currencyOptions: currencyOptions,
                  tagLabels: tagLabels,
                  tags: tags,
                  isSample: false,
                  loading:
                      snapshot.connectionState == ConnectionState.waiting,
                );
              },
            ),
    );
  }

  Widget _buildDashboardBody({
    required BuildContext context,
    required AppLocalizations l10n,
    required List<DonutChartSlice> slices,
    required String displayCurrency,
    required DonutBreakdown breakdown,
    required List<String> currencyOptions,
    required Map<int, String> tagLabels,
    required List<Tag> tags,
    required bool isSample,
    required bool loading,
  }) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, kFabBottomPadding),
      children: [
        if (isSample) ...[
          Material(
            color: theme.colorScheme.secondaryContainer
                .withValues(alpha: 0.55),
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => PlatformGuidePage.open(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(l10n.dashboardOpenGuide),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        DonutBreakdownChart(
          key: ValueKey('dash-${breakdown.name}-${slices.length}'),
          slices: slices,
          displayCurrency: displayCurrency,
          showTotal: false,
          emptyMessage:
              isSample ? l10n.noExpenses : l10n.noMatchingExpenses,
          onSegmentTap: isSample
              ? null
              : (slice) => _openSliceExpenses(slice, breakdown),
        ),
        const SizedBox(height: 8),
        _DonutBreakdownIcons(
          selected: breakdown,
          onChanged: _changeBreakdown,
        ),
        const SizedBox(height: 12),
        ExpensesFilterSummaryBar(
          draft: _applied,
          onTap: () => _openFilters(
            currencyOptions: currencyOptions,
            tagLabels: tagLabels,
            tags: tags,
          ),
        ),
        if (loading) const LinearProgressIndicator(),
      ],
    );
  }

  Future<List<DonutChartSlice>> _aggregate({
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
        DonutChartSlice(
          key: e.key,
          label: labels[e.key] ?? e.key,
          amountMinor: e.value,
          color: colors[e.key] ?? chartColorAt(i++),
        ),
    ];
  }
}

class _DonutBreakdownIcons extends StatelessWidget {
  final DonutBreakdown selected;
  final ValueChanged<DonutBreakdown> onChanged;

  const _DonutBreakdownIcons({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;

    Widget iconBtn({
      required DonutBreakdown value,
      required IconData icon,
      required String tooltip,
    }) {
      final isSelected = selected == value;
      return IconButton(
        tooltip: tooltip,
        onPressed: () => onChanged(value),
        icon: Icon(icon, color: isSelected ? primary : muted),
        style: IconButton.styleFrom(
          backgroundColor: isSelected
              ? primary.withValues(alpha: 0.12)
              : Colors.transparent,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        iconBtn(
          value: DonutBreakdown.tags,
          icon: Icons.label_outline,
          tooltip: l10n.chartByTags,
        ),
        iconBtn(
          value: DonutBreakdown.month,
          icon: Icons.calendar_month,
          tooltip: l10n.chartByMonth,
        ),
        iconBtn(
          value: DonutBreakdown.currency,
          icon: Icons.currency_exchange,
          tooltip: l10n.chartByCurrency,
        ),
      ],
    );
  }
}
