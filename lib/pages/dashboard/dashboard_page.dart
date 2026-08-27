import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/add_expense/ui/add_expense_sheet.dart';
import 'package:valtero/features/currency_settings/ui/rates_sheet.dart';
import 'package:valtero/features/export_expenses/ui/export_flow.dart';
import 'package:valtero/features/export_expenses/ui/export_menu.dart';
import 'package:valtero/pages/expenses/expenses_page.dart';
import 'package:valtero/pages/settings/settings_page.dart';
import 'package:valtero/pages/tags/tags_sheet.dart';
import 'package:valtero/shared/consts/palette.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/money.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/header_clock.dart';
import 'package:valtero/widgets/money_text.dart';
import 'package:valtero/widgets/period_picker.dart';
import 'package:valtero/shared/utils/date_period.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';

enum DonutBreakdown { tags, month, currency }

final donutBreakdownProvider =
    StateProvider<DonutBreakdown>((ref) => DonutBreakdown.tags);
final dashboardExcludedTagIdsProvider =
    StateProvider<Set<int>>((ref) => <int>{});
final dashboardFromProvider = StateProvider<DateTime?>((ref) => null);
final dashboardToProvider = StateProvider<DateTime?>((ref) => null);

class _Slice {
  final String key;
  final String label;
  final int amountMinor;
  final Color color;

  const _Slice({
    required this.key,
    required this.label,
    required this.amountMinor,
    required this.color,
  });
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
    );
  }

  DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _dayEnd(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider).value;
    final expenses = ref.watch(allExpensesProvider).value ?? const [];
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final breakdown = ref.watch(donutBreakdownProvider);
    final excluded = ref.watch(dashboardExcludedTagIdsProvider);
    final from = ref.watch(dashboardFromProvider);
    final to = ref.watch(dashboardToProvider);
    final displayCurrency = settings?.primaryCurrency ?? 'RUB';
    final tagById = {for (final t in tags) t.id: t};
    final tagLabels = {
      for (final t in tags) t.id: localizedTagLabel(context, t),
    };

    return Scaffold(
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
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'dashboard_show_expenses',
            onPressed: () => ExpensesPage.open(context),
            icon: const Icon(Icons.list_alt),
            label: Text(l10n.showExpenses),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'dashboard_add_expense',
            tooltip: l10n.addExpense,
            onPressed: () => showAddExpenseSheet(context),
            child: const Icon(Icons.add, size: 32),
          ),
        ],
      ),
      body: FutureBuilder<({int total, List<_Slice> slices})>(
        future: _aggregate(
          ref: ref,
          expenses: expenses,
          tagById: tagById,
          tagLabels: tagLabels,
          displayCurrency: displayCurrency,
          breakdown: breakdown,
          excludedTagIds: excluded,
          from: from,
          to: to,
          untaggedLabel: l10n.untagged,
        ),
        builder: (context, snapshot) {
          final total = snapshot.data?.total ?? 0;
          final slices = snapshot.data?.slices ?? const <_Slice>[];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
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
              const SizedBox(height: 12),
              Text(l10n.chartBy, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<DonutBreakdown>(
                segments: [
                  ButtonSegment(
                    value: DonutBreakdown.tags,
                    label: Text(l10n.chartByTags),
                  ),
                  ButtonSegment(
                    value: DonutBreakdown.month,
                    label: Text(l10n.chartByMonth),
                  ),
                  ButtonSegment(
                    value: DonutBreakdown.currency,
                    label: Text(l10n.chartByCurrency),
                  ),
                ],
                selected: {breakdown},
                onSelectionChanged: (s) {
                  ref.read(donutBreakdownProvider.notifier).state = s.first;
                },
              ),
              const SizedBox(height: 12),
              Text(l10n.periodRange,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: ActionChip(
                  avatar: const Icon(Icons.date_range, size: 18),
                  label: Text(
                    formatPeriodLabel(
                      l10n,
                      DatePeriod(from: from, to: to),
                    ),
                  ),
                  onPressed: () async {
                    final picked = await showPeriodPicker(
                      context,
                      initial: DatePeriod(from: from, to: to),
                    );
                    if (picked == null) return;
                    ref.read(dashboardFromProvider.notifier).state = picked.from;
                    ref.read(dashboardToProvider.notifier).state = picked.to;
                  },
                ),
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(l10n.filterTags,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  l10n.excludeTag,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in tags)
                      FilterChip(
                        avatar: tag.colorValue == null
                            ? null
                            : CircleAvatar(
                                backgroundColor: Color(tag.colorValue!),
                                radius: 8,
                              ),
                        label: Text(tagLabels[tag.id] ?? tag.name),
                        selected: excluded.contains(tag.id),
                        onSelected: (selected) {
                          final next = {...excluded};
                          if (selected) {
                            next.add(tag.id);
                          } else {
                            next.remove(tag.id);
                          }
                          ref
                              .read(dashboardExcludedTagIdsProvider.notifier)
                              .state = next;
                        },
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: slices.isEmpty
                    ? Center(child: Text(l10n.noExpenses))
                    : PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 48,
                          sections: [
                            for (var i = 0; i < slices.length; i++)
                              PieChartSectionData(
                                value: slices[i].amountMinor.toDouble().abs() ==
                                        0
                                    ? 1
                                    : slices[i].amountMinor.toDouble().abs(),
                                title: slices[i].label,
                                color: slices[i].color,
                                radius: 72,
                                titleStyle: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
              if (slices.isNotEmpty) ...[
                const SizedBox(height: 8),
                for (final slice in slices)
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: slice.color,
                      radius: 8,
                    ),
                    title: Text(slice.label),
                    trailing: MoneyText(
                      amountMinor: slice.amountMinor,
                      currencyCode: displayCurrency,
                    ),
                  ),
              ],
              if (snapshot.connectionState == ConnectionState.waiting)
                const LinearProgressIndicator(),
            ],
          );
        },
      ),
    );
  }

  Future<({int total, List<_Slice> slices})> _aggregate({
    required WidgetRef ref,
    required List expenses,
    required Map<int, Tag> tagById,
    required Map<int, String> tagLabels,
    required String displayCurrency,
    required DonutBreakdown breakdown,
    required Set<int> excludedTagIds,
    required DateTime? from,
    required DateTime? to,
    required String untaggedLabel,
  }) async {
    final resolver = ref.read(rateResolverProvider);
    final db = ref.read(appDatabaseProvider);
    final filtered = <dynamic>[];
    for (final expense in expenses) {
      final occurredAt = expense.occurredAt as DateTime;
      if (from != null && occurredAt.isBefore(_dayStart(from))) continue;
      if (to != null && occurredAt.isAfter(_dayEnd(to))) continue;
      filtered.add(expense);
    }

    final expenseIds = filtered.map((e) => e.id as int).toList();
    final tagIdsByExpense = await db.getTagIdsByExpenseIds(expenseIds);

    var total = 0;
    final amounts = <String, int>{};
    final colors = <String, Color>{};
    final labels = <String, String>{};

    for (final expense in filtered) {
      final tagIds = List<int>.from(
        tagIdsByExpense[expense.id as int] ?? const <int>[],
      )..removeWhere(excludedTagIds.contains);

      // If all tags excluded and expense had tags, skip it for tag breakdown;
      // for other breakdowns still include the amount.
      if (breakdown == DonutBreakdown.tags &&
          (tagIdsByExpense[expense.id as int] ?? const <int>[])
              .isNotEmpty &&
          tagIds.isEmpty) {
        continue;
      }

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
          final occurredAt = expense.occurredAt as DateTime;
          final key =
              '${occurredAt.year}-${occurredAt.month.toString().padLeft(2, '0')}';
          amounts[key] = (amounts[key] ?? 0) + amount;
          labels[key] = key;
          colors[key] ??= chartColorAt(amounts.length);
        case DonutBreakdown.currency:
          final key = expense.storedCurrencyCode as String;
          amounts[key] = (amounts[key] ?? 0) + amount;
          labels[key] = key;
          colors[key] ??= chartColorAt(key.hashCode);
      }
    }

    final entries = amounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    var i = 0;
    final slices = [
      for (final e in entries)
        _Slice(
          key: e.key,
          label: labels[e.key] ?? e.key,
          amountMinor: e.value,
          color: colors[e.key] ?? chartColorAt(i++),
        ),
    ];
    return (total: total, slices: slices);
  }
}
