import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/expense/model/expense_tags_provider.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/income/model/income_provider.dart';
import 'package:valtero/entities/income/model/income_tags_provider.dart';
import 'package:valtero/entities/payment_method/model/payment_methods_provider.dart';
import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/add_expense/ui/add_expense_sheet.dart';
import 'package:valtero/features/add_income/ui/add_income_sheet.dart';
import 'package:valtero/features/currency_settings/ui/rates_sheet.dart';
import 'package:valtero/features/data_sync/ui/data_sync_flow.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_aggregator.dart';
import 'package:valtero/features/expenses_list/model/chart_time_series.dart';
import 'package:valtero/features/expenses_list/model/dashboard_sample_slices.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_aggregator.dart';
import 'package:valtero/features/expenses_list/model/expense_chart_drill_down.dart';
import 'package:valtero/features/expenses_list/model/expense_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/model/expenses_list_display_prefs.dart';
import 'package:valtero/features/expenses_list/model/income_chart_aggregator.dart';
import 'package:valtero/features/expenses_list/model/income_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/transaction_direction.dart';
import 'package:valtero/features/expenses_list/ui/dashboard_body.dart';
import 'package:valtero/features/expenses_list/ui/expense_payment_filter_dialog.dart';
import 'package:valtero/features/expenses_list/ui/expense_tag_filter_dialog.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_sheet.dart';
import 'package:valtero/features/google_drive_sync/ui/google_drive_sync_app_bar_button.dart';
import 'package:valtero/pages/expenses/expenses_page.dart';
import 'package:valtero/pages/platform_guide/platform_guide_page.dart';
import 'package:valtero/pages/settings/settings_app_bar_button.dart';
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
import 'package:valtero/widgets/period_picker.dart';
import 'package:valtero/widgets/show_list_fab.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

bool _usesTimeSeriesChart(ExpenseChartType type) {
  return type == ExpenseChartType.columnByDate ||
      type == ExpenseChartType.line;
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _hasCustomFilter = false;
  ExpenseListQuery? _customQuery;
  /// Bumps [DashboardBody] key so recent pagination resets after filter apply.
  int _filterGeneration = 0;
  TransactionDirection? _directionOverride;

  TransactionDirection get _direction {
    if (_directionOverride != null) return _directionOverride!;
    final raw = ref.watch(appSettingsProvider).value?.dashboardDirection;
    return TransactionDirectionPersistence.fromSettings(raw);
  }

  ExpenseListQuery _resolveQuery(String timeZoneId) {
    if (_hasCustomFilter && _customQuery != null) return _customQuery!;
    return ExpenseListQuery.sessionDefaults(timeZoneId: timeZoneId);
  }

  void _changeBreakdown(ExpenseChartBreakdown next) {
    if (_direction == TransactionDirection.cashFlow) {
      ref.read(appSettingsProvider.notifier).setCashFlowListDisplay(
            chartDatePeriod: isDateChartBreakdown(next)
                ? next.name
                : ExpenseChartBreakdown.month.name,
          );
      return;
    }
    if (_direction == TransactionDirection.income) {
      ref.read(appSettingsProvider.notifier).setIncomeListDisplay(
            chartBreakdown: next.name,
            chartDatePeriod: isDateChartBreakdown(next) ? next.name : null,
          );
      return;
    }
    ref.read(appSettingsProvider.notifier).setExpensesListDisplay(
          chartBreakdown: next.name,
          chartDatePeriod: isDateChartBreakdown(next) ? next.name : null,
        );
  }

  void _changeShowSubcategories(bool showSubcategories) {
    if (_direction == TransactionDirection.income) {
      ref
          .read(appSettingsProvider.notifier)
          .setIncomeShowSubcategories(showSubcategories);
      return;
    }
    ref
        .read(appSettingsProvider.notifier)
        .setExpensesShowSubcategories(showSubcategories);
  }

  void _changeChartType(ExpenseChartType next) {
    if (_direction == TransactionDirection.cashFlow) {
      ref.read(appSettingsProvider.notifier).setCashFlowListDisplay(
            chartType: next.name,
          );
      return;
    }
    if (_direction == TransactionDirection.income) {
      ref.read(appSettingsProvider.notifier).setIncomeListDisplay(
            chartType: next.name,
          );
      return;
    }
    ref.read(appSettingsProvider.notifier).setExpensesListDisplay(
          chartType: next.name,
        );
  }

  void _changeDirection(TransactionDirection next) {
    if (next == _direction) return;
    setState(() {
      _directionOverride = next;
      _filterGeneration++;
    });
    ref
        .read(appSettingsProvider.notifier)
        .setDashboardDirection(next.settingsValue);
    if (next == TransactionDirection.cashFlow) {
      final settings = ref.read(appSettingsProvider).value;
      final period = settings != null
          ? cashFlowChartDatePeriodFromSettings(settings)
          : ExpenseChartBreakdown.month;
      if (!isDateChartBreakdown(period)) {
        _changeBreakdown(ExpenseChartBreakdown.month);
      }
    }
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
          kinds: _direction == TransactionDirection.income
              ? const [TagKind.income]
              : const [TagKind.custom],
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
    ExpensesPage.open(
      context,
      initial: query,
      direction: _direction == TransactionDirection.cashFlow
          ? TransactionDirection.expenses
          : _direction,
    );
  }

  Widget _dashboardBody({
    required List<DonutChartSlice> slices,
    ChartTimeSeriesAggregation? timeSeries,
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
    List<Income> recentIncomes = const [],
    Map<int, List<int>> incomeTags = const {},
    List<CashFlowBucket> cashFlowBuckets = const [],
    required ExpenseListQuery applied,
    required bool isSample,
    bool hasSourceData = false,
    bool showSubcategories = false,
  }) {
    return DashboardBody(
      key: ValueKey('${_direction.name}-$_filterGeneration'),
      direction: _direction,
      onDirectionChanged: _changeDirection,
      slices: slices,
      timeSeries: timeSeries,
      missingRateCount: missingRateCount,
      displayCurrency: displayCurrency,
      breakdown: breakdown,
      chartType: chartType,
      applied: applied,
      recentExpenses: recentExpenses,
      expenseTags: expenseTags,
      recentIncomes: recentIncomes,
      incomeTags: incomeTags,
      cashFlowBuckets: cashFlowBuckets,
      tagLabels: tagLabels,
      paymentLabels: paymentLabels,
      isSample: isSample,
      hasSourceData: hasSourceData,
      onBreakdownChanged: _changeBreakdown,
      onChartTypeChanged: _changeChartType,
      showSubcategories: showSubcategories,
      onShowSubcategoriesChanged: breakdown == ExpenseChartBreakdown.tagCustom
          ? _changeShowSubcategories
          : null,
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
    final incomes = ref.watch(allIncomeProvider).value ?? const [];
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final paymentMethods =
        ref.watch(paymentMethodsStreamProvider).value ?? const [];
    final expenseTags = ref.watch(expenseTagIdsProvider).value ?? const {};
    final incomeTags = ref.watch(incomeTagIdsProvider).value ?? const {};
    final rawBreakdown = settings == null
        ? ExpenseChartBreakdown.currency
        : (_direction == TransactionDirection.cashFlow
            ? cashFlowChartDatePeriodFromSettings(settings)
            : expensesChartBreakdownFromSettings(settings));
    final breakdown =
        _direction == TransactionDirection.cashFlow &&
                !isDateChartBreakdown(rawBreakdown)
            ? ExpenseChartBreakdown.month
            : rawBreakdown;
    final chartType = settings != null
        ? (_direction == TransactionDirection.cashFlow
            ? cashFlowChartTypeFromSettings(settings)
            : _direction == TransactionDirection.income
                ? incomeChartTypeFromSettings(settings)
                : expensesChartTypeFromSettings(settings))
        : ExpenseChartType.donut;
    final showSubcategories = settings == null
        ? false
        : (_direction == TransactionDirection.income
            ? incomeShowSubcategoriesFromSettings(settings)
            : expensesShowSubcategoriesFromSettings(settings));
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
      for (final i in incomes) i.storedCurrencyCode,
    }.toList()
      ..sort();

    final timeZoneId = settings?.timeZoneId ?? kSystemTimeZoneId;
    final applied = _resolveQuery(timeZoneId);

    final filteredExpenses = filterExpenses(
      all: expenses,
      query: applied,
      expenseTags: expenseTags,
      timeZoneId: timeZoneId,
    );
    final filteredIncomes = filterIncomes(
      all: incomes,
      query: applied,
      incomeTags: incomeTags,
      timeZoneId: timeZoneId,
    );
    final isExpenseSample =
        _direction == TransactionDirection.expenses && expenses.isEmpty;
    final isCashFlowSample = _direction == TransactionDirection.cashFlow &&
        expenses.isEmpty &&
        incomes.isEmpty;
    final lang = Localizations.localeOf(context).languageCode;

    Widget body;
    if (isCashFlowSample) {
      body = _dashboardBody(
        slices: const [],
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
        cashFlowBuckets: dashboardSampleCashFlowBuckets(breakdown),
        applied: applied,
        isSample: true,
        hasSourceData: false,
      );
    } else if (isExpenseSample) {
      body = _dashboardBody(
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
        hasSourceData: false,
      );
    } else if (_direction == TransactionDirection.income) {
      if (_usesTimeSeriesChart(chartType)) {
        body = FutureBuilder<ChartTimeSeriesAggregation>(
          future: aggregateIncomesForTimeSeries(
            incomes: filteredIncomes,
            primaryCurrency: displayCurrency,
            resolver: ref.read(rateResolverProvider),
            targetBreakdown: breakdown,
            incomeTags: incomeTags,
            tagLabels: tagLabels,
            tagById: tagById,
            untaggedLabel: breakdown == ExpenseChartBreakdown.tagCustom
                ? l10n.tagKindUnspecifiedIncome
                : unspecifiedLabelForChartBreakdown(l10n, breakdown),
            otherLabel: l10n.chartOtherSeries,
            periodFrom: applied.from,
            periodTo: applied.to,
            paymentById: paymentById,
            paymentLabels: paymentLabels,
            countryLabel: (code) =>
                countryDisplayName(code, languageCode: lang),
            timeZoneId: timeZoneId,
            includeSubcategories: showSubcategories,
          ),
          builder: (context, snapshot) {
            final aggregation = snapshot.data ??
                (
                  series: const <ChartSeriesDef>[],
                  points: const <ChartTimeSeriesPoint>[],
                  missingRateCount: 0,
                );
            return _dashboardBody(
              slices: const [],
              timeSeries: aggregation,
              missingRateCount: aggregation.missingRateCount,
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
              recentIncomes: filteredIncomes,
              incomeTags: incomeTags,
              applied: applied,
              isSample: false,
              hasSourceData: incomes.isNotEmpty,
              showSubcategories: showSubcategories,
            );
          },
        );
      } else {
        body = FutureBuilder<IncomeChartAggregation>(
          future: aggregateIncomesForChart(
            incomes: filteredIncomes,
            primaryCurrency: displayCurrency,
            resolver: ref.read(rateResolverProvider),
            breakdown: breakdown,
            incomeTags: incomeTags,
            tagLabels: tagLabels,
            tagById: tagById,
            untaggedLabel: breakdown == ExpenseChartBreakdown.tagCustom
                ? l10n.tagKindUnspecifiedIncome
                : unspecifiedLabelForChartBreakdown(l10n, breakdown),
            paymentById: paymentById,
            paymentLabels: paymentLabels,
            countryLabel: (code) =>
                countryDisplayName(code, languageCode: lang),
            timeZoneId: timeZoneId,
            includeSubcategories: showSubcategories,
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
              recentExpenses: const [],
              expenseTags: expenseTags,
              recentIncomes: filteredIncomes,
              incomeTags: incomeTags,
              applied: applied,
              isSample: false,
              hasSourceData: incomes.isNotEmpty,
              showSubcategories: showSubcategories,
            );
          },
        );
      }
    } else if (_direction == TransactionDirection.cashFlow) {
      final cashFlowQuery = applied.copyWith(
        tagIds: {},
        paymentMethodIds: {},
        countryCodes: {},
      );
      final cfExpenses = filterExpenses(
        all: expenses,
        query: cashFlowQuery,
        expenseTags: expenseTags,
        timeZoneId: timeZoneId,
      );
      final cfIncomes = filterIncomes(
        all: incomes,
        query: cashFlowQuery,
        incomeTags: incomeTags,
        timeZoneId: timeZoneId,
      );
      body = FutureBuilder<CashFlowAggregation>(
        future: aggregateCashFlow(
          expenses: cfExpenses,
          incomes: cfIncomes,
          primaryCurrency: displayCurrency,
          resolver: ref.read(rateResolverProvider),
          breakdown: breakdown,
          timeZoneId: timeZoneId,
        ),
        builder: (context, snapshot) {
          final aggregation = snapshot.data ??
              (buckets: const <CashFlowBucket>[], missingRateCount: 0);
          return _dashboardBody(
            slices: const [],
            missingRateCount: aggregation.missingRateCount,
            displayCurrency: displayCurrency,
            breakdown: breakdown,
            chartType: chartType,
            currencyOptions: currencyOptions,
            tagLabels: tagLabels,
            paymentLabels: paymentLabels,
            tags: tags,
            paymentMethods: paymentMethods,
            recentExpenses: cfExpenses,
            expenseTags: expenseTags,
            recentIncomes: cfIncomes,
            incomeTags: incomeTags,
            cashFlowBuckets: aggregation.buckets,
            applied: applied,
            isSample: false,
            hasSourceData: expenses.isNotEmpty || incomes.isNotEmpty,
          );
        },
      );
    } else if (_usesTimeSeriesChart(chartType)) {
      body = FutureBuilder<ChartTimeSeriesAggregation>(
        future: aggregateExpensesForTimeSeries(
          expenses: filteredExpenses,
          primaryCurrency: displayCurrency,
          resolver: ref.read(rateResolverProvider),
          targetBreakdown: breakdown,
          expenseTags: expenseTags,
          tagLabels: tagLabels,
          tagById: tagById,
          untaggedLabel: unspecifiedLabelForChartBreakdown(l10n, breakdown),
          otherLabel: l10n.chartOtherSeries,
          periodFrom: applied.from,
          periodTo: applied.to,
          paymentById: paymentById,
          paymentLabels: paymentLabels,
          countryLabel: (code) =>
              countryDisplayName(code, languageCode: lang),
          timeZoneId: timeZoneId,
          includeSubcategories: showSubcategories,
        ),
        builder: (context, snapshot) {
          final aggregation = snapshot.data ??
              (
                series: const <ChartSeriesDef>[],
                points: const <ChartTimeSeriesPoint>[],
                missingRateCount: 0,
              );
          return _dashboardBody(
            slices: const [],
            timeSeries: aggregation,
            missingRateCount: aggregation.missingRateCount,
            displayCurrency: displayCurrency,
            breakdown: breakdown,
            chartType: chartType,
            currencyOptions: currencyOptions,
            tagLabels: tagLabels,
            paymentLabels: paymentLabels,
            tags: tags,
            paymentMethods: paymentMethods,
            recentExpenses: filteredExpenses,
            expenseTags: expenseTags,
            applied: applied,
            isSample: false,
            hasSourceData: expenses.isNotEmpty,
            showSubcategories: showSubcategories,
          );
        },
      );
    } else {
      body = FutureBuilder<ExpenseChartAggregation>(
        future: aggregateExpensesForChart(
          expenses: filteredExpenses,
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
          includeSubcategories: showSubcategories,
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
            recentExpenses: filteredExpenses,
            expenseTags: expenseTags,
            applied: applied,
            isSample: false,
            hasSourceData: expenses.isNotEmpty,
            showSubcategories: showSubcategories,
          );
        },
      );
    }

    return AppPageScaffold(
      appBar: AppBar(
        title: Text(l10n.navDashboard),
        actions: [
          const GoogleDriveSyncAppBarButton(),
          IconButton(
            tooltip: l10n.viewRates,
            onPressed: () => showRatesSheet(context),
            icon: const Icon(Icons.currency_exchange),
          ),
          const SettingsAppBarButton(),
        ],
      ),
      addOperationHeroTag: 'dashboard_add_operation',
      onAddExpense: () => showAddExpenseSheet(context),
      onAddIncome: () => showAddIncomeSheet(context),
      extraFabs: [
        ShowListFab(
          heroTag: 'dashboard_show_list',
          onShowCashFlow: () => ExpensesPage.open(
            context,
            direction: TransactionDirection.cashFlow,
          ),
          onShowExpenses: () => ExpensesPage.open(
            context,
            direction: TransactionDirection.expenses,
          ),
          onShowIncome: () => ExpensesPage.open(
            context,
            direction: TransactionDirection.income,
          ),
        ),
      ],
      body: body,
    );
  }
}
