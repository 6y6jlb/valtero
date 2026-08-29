import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/features/expenses_list/model/expense_list_selection.dart';
import 'package:valtero/features/expenses_list/ui/expense_bulk_action_bar.dart';
import 'package:valtero/features/expenses_list/ui/expense_bulk_flows.dart';

/// Bulk actions for the expenses FAB row (same level as “add expense”).
class ExpenseBulkFabActions extends ConsumerStatefulWidget {
  const ExpenseBulkFabActions({super.key});

  @override
  ConsumerState<ExpenseBulkFabActions> createState() =>
      _ExpenseBulkFabActionsState();
}

class _ExpenseBulkFabActionsState extends ConsumerState<ExpenseBulkFabActions> {
  bool _busy = false;

  Future<void> _run(Future<bool> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final ok = await action();
      if (ok && mounted) {
        ref.read(expenseListSelectionProvider.notifier).clear();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIds = ref.watch(expenseListSelectionProvider);
    final all = ref.watch(allExpensesProvider).value ?? const [];
    final validSelected = all.where((e) => selectedIds.contains(e.id)).toList();

    if (selectedIds.isNotEmpty && validSelected.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(expenseListSelectionProvider.notifier).clear();
      });
      return const SizedBox.shrink();
    }
    if (validSelected.isEmpty) return const SizedBox.shrink();

    if (validSelected.length != selectedIds.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(expenseListSelectionProvider.notifier).pruneTo(
              all.map((e) => e.id),
            );
      });
    }

    final maxWidth = MediaQuery.sizeOf(context).width - 96;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth.clamp(120, 480)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ExpenseBulkActionBar(
          selectedCount: validSelected.length,
          onDelete: _busy
              ? null
              : () => _run(
                    () => runBulkDeleteExpenses(
                      context,
                      ref,
                      allExpenses: all,
                      selectedIds: selectedIds,
                    ),
                  ),
          onChangeTags: _busy
              ? null
              : () => _run(
                    () => runBulkChangeTags(
                      context,
                      ref,
                      allExpenses: all,
                      selectedIds: selectedIds,
                    ),
                  ),
          onChangeCountry: _busy
              ? null
              : () => _run(
                    () => runBulkChangeCountry(
                      context,
                      ref,
                      allExpenses: all,
                      selectedIds: selectedIds,
                    ),
                  ),
          onChangeCurrency: _busy
              ? null
              : () => _run(
                    () => runBulkChangeCurrency(
                      context,
                      ref,
                      allExpenses: all,
                      selectedIds: selectedIds,
                    ),
                  ),
        ),
      ),
    );
  }
}
