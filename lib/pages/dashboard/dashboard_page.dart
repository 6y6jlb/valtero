import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/payment_method/model/payment_methods_provider.dart';
import 'package:valtero/entities/expense/model/expense_tags_provider.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/add_expense/ui/add_expense_sheet.dart';
import 'package:valtero/features/currency_settings/ui/rates_sheet.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_aggregator.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_drill_down.dart';
import 'package:valtero/features/expenses_list/model/expense_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/ui/chart_breakdown_icons.dart';
import 'package:valtero/features/expenses_list/ui/donut_breakdown_chart.dart';
import 'package:valtero/features/expenses_list/ui/expense_payment_filter_dialog.dart';
import 'package:valtero/features/expenses_list/ui/expense_tag_filter_dialog.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_sheet.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_summary_bar.dart';
import 'package:valtero/features/expenses_list/ui/recent_expense_tile.dart';
import 'package:valtero/features/export_expenses/ui/export_flow.dart';
import 'package:valtero/features/export_expenses/ui/export_menu.dart';
import 'package:valtero/pages/expenses/expenses_page.dart';
import 'package:valtero/pages/platform_guide/platform_guide_page.dart';
import 'package:valtero/pages/settings/settings_page.dart';
import 'package:valtero/pages/tags/tags_sheet.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/consts/palette.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/date_period.dart';
import 'package:valtero/shared/utils/payment_method_label.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/app_page_scaffold.dart';
import 'package:valtero/widgets/app_toast.dart';
import 'package:valtero/widgets/header_clock.dart';
import 'package:valtero/widgets/period_picker.dart';

final donutBreakdownProvider = StateProvider<ExpenseChartBreakdown>(
  (ref) => ExpenseChartBreakdown.country,
);

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  late ExpenseListQuery _draft = ExpenseListQuery.sessionDefaults();
  late ExpenseListQuery _applied = ExpenseListQuery.sessionDefaults();

  void _changeBreakdown(ExpenseChartBreakdown next) {
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
      _applied = result;
    });
    showAppToast(context, AppLocalizations.of(context)!.filtersApplied);
  }

  void _openSliceExpenses(DonutChartSlice slice, ExpenseChartBreakdown breakdown) {
    final query = expenseChartDrillDownQuery(
      base: _applied,
      breakdown: breakdown,
      sliceKey: slice.key,
    );
    if (query == null) return;
    ExpensesPage.open(context, initial: query);
  }

  List<DonutChartSlice> _sampleSlices(
    AppLocalizations l10n,
    ExpenseChartBreakdown breakdown,
  ) {
    final now = DateTime.now();
    switch (breakdown) {
      case ExpenseChartBreakdown.country:
        return [
          DonutChartSlice(
            key: 'sample_ru',
            label: l10n.guideSampleCountryRu,
            amountMinor: 520000,
            color: chartColorAt(0),
          ),
          DonutChartSlice(
            key: 'sample_ge',
            label: l10n.guideSampleCountryGe,
            amountMinor: 210000,
            color: chartColorAt(1),
          ),
          DonutChartSlice(
            key: 'sample_tr',
            label: l10n.guideSampleCountryTr,
            amountMinor: 150000,
            color: chartColorAt(2),
          ),
        ];
      case ExpenseChartBreakdown.payment:
        return [
          DonutChartSlice(
            key: 'sample_cash',
            label: l10n.tagCash,
            amountMinor: 380000,
            color: chartColorAt(0),
          ),
          DonutChartSlice(
            key: 'sample_card',
            label: l10n.tagCard,
            amountMinor: 450000,
            color: chartColorAt(1),
          ),
          DonutChartSlice(
            key: 'sample_crypto',
            label: l10n.tagCrypto,
            amountMinor: 120000,
            color: chartColorAt(2),
          ),
        ];
      case ExpenseChartBreakdown.tagCustom:
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
      case ExpenseChartBreakdown.month:
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
      case ExpenseChartBreakdown.year:
        return [
          DonutChartSlice(
            key: '${now.year - 2}',
            label: '${now.year - 2}',
            amountMinor: 720000,
            color: chartColorAt(0),
          ),
          DonutChartSlice(
            key: '${now.year - 1}',
            label: '${now.year - 1}',
            amountMinor: 890000,
            color: chartColorAt(1),
          ),
          DonutChartSlice(
            key: '${now.year}',
            label: '${now.year}',
            amountMinor: 540000,
            color: chartColorAt(2),
          ),
        ];
      case ExpenseChartBreakdown.currency:
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
    final paymentMethods =
        ref.watch(paymentMethodsStreamProvider).value ?? const [];
    final expenseTags = ref.watch(expenseTagIdsProvider).value ?? const {};
    final breakdown = ref.watch(donutBreakdownProvider);
    final displayCurrency = settings?.primaryCurrency ?? 'RUB';
    final tagById = {for (final t in tags) t.id: t};
    final tagLabels = {
      for (final t in tags) t.id: localizedTagLabel(context, t),
    };
    final paymentById = {for (final m in paymentMethods) m.id: m};
    final paymentLabels = {
      for (final m in paymentMethods)
        m.id: localizedPaymentMethodLabel(context, m),
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
    final lang = Localizations.localeOf(context).languageCode;

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
              paymentLabels: paymentLabels,
              tags: tags,
              paymentMethods: paymentMethods,
              recentExpenses: const [],
              expenseTags: expenseTags,
              isSample: true,
              loading: false,
            )
          : FutureBuilder<List<DonutChartSlice>>(
              future: aggregateExpensesForChart(
                expenses: filtered,
                primaryCurrency: displayCurrency,
                resolver: ref.read(rateResolverProvider),
                breakdown: breakdown,
                expenseTags: expenseTags,
                tagLabels: tagLabels,
                tagById: tagById,
                paymentById: paymentById,
                paymentLabels: paymentLabels,
                untaggedLabel: unspecifiedLabelForChartBreakdown(
                  l10n,
                  breakdown,
                ),
                countryLabel: (code) =>
                    countryDisplayName(code, languageCode: lang),
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
                  paymentLabels: paymentLabels,
                  tags: tags,
                  paymentMethods: paymentMethods,
                  recentExpenses: filtered,
                  expenseTags: expenseTags,
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
    required ExpenseChartBreakdown breakdown,
    required List<String> currencyOptions,
    required Map<int, String> tagLabels,
    required Map<int, String> paymentLabels,
    required List<Tag> tags,
    required List<PaymentMethod> paymentMethods,
    required List<Expense> recentExpenses,
    required Map<int, List<int>> expenseTags,
    required bool isSample,
    required bool loading,
  }) {
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final recent = [...recentExpenses]
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    final recentTop = recent.take(10).toList();

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
        ChartBreakdownIcons(
          selected: breakdown,
          onChanged: _changeBreakdown,
          showYear: false,
        ),
        if (expenseChartBreakdownUsesTagKind(breakdown) ||
            expenseChartBreakdownUsesPayment(breakdown)) ...[
          const SizedBox(height: 4),
          Text(
            expenseChartBreakdownUsesPayment(breakdown)
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
          draft: _applied,
          onTap: () => _openFilters(
            currencyOptions: currencyOptions,
            tagLabels: tagLabels,
            paymentLabels: paymentLabels,
            tags: tags,
            paymentMethods: paymentMethods,
          ),
        ),
        if (loading) const LinearProgressIndicator(),
        if (!isSample && recentTop.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            l10n.navExpenses,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          for (final e in recentTop)
            RecentExpenseTile(
              expense: e,
              paymentLabel: e.paymentMethodId == null
                  ? null
                  : paymentLabels[e.paymentMethodId!],
              countryLabel: e.countryCode == null || e.countryCode!.isEmpty
                  ? null
                  : countryDisplayName(
                      e.countryCode!,
                      languageCode: lang,
                    ),
              tagsLabel: recentExpenseTagsLabel(e.id, expenseTags, tagLabels),
              onTap: () => showAddExpenseSheet(context, expense: e),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => ExpensesPage.open(context, initial: _applied),
              child: Text(l10n.showExpenses),
            ),
          ),
        ],
      ],
    );
  }
}
