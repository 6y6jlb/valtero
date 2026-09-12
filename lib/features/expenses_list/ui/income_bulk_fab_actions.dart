import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/income/model/income_provider.dart';
import 'package:valtero/features/expenses_list/model/income_list_selection.dart';
import 'package:valtero/features/expenses_list/ui/expense_bulk_action_bar.dart';
import 'package:valtero/features/expenses_list/ui/income_bulk_flows.dart';

/// Bulk actions for the income FAB row (same level as “add income”).
class IncomeBulkFabActions extends ConsumerStatefulWidget {
  const IncomeBulkFabActions({super.key});

  @override
  ConsumerState<IncomeBulkFabActions> createState() =>
      _IncomeBulkFabActionsState();
}

class _IncomeBulkFabActionsState extends ConsumerState<IncomeBulkFabActions> {
  bool _busy = false;

  Future<void> _run(Future<bool> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final ok = await action();
      if (ok && mounted) {
        ref.read(incomeListSelectionProvider.notifier).clear();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIds = ref.watch(incomeListSelectionProvider);
    final all = ref.watch(allIncomeProvider).value ?? const [];
    final validSelected =
        all.where((e) => selectedIds.contains(e.id)).toList();

    if (selectedIds.isNotEmpty && validSelected.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(incomeListSelectionProvider.notifier).clear();
      });
      return const SizedBox.shrink();
    }
    if (validSelected.isEmpty) return const SizedBox.shrink();

    if (validSelected.length != selectedIds.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(incomeListSelectionProvider.notifier).pruneTo(
              all.map((e) => e.id),
            );
      });
    }

    final maxWidth = MediaQuery.sizeOf(context).width - 96;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth.clamp(120, 480)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: OperationBulkActionBar(
          selectedCount: validSelected.length,
          onDelete: _busy
              ? null
              : () => _run(
                    () => runBulkDeleteIncomes(
                      context,
                      ref,
                      allIncomes: all,
                      selectedIds: selectedIds,
                    ),
                  ),
          onChangeTags: _busy
              ? null
              : () => _run(
                    () => runBulkChangeIncomeTags(
                      context,
                      ref,
                      allIncomes: all,
                      selectedIds: selectedIds,
                    ),
                  ),
          onChangeCountry: _busy
              ? null
              : () => _run(
                    () => runBulkChangeIncomeCountry(
                      context,
                      ref,
                      allIncomes: all,
                      selectedIds: selectedIds,
                    ),
                  ),
          onChangeCurrency: _busy
              ? null
              : () => _run(
                    () => runBulkChangeIncomeCurrency(
                      context,
                      ref,
                      allIncomes: all,
                      selectedIds: selectedIds,
                    ),
                  ),
        ),
      ),
    );
  }
}
