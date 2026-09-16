import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/expense_summary_aggregator.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/feature_help_sheet.dart';
import 'package:valtero/widgets/money_text.dart';

class ExpensesSummaryRow extends StatelessWidget {
  final List<CurrencyExpenseSummary> byCurrency;
  final int totalCount;
  final String? displayCurrency;
  final Future<({int totalMinor, int convertibleCount})>? convertedTotalFuture;
  final VoidCallback onConvert;
  /// Overrides the "Expenses" title label (e.g. for the income direction).
  final String? titleLabel;
  /// Per-currency count label; defaults to expense wording.
  final String Function(int count)? perCurrencyCountLabel;
  /// Info-sheet title; defaults to expenses summary help.
  final String? helpTitle;
  /// Info-sheet body; defaults to expenses summary help.
  final String? helpBody;

  const ExpensesSummaryRow({
    super.key,
    required this.byCurrency,
    required this.totalCount,
    required this.displayCurrency,
    required this.convertedTotalFuture,
    required this.onConvert,
    this.titleLabel,
    this.perCurrencyCountLabel,
    this.helpTitle,
    this.helpBody,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final countLabel = perCurrencyCountLabel ?? l10n.summaryPerCurrencyCount;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              titleLabel ?? l10n.summaryExpenses,
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
                if (i > 0) const SizedBox(height: 6),
                _CurrencyLine(
                  summary: byCurrency[i],
                  countLabel: countLabel(byCurrency[i].count),
                ),
              ],
            if (displayCurrency != null && convertedTotalFuture != null) ...[
              const SizedBox(height: 10),
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.summaryConvertedTotal(displayCurrency!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              FutureBuilder(
                future: convertedTotalFuture,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MoneyText(
                        amountMinor: data.totalMinor,
                        currencyCode: displayCurrency!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
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
              ),
            ],
            const SizedBox(height: 8),
            Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant,
            ),
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
                  tooltip: helpTitle ?? l10n.expensesSummaryHelpTitle,
                  onPressed: () => showFeatureHelpSheet(
                    context,
                    title: helpTitle ?? l10n.expensesSummaryHelpTitle,
                    body: helpBody ?? l10n.expensesSummaryHelpBody,
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

class _CurrencyLine extends StatelessWidget {
  final CurrencyExpenseSummary summary;
  final String countLabel;

  const _CurrencyLine({
    required this.summary,
    required this.countLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(text: summary.currency.toUpperCase()),
                TextSpan(
                  text: ' · $countLabel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        MoneyText(
          amountMinor: summary.totalMinor,
          currencyCode: summary.currency,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
