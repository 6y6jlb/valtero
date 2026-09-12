import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/bulk_expense_controller.dart';
import 'package:valtero/features/expenses_list/model/bulk_income_controller.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_selection_key.dart';
import 'package:valtero/features/expenses_list/model/recent_operation.dart';

/// Partitions a cash-flow multi-select into expense and income id lists.
({List<int> expenseIds, List<int> incomeIds}) partitionCashFlowSelection(
  Set<CashFlowSelectionKey> keys,
) {
  final expenseIds = <int>[];
  final incomeIds = <int>[];
  for (final key in keys) {
    switch (key.kind) {
      case OperationKind.expense:
        expenseIds.add(key.id);
      case OperationKind.income:
        incomeIds.add(key.id);
    }
  }
  return (expenseIds: expenseIds, incomeIds: incomeIds);
}

/// Whether every selected row is the same [OperationKind].
OperationKind? homogeneousCashFlowKind(Set<CashFlowSelectionKey> keys) {
  if (keys.isEmpty) return null;
  final first = keys.first.kind;
  if (keys.every((k) => k.kind == first)) return first;
  return null;
}

/// Batch updates for selected cash-flow operations (delegates by kind).
class BulkCashFlowController {
  final Ref ref;

  BulkCashFlowController(this.ref);

  BulkExpenseController get _expenses =>
      ref.read(bulkExpenseControllerProvider);
  BulkIncomeController get _incomes => ref.read(bulkIncomeControllerProvider);

  Future<void> deleteMany(Set<CashFlowSelectionKey> keys) async {
    final parts = partitionCashFlowSelection(keys);
    await _expenses.deleteMany(parts.expenseIds);
    await _incomes.deleteMany(parts.incomeIds);
  }

  Future<void> setCountry(Set<CashFlowSelectionKey> keys, String? countryCode) async {
    final parts = partitionCashFlowSelection(keys);
    await _expenses.setCountry(parts.expenseIds, countryCode);
    await _incomes.setCountry(parts.incomeIds, countryCode);
  }

  Future<void> setExpenseTags(Set<CashFlowSelectionKey> keys, List<int> tagIds) async {
    final parts = partitionCashFlowSelection(keys);
    await _expenses.setTags(parts.expenseIds, tagIds);
  }

  Future<void> setIncomeTags(Set<CashFlowSelectionKey> keys, List<int> tagIds) async {
    final parts = partitionCashFlowSelection(keys);
    await _incomes.setTags(parts.incomeIds, tagIds);
  }

  /// Converts each operation from its original amount into [currencyCode].
  /// Throws [StateError] with `rate_unavailable` if any pair has no rate.
  Future<void> convertToCurrency(
    Set<CashFlowSelectionKey> keys,
    String currencyCode,
  ) async {
    final parts = partitionCashFlowSelection(keys);
    await _expenses.convertToCurrency(parts.expenseIds, currencyCode);
    await _incomes.convertToCurrency(parts.incomeIds, currencyCode);
  }
}

final bulkCashFlowControllerProvider = Provider<BulkCashFlowController>((ref) {
  return BulkCashFlowController(ref);
});
