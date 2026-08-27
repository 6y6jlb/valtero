import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/money_text.dart';

class ExpensesSummaryRow extends StatelessWidget {
  final int count;
  final String primaryCurrency;
  final Future<({int totalMinor, int convertibleCount})> totalFuture;

  const ExpensesSummaryRow({
    super.key,
    required this.count,
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
          ExpensesSummaryCard(
            title: l10n.summaryCount,
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ExpensesSummaryCard(
            title: l10n.summaryTotal,
            child: FutureBuilder(
              future: totalFuture,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const SizedBox(
                    height: 48,
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
                final theme = Theme.of(context);
                final showPartial =
                    count > 0 && data.convertibleCount < count;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MoneyText(
                      amountMinor: data.totalMinor,
                      currencyCode: primaryCurrency,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 18,
                      child: showPartial
                          ? Text(
                              l10n.summaryPartialTotal(
                                data.convertibleCount,
                                count,
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
          ),
        ];
        if (wide) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: cards[i]),
                ],
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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

class ExpensesSummaryCard extends StatelessWidget {
  final String title;
  final Widget child;

  const ExpensesSummaryCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
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
