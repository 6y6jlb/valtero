import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/money.dart';
import 'package:valtero/widgets/money_text.dart';
import 'package:fl_chart/fl_chart.dart';

enum DashboardPeriod { day, week, month }

final displayCurrencyProvider = StateProvider<String?>((ref) => null);
final dashboardPeriodProvider =
    StateProvider<DashboardPeriod>((ref) => DashboardPeriod.month);

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider).value;
    final expenses = ref.watch(allExpensesProvider).value ?? const [];
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final period = ref.watch(dashboardPeriodProvider);
    final displayCurrency = ref.watch(displayCurrencyProvider) ??
        settings?.primaryCurrency ??
        'RUB';
    final reporting = settings?.reportingCurrencies ?? [displayCurrency];

    return FutureBuilder<Map<String, dynamic>>(
      future: _aggregate(
        ref: ref,
        expenses: expenses,
        tags: {for (final t in tags) t.id: t.name},
        displayCurrency: displayCurrency,
        period: period,
        untaggedLabel: l10n.untagged,
      ),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final total = data?['total'] as int? ?? 0;
        final byTag = (data?['byTag'] as Map<String, int>?) ?? {};
        final byPeriod = (data?['byPeriod'] as Map<String, int>?) ?? {};

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.navDashboard,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                DropdownButton<String>(
                  value: reporting.contains(displayCurrency)
                      ? displayCurrency
                      : reporting.first,
                  items: [
                    for (final code in reporting)
                      DropdownMenuItem(value: code, child: Text(code)),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(displayCurrencyProvider.notifier).state = v;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: Text(l10n.summaryTotal),
                trailing: MoneyText(
                  amountMinor: total,
                  currencyCode: displayCurrency,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<DashboardPeriod>(
              segments: [
                ButtonSegment(
                  value: DashboardPeriod.day,
                  label: Text(l10n.periodDay),
                ),
                ButtonSegment(
                  value: DashboardPeriod.week,
                  label: Text(l10n.periodWeek),
                ),
                ButtonSegment(
                  value: DashboardPeriod.month,
                  label: Text(l10n.periodMonth),
                ),
              ],
              selected: {period},
              onSelectionChanged: (s) {
                ref.read(dashboardPeriodProvider.notifier).state = s.first;
              },
            ),
            const SizedBox(height: 16),
            Text(l10n.byTag, style: Theme.of(context).textTheme.titleMedium),
            SizedBox(
              height: 220,
              child: byTag.isEmpty
                  ? Center(child: Text(l10n.noExpenses))
                  : PieChart(
                      PieChartData(
                        sections: [
                          for (final entry in byTag.entries)
                            PieChartSectionData(
                              value: entry.value.toDouble().abs() == 0
                                  ? 1
                                  : entry.value.toDouble().abs(),
                              title: entry.key,
                              radius: 60,
                              titleStyle: const TextStyle(fontSize: 10),
                            ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Text(l10n.byPeriod, style: Theme.of(context).textTheme.titleMedium),
            SizedBox(
              height: 220,
              child: byPeriod.isEmpty
                  ? Center(child: Text(l10n.noExpenses))
                  : BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final keys = byPeriod.keys.toList();
                                final i = value.toInt();
                                if (i < 0 || i >= keys.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(keys[i], style: const TextStyle(fontSize: 9)),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        barGroups: [
                          for (var i = 0; i < byPeriod.length; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: (byPeriod.values.elementAt(i) / 100)
                                      .toDouble(),
                                  width: 14,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const LinearProgressIndicator(),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _aggregate({
    required WidgetRef ref,
    required List expenses,
    required Map<int, String> tags,
    required String displayCurrency,
    required DashboardPeriod period,
    required String untaggedLabel,
  }) async {
    final resolver = ref.read(rateResolverProvider);
    var total = 0;
    final byTag = <String, int>{};
    final byPeriod = <String, int>{};

    for (final expense in expenses) {
      final rate = await resolver.getRate(
        expense.storedCurrencyCode as String,
        displayCurrency,
      );
      final amount = rate == null
          ? (expense.storedCurrencyCode == displayCurrency
              ? expense.storedAmountMinor as int
              : 0)
          : Money.convertMinor(
              originalMinor: expense.storedAmountMinor as int,
              rate: rate,
            );
      total += amount;
      final tagName = expense.tagId == null
          ? untaggedLabel
          : (tags[expense.tagId as int] ?? untaggedLabel);
      byTag[tagName] = (byTag[tagName] ?? 0) + amount;

      final occurredAt = expense.occurredAt as DateTime;
      final key = switch (period) {
        DashboardPeriod.day =>
          '${occurredAt.year}-${occurredAt.month.toString().padLeft(2, '0')}-${occurredAt.day.toString().padLeft(2, '0')}',
        DashboardPeriod.week => _weekKey(occurredAt),
        DashboardPeriod.month =>
          '${occurredAt.year}-${occurredAt.month.toString().padLeft(2, '0')}',
      };
      byPeriod[key] = (byPeriod[key] ?? 0) + amount;
    }

    final sortedPeriod = Map.fromEntries(
      byPeriod.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    return {
      'total': total,
      'byTag': byTag,
      'byPeriod': sortedPeriod,
    };
  }

  String _weekKey(DateTime dt) {
    final start = dt.subtract(Duration(days: dt.weekday - 1));
    return '${start.year}-W${start.month.toString().padLeft(2, '0')}${start.day.toString().padLeft(2, '0')}';
  }
}
