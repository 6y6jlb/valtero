import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/expense/model/expense_tags_provider.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/income/model/income_provider.dart';
import 'package:valtero/entities/income/model/income_tags_provider.dart';
import 'package:valtero/entities/payment_method/model/payment_methods_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_aggregator.dart';
import 'package:valtero/features/expenses_list/model/expense_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/features/expenses_list/model/income_list_filtering.dart';
import 'package:valtero/features/expenses_list/model/recent_operation.dart';
import 'package:valtero/features/expenses_list/ui/cash_flow_breakdown_icons.dart';
import 'package:valtero/features/expenses_list/ui/cash_flow_chart.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_summary_bar.dart';
import 'package:valtero/features/expenses_list/ui/expenses_sheet_filter_flow.dart';
import 'package:valtero/features/expenses_list/ui/recent_cash_flow_operations_list.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/payment_method_label.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/app_toast.dart';
import 'package:valtero/widgets/feature_help_sheet.dart';

/// Cash-flow listing for the Expenses/Income list page: filter bar (date +
/// currency drive the aggregation; tag/payment/country are cleared before
/// aggregating — cash flow has no per-category breakdown), the grouped
/// income-vs-expense bar chart, and the merged recent operations list.
class CashFlowListBody extends ConsumerStatefulWidget {
  final ExpenseListQuery initial;

  const CashFlowListBody({super.key, required this.initial});

  @override
  ConsumerState<CashFlowListBody> createState() => _CashFlowListBodyState();
}

class _CashFlowListBodyState extends ConsumerState<CashFlowListBody> {
  late ExpenseListQuery _applied;
  ExpenseChartBreakdown _breakdown = ExpenseChartBreakdown.month;

  @override
  void initState() {
    super.initState();
    _applied = widget.initial;
  }

  Future<void> _openFilters({
    required List<String> currencyOptions,
    required Map<int, String> tagLabels,
    required Map<int, String> paymentLabels,
    required List<Tag> tags,
    required List<PaymentMethod> paymentMethods,
  }) async {
    final result = await openExpensesFilterSheet(
      context: context,
      draft: _applied,
      currencyOptions: currencyOptions,
      tagLabels: tagLabels,
      paymentLabels: paymentLabels,
      tags: tags,
      paymentMethods: paymentMethods,
    );
    if (result == null || !mounted) return;
    setState(() => _applied = result);
    showAppToast(context, AppLocalizations.of(context)!.filtersApplied);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final expenses = ref.watch(allExpensesProvider).value ?? const [];
    final incomes = ref.watch(allIncomeProvider).value ?? const [];
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final paymentMethods =
        ref.watch(paymentMethodsStreamProvider).value ?? const [];
    final expenseTags = ref.watch(expenseTagIdsProvider).value ?? const {};
    final incomeTags = ref.watch(incomeTagIdsProvider).value ?? const {};
    final settings = ref.watch(appSettingsProvider).value;
    final timeZoneId = settings?.timeZoneId ?? kSystemTimeZoneId;
    final displayCurrency = settings?.primaryCurrency ?? 'RUB';
    final paymentLabels = {
      for (final m in paymentMethods)
        m.id: localizedPaymentMethodLabel(context, m),
    };
    final tagLabels = {
      for (final t in tags) t.id: localizedTagLabel(context, t),
    };

    final currencyOptions = <String>{
      for (final e in expenses) e.storedCurrencyCode,
      for (final i in incomes) i.storedCurrencyCode,
    }.toList()
      ..sort();

    // Cash flow only ever aggregates by date + currency; tag/payment/country
    // filters stay on the Expenses/Income tabs.
    final cashFlowQuery = _applied.copyWith(
      tagIds: {},
      paymentMethodIds: {},
      countryCodes: {},
    );
    final filteredExpenses = filterExpenses(
      all: expenses,
      query: cashFlowQuery,
      expenseTags: expenseTags,
      timeZoneId: timeZoneId,
    );
    final filteredIncomes = filterIncomes(
      all: incomes,
      query: cashFlowQuery,
      incomeTags: incomeTags,
      timeZoneId: timeZoneId,
    );
    final recent = mergeRecentOperations(
      expenses: filteredExpenses,
      incomes: filteredIncomes,
    );

    return FutureBuilder<CashFlowAggregation>(
      future: aggregateCashFlow(
        expenses: filteredExpenses,
        incomes: filteredIncomes,
        primaryCurrency: displayCurrency,
        resolver: ref.read(rateResolverProvider),
        breakdown: _breakdown,
        timeZoneId: timeZoneId,
      ),
      builder: (context, snapshot) {
        final aggregation = snapshot.data ??
            (buckets: const <CashFlowBucket>[], missingRateCount: 0);
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
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
            if (aggregation.missingRateCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: MaterialBanner(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: Icon(
                    Icons.warning_amber_outlined,
                    color: theme.colorScheme.error,
                  ),
                  content: Text(
                    l10n.chartMissingRatesAlertGeneric(
                      aggregation.missingRateCount,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => showFeatureHelpSheet(
                        context,
                        title: l10n.chartHelpTitle,
                        body: l10n.chartHelpBody,
                      ),
                      child: Text(l10n.chartHelpTitle),
                    ),
                  ],
                ),
              ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const LinearProgressIndicator(),
            const SizedBox(height: 12),
            CashFlowChart(
              buckets: aggregation.buckets,
              displayCurrency: displayCurrency,
              hideBarAmounts: aggregation.missingRateCount > 0,
              emptyMessage: l10n.noMatchingOperations,
            ),
            const SizedBox(height: 8),
            CashFlowBreakdownIcons(
              selected: _breakdown,
              onChanged: (next) => setState(() => _breakdown = next),
            ),
            if (recent.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                l10n.recentOperations,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              RecentCashFlowOperationsList(
                operations: recent,
                paymentLabels: paymentLabels,
              ),
            ],
          ],
        );
      },
    );
  }
}
