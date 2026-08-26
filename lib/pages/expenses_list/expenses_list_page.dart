import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/entities/tag/ui/tag_chip.dart';
import 'package:valtero/features/expenses_filter/model/expense_filter.dart';
import 'package:valtero/features/add_expense/model/add_expense_controller.dart';
import 'package:valtero/entities/expense/ui/expense_tile.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

final expenseFilterProvider =
    StateProvider<ExpenseFilter>((ref) => ExpenseFilter.empty);

class ExpensesListPage extends ConsumerWidget {
  const ExpensesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final filter = ref.watch(expenseFilterProvider);
    final expensesAsync = ref.watch(expensesStreamProvider(filter));
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final tagNames = {for (final t in tags) t.id: t.name};

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  // ignore: deprecated_member_use
                  value: filter.tagId,
                  decoration: InputDecoration(labelText: l10n.filterTag),
                  items: [
                    DropdownMenuItem<int?>(value: null, child: Text(l10n.all)),
                    for (final tag in tags)
                      DropdownMenuItem(value: tag.id, child: Text(tag.name)),
                  ],
                  onChanged: (v) {
                    ref.read(expenseFilterProvider.notifier).state =
                        filter.copyWith(tagId: v, clearTagId: v == null);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  // ignore: deprecated_member_use
                  value: filter.currencyCode,
                  decoration: InputDecoration(labelText: l10n.filterCurrency),
                  items: [
                    DropdownMenuItem<String?>(value: null, child: Text(l10n.all)),
                    ...{
                      for (final e in ref.watch(allExpensesProvider).value ?? const [])
                        e.storedCurrencyCode,
                    }.map(
                      (c) => DropdownMenuItem(value: c, child: Text(c)),
                    ),
                  ],
                  onChanged: (v) {
                    ref.read(expenseFilterProvider.notifier).state = filter.copyWith(
                      currencyCode: v,
                      clearCurrencyCode: v == null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (tags.isNotEmpty)
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final tag in tags)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TagChip(
                      tag: tag,
                      selected: filter.tagId == tag.id,
                      onTap: () {
                        ref.read(expenseFilterProvider.notifier).state =
                            filter.tagId == tag.id
                                ? filter.copyWith(clearTagId: true)
                                : filter.copyWith(tagId: tag.id);
                      },
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: expensesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (expenses) {
              if (expenses.isEmpty) {
                return Center(child: Text(l10n.noExpenses));
              }
              return ListView.separated(
                itemCount: expenses.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return ExpenseTile(
                    expense: expense,
                    tagName: expense.tagId == null
                        ? l10n.untagged
                        : tagNames[expense.tagId!],
                    onDelete: () {
                      ref.read(addExpenseControllerProvider).delete(expense.id);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
