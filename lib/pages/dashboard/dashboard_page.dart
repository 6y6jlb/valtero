import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/expense/model/expense_tags_provider.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/payment_method/model/payment_methods_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/currency_settings/ui/rates_sheet.dart';
import 'package:valtero/features/data_sync/ui/data_sync_flow.dart';
import 'package:valtero/features/expenses_list/model/dashboard_sample_slices.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_aggregator.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_drill_down.dart';
import 'package:valtero/features/expenses_list/model/expense_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/model/expenses_list_display_prefs.dart';
import 'package:valtero/features/expenses_list/ui/dashboard_body.dart';
import 'package:valtero/features/expenses_list/ui/expense_payment_filter_dialog.dart';
import 'package:valtero/features/expenses_list/ui/expense_tag_filter_dialog.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_sheet.dart';
import 'package:valtero/features/google_drive_sync/ui/google_drive_sync_app_bar_button.dart';
import 'package:valtero/pages/expenses/expenses_page.dart';
import 'package:valtero/pages/platform_guide/platform_guide_page.dart';
import 'package:valtero/pages/settings/settings_page.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/date_period.dart';
import 'package:valtero/shared/utils/payment_method_label.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/app_page_scaffold.dart';
import 'package:valtero/widgets/app_toast.dart';
import 'package:valtero/widgets/header_clock.dart';
import 'package:valtero/widgets/period_picker.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _hasCustomFilter = false;
  ExpenseListQuery? _customQuery;
  /// Bumps [DashboardBody] key so recent pagination resets after filter apply.
  int _filterGeneration = 0;

  ExpenseListQuery _resolveQuery(String timeZoneId) {
    if (_hasCustomFilter && _customQuery != null) return _customQuery!;
    return ExpenseListQuery.sessionDefaults(timeZoneId: timeZoneId);
  }

  void _changeBreakdown(ExpenseChartBreakdown next) {
    ref.read(appSettingsProvider.notifier).setExpensesListDisplay(
          chartBreakdown: next.name,
          chartDatePeriod:
              isDateChartBreakdown(next) ? next.name : null,
        );
  }

  void _changeChartType(ExpenseChartType next) {
    ref.read(appSettingsProvider.notifier).setExpensesListDisplay(
          chartType: next.name,
        );
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
    required ExpenseListQuery current,
  }) async {
    final result = await showExpensesFilterSheet(
      context: context,
      initial: current,
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
      _hasCustomFilter = true;
      _customQuery = result;
      _filterGeneration++;
    });
    showAppToast(context, AppLocalizations.of(context)!.filtersApplied);
  }

  void _openSliceExpenses(
    DonutChartSlice slice,
    ExpenseChartBreakdown breakdown,
    ExpenseListQuery applied,
  ) {
    final query = expenseChartDrillDownQuery(
      base: applied,
      breakdown: breakdown,
      sliceKey: slice.key,
    );
    if (query == null) return;
    ExpensesPage.open(context, initial: query);
  }

  Widget _dashboardBody({
    required List<DonutChartSlice> slices,
    required int missingRateCount,
    required String displayCurrency,
    required ExpenseChartBreakdown breakdown,
    required ExpenseChartType chartType,
    required List<String> currencyOptions,
    required Map<int, String> tagLabels,
    required Map<int, String> paymentLabels,
    required List<Tag> tags,
    required List<PaymentMethod> paymentMethods,
    required List<Expense> recentExpenses,
    required Map<int, List<int>> expenseTags,
    required ExpenseListQuery applied,
    required bool isSample,
    required bool loading,
  }) {
    return DashboardBody(
      key: ValueKey(_filterGeneration),
      slices: slices,
      missingRateCount: missingRateCount,
      displayCurrency: displayCurrency,
      breakdown: breakdown,
      chartType: chartType,
      applied: applied,
      recentExpenses: recentExpenses,
      expenseTags: expenseTags,
      tagLabels: tagLabels,
      paymentLabels: paymentLabels,
      isSample: isSample,
      loading: loading,
      onBreakdownChanged: _changeBreakdown,
      onChartTypeChanged: _changeChartType,
      onOpenFilters: () => _openFilters(
        currencyOptions: currencyOptions,
        tagLabels: tagLabels,
        paymentLabels: paymentLabels,
        tags: tags,
        paymentMethods: paymentMethods,
        current: applied,
      ),
      onSegmentTap: isSample
          ? null
          : (slice) => _openSliceExpenses(slice, breakdown, applied),
      onOpenGuide: isSample ? () => PlatformGuidePage.open(context) : null,
      onRestoreFromBackup:
          isSample ? () => showDataSyncImportFlow(context) : null,
    );
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
    final breakdown = settings != null
        ? expensesChartBreakdownFromSettings(settings)
        : ExpenseChartBreakdown.currency;
    final chartType = settings != null
        ? expensesChartTypeFromSettings(settings)
        : ExpenseChartType.donut;
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

    final timeZoneId = settings?.timeZoneId ?? kSystemTimeZoneId;
    final applied = _resolveQuery(timeZoneId);

    final filtered = filterExpenses(
      all: expenses,
      query: applied,
      expenseTags: expenseTags,
      timeZoneId: timeZoneId,
    );
    final isSample = expenses.isEmpty;
    final lang = Localizations.localeOf(context).languageCode;

    return AppPageScaffold(
      appBar: AppBar(
        title: const HeaderClock(),
        actions: [
          const GoogleDriveSyncAppBarButton(),
          IconButton(
            tooltip: l10n.viewRates,
            onPressed: () => showRatesSheet(context),
            icon: const Icon(Icons.currency_exchange),
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
          ? _dashboardBody(
              slices: dashboardSampleSlices(l10n, breakdown),
              missingRateCount: 0,
              displayCurrency: displayCurrency,
              breakdown: breakdown,
              chartType: chartType,
              currencyOptions: currencyOptions,
              tagLabels: tagLabels,
              paymentLabels: paymentLabels,
              tags: tags,
              paymentMethods: paymentMethods,
              recentExpenses: const [],
              expenseTags: expenseTags,
              applied: applied,
              isSample: true,
              loading: false,
            )
          : FutureBuilder<ExpenseChartAggregation>(
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
                timeZoneId: timeZoneId,
              ),
              builder: (context, snapshot) {
                final aggregation = snapshot.data ??
                    (slices: const <DonutChartSlice>[], missingRateCount: 0);
                return _dashboardBody(
                  slices: aggregation.slices,
                  missingRateCount: aggregation.missingRateCount,
                  displayCurrency: displayCurrency,
                  breakdown: breakdown,
                  chartType: chartType,
                  currencyOptions: currencyOptions,
                  tagLabels: tagLabels,
                  paymentLabels: paymentLabels,
                  tags: tags,
                  paymentMethods: paymentMethods,
                  recentExpenses: filtered,
                  expenseTags: expenseTags,
                  applied: applied,
                  isSample: false,
                  loading:
                      snapshot.connectionState == ConnectionState.waiting,
                );
              },
            ),
    );
  }
}
