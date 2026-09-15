import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_summary_aggregator.dart';
import 'package:valtero/features/expenses_list/ui/signed_money_text.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/currency_symbol.dart';
import 'package:valtero/widgets/feature_help_sheet.dart';
import 'package:valtero/widgets/flag_icon.dart';

/// Cash-flow summary card: income / expenses / net per stored currency plus an
/// optional converted total in the display currency. Mirrors
/// `ExpensesSummaryRow` but reports both directions and the net.
class CashFlowSummaryRow extends StatelessWidget {
  final List<CurrencyCashFlowSummary> byCurrency;
  final int totalCount;
  final String? displayCurrency;
  final Future<CashFlowConvertedTotals>? convertedTotalFuture;
  final VoidCallback onConvert;

  const CashFlowSummaryRow({
    super.key,
    required this.byCurrency,
    required this.totalCount,
    required this.displayCurrency,
    required this.convertedTotalFuture,
    required this.onConvert,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.summaryCashFlow,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (byCurrency.isEmpty)
              Text(
                '0',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              for (var i = 0; i < byCurrency.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _CurrencyBlock(summary: byCurrency[i]),
              ],
            if (displayCurrency != null && convertedTotalFuture != null) ...[
              const SizedBox(height: 10),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              const SizedBox(height: 10),
              Text(
                l10n.summaryConvertedTotal(displayCurrency!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              _ConvertedTotals(
                future: convertedTotalFuture!,
                displayCurrency: displayCurrency!,
                totalCount: totalCount,
              ),
            ],
            const SizedBox(height: 8),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: l10n.displayIn,
                  onPressed: onConvert,
                  icon: Icon(
                    Icons.currency_exchange,
                    color: displayCurrency != null
                        ? theme.colorScheme.primary
                        : null,
                  ),
                ),
                IconButton(
                  tooltip: l10n.cashFlowSummaryHelpTitle,
                  onPressed: () => showFeatureHelpSheet(
                    context,
                    title: l10n.cashFlowSummaryHelpTitle,
                    body: l10n.cashFlowSummaryHelpBody,
                  ),
                  icon: const Icon(Icons.info_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyBlock extends StatelessWidget {
  final CurrencyCashFlowSummary summary;

  const _CurrencyBlock({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            FlagIcon.currency(summary.currency, size: 18),
            const SizedBox(width: 6),
            Text(
              currencySymbolFor(summary.currency),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.summaryPerCurrencyOperationCount(summary.count),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        _AmountLine(
          label: l10n.cashFlowIncome,
          signedAmountMinor: summary.incomeMinor,
          currencyCode: summary.currency,
        ),
        _AmountLine(
          label: l10n.cashFlowExpense,
          signedAmountMinor: -summary.expenseMinor,
          currencyCode: summary.currency,
        ),
        _AmountLine(
          label: l10n.cashFlowNet,
          signedAmountMinor: summary.netMinor,
          currencyCode: summary.currency,
          emphasized: true,
        ),
      ],
    );
  }
}

class _AmountLine extends StatelessWidget {
  final String label;
  final int signedAmountMinor;
  final String currencyCode;
  final bool emphasized;

  const _AmountLine({
    required this.label,
    required this.signedAmountMinor,
    required this.currencyCode,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SignedMoneyText(
            signedAmountMinor: signedAmountMinor,
            currencyCode: currencyCode,
            style: emphasized
                ? theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  )
                : theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ConvertedTotals extends StatelessWidget {
  final Future<CashFlowConvertedTotals> future;
  final String displayCurrency;
  final int totalCount;

  const _ConvertedTotals({
    required this.future,
    required this.displayCurrency,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return FutureBuilder(
      future: future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const SizedBox(
            height: 32,
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
        final showPartial =
            totalCount > 0 && data.convertibleCount < totalCount;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AmountLine(
              label: l10n.cashFlowIncome,
              signedAmountMinor: data.incomeMinor,
              currencyCode: displayCurrency,
            ),
            _AmountLine(
              label: l10n.cashFlowExpense,
              signedAmountMinor: -data.expenseMinor,
              currencyCode: displayCurrency,
            ),
            _AmountLine(
              label: l10n.cashFlowNet,
              signedAmountMinor: data.netMinor,
              currencyCode: displayCurrency,
              emphasized: true,
            ),
            SizedBox(
              height: 18,
              child: showPartial
                  ? Text(
                      l10n.summaryPartialTotal(
                        data.convertibleCount,
                        totalCount,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    )
                  : null,
            ),
          ],
        );
      },
    );
  }
}
