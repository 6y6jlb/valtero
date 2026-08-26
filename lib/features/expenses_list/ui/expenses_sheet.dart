import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/expense/model/expense_tags_provider.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/expense/ui/expense_tile.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/entities/tag/ui/tag_chip.dart';
import 'package:valtero/features/add_expense/model/add_expense_controller.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/features/export_expenses/model/export_controller.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/flag_icon.dart';

Future<void> showExpensesSheet(
  BuildContext context, {
  ExpenseListQuery? initial,
}) {
  return showAppModalSheet(
    context: context,
    initialChildSize: 0.9,
    minChildSize: 0.5,
    child: ExpensesSheetBody(initial: initial ?? const ExpenseListQuery()),
  );
}

class ExpensesSheetBody extends ConsumerStatefulWidget {
  final ExpenseListQuery initial;

  const ExpensesSheetBody({super.key, required this.initial});

  @override
  ConsumerState<ExpensesSheetBody> createState() => _ExpensesSheetBodyState();
}

class _ExpensesSheetBodyState extends ConsumerState<ExpensesSheetBody> {
  late ExpenseListQuery _query;
  String? _exportMessage;

  @override
  void initState() {
    super.initState();
    _query = widget.initial;
  }

  DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _dayEnd(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  String _formatDay(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<Expense> _applyFilter(
    List<Expense> all,
    Map<int, List<int>> expenseTags,
  ) {
    return all.where((e) {
      if (_query.currencyCode != null &&
          e.storedCurrencyCode != _query.currencyCode) {
        return false;
      }
      if (_query.from != null && e.occurredAt.isBefore(_dayStart(_query.from!))) {
        return false;
      }
      if (_query.to != null && e.occurredAt.isAfter(_dayEnd(_query.to!))) {
        return false;
      }
      if (_query.tagIds.isNotEmpty) {
        final ids = expenseTags[e.id] ?? const <int>[];
        if (!_query.tagIds.any(ids.contains)) return false;
      }
      return true;
    }).toList();
  }

  List<Expense> _applySort(List<Expense> list) {
    final sorted = [...list];
    int cmp(Expense a, Expense b) {
      final raw = switch (_query.sort) {
        ExpenseListSortField.date => a.occurredAt.compareTo(b.occurredAt),
        ExpenseListSortField.amount =>
          a.storedAmountMinor.compareTo(b.storedAmountMinor),
        ExpenseListSortField.currency =>
          a.storedCurrencyCode.compareTo(b.storedCurrencyCode),
      };
      return _query.ascending ? raw : -raw;
    }

    sorted.sort(cmp);
    return sorted;
  }

  /// Sections for the current group mode. Tag grouping may list an expense
  /// under multiple headers when it has several tags.
  List<({String header, List<Expense> items})> _group(
    List<Expense> list,
    Map<int, List<int>> expenseTags,
    Map<int, String> tagLabels,
    String untaggedLabel,
  ) {
    switch (_query.group) {
      case ExpenseListGroup.none:
        return [(header: '', items: list)];
      case ExpenseListGroup.currency:
        final map = <String, List<Expense>>{};
        for (final e in list) {
          map.putIfAbsent(e.storedCurrencyCode, () => []).add(e);
        }
        final keys = map.keys.toList()..sort();
        return [for (final k in keys) (header: k, items: map[k]!)];
      case ExpenseListGroup.date:
        final map = <String, List<Expense>>{};
        for (final e in list) {
          map.putIfAbsent(_formatDay(e.occurredAt), () => []).add(e);
        }
        final keys = map.keys.toList()
          ..sort((a, b) => _query.ascending ? a.compareTo(b) : b.compareTo(a));
        return [for (final k in keys) (header: k, items: map[k]!)];
      case ExpenseListGroup.tag:
        final map = <String, List<Expense>>{};
        for (final e in list) {
          final ids = expenseTags[e.id] ?? const <int>[];
          if (ids.isEmpty) {
            map.putIfAbsent(untaggedLabel, () => []).add(e);
          } else {
            for (final id in ids) {
              final label = tagLabels[id] ?? '?';
              map.putIfAbsent(label, () => []).add(e);
            }
          }
        }
        final keys = map.keys.toList()..sort();
        return [for (final k in keys) (header: k, items: map[k]!)];
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom
        ? (_query.from ?? DateTime.now())
        : (_query.to ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _query = isFrom
          ? _query.copyWith(from: picked)
          : _query.copyWith(to: picked);
    });
  }

  Future<void> _export(ExportFormat format, {required bool share}) async {
    final expenses = ref.read(allExpensesProvider).value ?? const [];
    final tags = ref.read(tagsStreamProvider).value ?? const [];
    final expenseTags = ref.read(expenseTagIdsProvider).value ?? const {};
    final tagLabels = {
      for (final t in tags) t.id: localizedTagLabel(context, t),
    };
    final filtered = _applySort(_applyFilter(expenses, expenseTags));
    final tagsByExpense = {
      for (final e in filtered) e.id: expenseTags[e.id] ?? const <int>[],
    };
    final controller = ref.read(exportControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    try {
      if (share) {
        await controller.shareFor(
          format,
          expenses: filtered,
          tagNames: tagLabels,
          tagsByExpense: tagsByExpense,
        );
      } else {
        final path = await controller.saveFileFor(
          format,
          expenses: filtered,
          tagNames: tagLabels,
          tagsByExpense: tagsByExpense,
        );
        if (!mounted) return;
        setState(() => _exportMessage = path == null ? null : l10n.exportDone);
        return;
      }
      if (!mounted) return;
      setState(() => _exportMessage = l10n.exportDone);
    } catch (_) {
      if (!mounted) return;
      setState(() => _exportMessage = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final expensesAsync = ref.watch(allExpensesProvider);
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final expenseTags = ref.watch(expenseTagIdsProvider).value ?? const {};
    final tagLabels = {
      for (final t in tags) t.id: localizedTagLabel(context, t),
    };
    final scrollController = PrimaryScrollController.maybeOf(context);

    final currencyOptions = <String>{
      for (final e in expensesAsync.value ?? const []) e.storedCurrencyCode,
    }.toList()
      ..sort();

    return expensesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (all) {
        final filtered = _applySort(_applyFilter(all, expenseTags));
        final sections = _group(
          filtered,
          expenseTags,
          tagLabels,
          l10n.untagged,
        );

        return CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.showExpenses,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.filterTag,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final tag in tags)
                          TagChip(
                            tag: tag,
                            selected: _query.tagIds.contains(tag.id),
                            onTap: () {
                              setState(() {
                                final next = {..._query.tagIds};
                                if (next.contains(tag.id)) {
                                  next.remove(tag.id);
                                } else {
                                  next.add(tag.id);
                                }
                                _query = _query.copyWith(tagIds: next);
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      // ignore: deprecated_member_use
                      value: _query.currencyCode,
                      isExpanded: true,
                      decoration:
                          InputDecoration(labelText: l10n.filterCurrency),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l10n.all),
                        ),
                        for (final code in currencyOptions)
                          DropdownMenuItem<String?>(
                            value: code,
                            child: CurrencyCodeLabel(code),
                          ),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _query = v == null
                              ? _query.copyWith(clearCurrencyCode: true)
                              : _query.copyWith(currencyCode: v);
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickDate(isFrom: true),
                            onLongPress: () => setState(
                              () => _query = _query.copyWith(clearFrom: true),
                            ),
                            child: Text(
                              _query.from == null
                                  ? l10n.periodFrom
                                  : '${l10n.periodFrom}: ${_formatDay(_query.from!)}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickDate(isFrom: false),
                            onLongPress: () => setState(
                              () => _query = _query.copyWith(clearTo: true),
                            ),
                            child: Text(
                              _query.to == null
                                  ? l10n.periodTo
                                  : '${l10n.periodTo}: ${_formatDay(_query.to!)}',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.sortBy,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    SegmentedButton<ExpenseListSortField>(
                      segments: [
                        ButtonSegment(
                          value: ExpenseListSortField.date,
                          label: Text(l10n.sortDate),
                        ),
                        ButtonSegment(
                          value: ExpenseListSortField.amount,
                          label: Text(l10n.sortAmount),
                        ),
                        ButtonSegment(
                          value: ExpenseListSortField.currency,
                          label: Text(l10n.sortCurrency),
                        ),
                      ],
                      selected: {_query.sort},
                      onSelectionChanged: (s) {
                        setState(
                          () => _query = _query.copyWith(sort: s.first),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilterChip(
                        label: Text(
                          _query.ascending ? l10n.ascending : l10n.descending,
                        ),
                        selected: _query.ascending,
                        onSelected: (v) {
                          setState(
                            () => _query = _query.copyWith(ascending: v),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.groupBy,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    SegmentedButton<ExpenseListGroup>(
                      segments: [
                        ButtonSegment(
                          value: ExpenseListGroup.none,
                          label: Text(l10n.groupNone),
                        ),
                        ButtonSegment(
                          value: ExpenseListGroup.currency,
                          label: Text(l10n.groupCurrency),
                        ),
                        ButtonSegment(
                          value: ExpenseListGroup.date,
                          label: Text(l10n.groupDate),
                        ),
                        ButtonSegment(
                          value: ExpenseListGroup.tag,
                          label: Text(l10n.groupTag),
                        ),
                      ],
                      selected: {_query.group},
                      onSelectionChanged: (s) {
                        setState(
                          () => _query = _query.copyWith(group: s.first),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonal(
                          onPressed: () =>
                              _export(ExportFormat.csv, share: false),
                          child: Text('${l10n.exportCsv} · ${l10n.saveFile}'),
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              _export(ExportFormat.csv, share: true),
                          child: Text('${l10n.exportCsv} · ${l10n.share}'),
                        ),
                        FilledButton.tonal(
                          onPressed: () =>
                              _export(ExportFormat.json, share: false),
                          child: Text('${l10n.exportJson} · ${l10n.saveFile}'),
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              _export(ExportFormat.json, share: true),
                          child: Text('${l10n.exportJson} · ${l10n.share}'),
                        ),
                      ],
                    ),
                    if (_exportMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(_exportMessage!),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.navExpenses}: ${filtered.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text(l10n.noExpenses)),
              )
            else
              for (final section in sections) ...[
                if (section.header.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        section.header,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                  ),
                SliverList.builder(
                  itemCount: section.items.length,
                  itemBuilder: (context, index) {
                    final expense = section.items[index];
                    final ids = expenseTags[expense.id] ?? const <int>[];
                    final label = ids.isEmpty
                        ? l10n.untagged
                        : ids.map((id) => tagLabels[id] ?? '?').join(', ');
                    return ExpenseTile(
                      expense: expense,
                      tagLabel: label,
                      onDelete: () {
                        ref
                            .read(addExpenseControllerProvider)
                            .delete(expense.id);
                        ref.invalidate(expenseTagIdsProvider);
                      },
                    );
                  },
                ),
              ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      },
    );
  }
}
