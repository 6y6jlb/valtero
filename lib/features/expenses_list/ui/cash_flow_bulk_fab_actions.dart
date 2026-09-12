import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/income/model/income_provider.dart';
import 'package:valtero/features/expenses_list/model/bulk_cash_flow_controller.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_list_selection.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_selection_key.dart';
import 'package:valtero/features/expenses_list/model/recent_operation.dart';
import 'package:valtero/features/expenses_list/ui/cash_flow_bulk_flows.dart';
import 'package:valtero/features/expenses_list/ui/expense_bulk_action_bar.dart';

/// Bulk actions for the cash-flow FAB row.
class CashFlowBulkFabActions extends ConsumerStatefulWidget {
  const CashFlowBulkFabActions({super.key});

  @override
  ConsumerState<CashFlowBulkFabActions> createState() =>
      _CashFlowBulkFabActionsState();
}

class _CashFlowBulkFabActionsState extends ConsumerState<CashFlowBulkFabActions> {
  bool _busy = false;

  Future<void> _run(Future<bool> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final ok = await action();
      if (ok && mounted) {
        ref.read(cashFlowListSelectionProvider.notifier).clear();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedKeys = ref.watch(cashFlowListSelectionProvider);
    final expenses = ref.watch(allExpensesProvider).value ?? const [];
    final incomes = ref.watch(allIncomeProvider).value ?? const [];
    final allOperations = mergeRecentOperations(
      expenses: expenses,
      incomes: incomes,
    );
    final allKeys =
        allOperations.map(CashFlowSelectionKey.fromOperation).toSet();
    final validKeys = allKeys.intersection(selectedKeys);

    if (selectedKeys.isNotEmpty && validKeys.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(cashFlowListSelectionProvider.notifier).clear();
      });
      return const SizedBox.shrink();
    }
    if (validKeys.isEmpty) return const SizedBox.shrink();

    if (validKeys.length != selectedKeys.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(cashFlowListSelectionProvider.notifier).pruneTo(allKeys);
      });
    }

    final tagsEnabled = homogeneousCashFlowKind(selectedKeys) != null;
    final maxWidth = MediaQuery.sizeOf(context).width - 96;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth.clamp(120, 480)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: OperationBulkActionBar(
          selectedCount: validKeys.length,
          onDelete: _busy
              ? null
              : () => _run(
                    () => runBulkDeleteCashFlow(
                      context,
                      ref,
                      allOperations: allOperations,
                      selectedKeys: selectedKeys,
                    ),
                  ),
          onChangeTags: !_busy && tagsEnabled
              ? () => _run(
                    () => runBulkChangeCashFlowTags(
                      context,
                      ref,
                      allOperations: allOperations,
                      selectedKeys: selectedKeys,
                    ),
                  )
              : null,
          onChangeCountry: _busy
              ? null
              : () => _run(
                    () => runBulkChangeCashFlowCountry(
                      context,
                      ref,
                      allOperations: allOperations,
                      selectedKeys: selectedKeys,
                    ),
                  ),
          onChangeCurrency: _busy
              ? null
              : () => _run(
                    () => runBulkChangeCashFlowCurrency(
                      context,
                      ref,
                      allOperations: allOperations,
                      selectedKeys: selectedKeys,
                    ),
                  ),
        ),
      ),
    );
  }
}
