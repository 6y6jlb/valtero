import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/money.dart';
import 'package:valtero/widgets/money_text.dart';

class ExpenseChart extends StatelessWidget {
  final Future<Map<String, int>> future;
  final String primaryCurrency;

  const ExpenseChart({
    super.key,
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
