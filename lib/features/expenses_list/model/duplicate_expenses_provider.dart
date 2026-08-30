import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/expense/model/duplicate_matcher.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';

/// Derived view of local expenses that share a soft-duplicate fingerprint.
class DuplicateExpensesState {
  /// expenseId → sibling ids in the same group (including self).
  final Map<int, List<int>> groupByExpenseId;

  /// Distinct groups (each list length ≥ 2).
  final List<List<int>> groups;

  const DuplicateExpensesState({
    required this.groupByExpenseId,
    required this.groups,
  });

  static const empty = DuplicateExpensesState(
    groupByExpenseId: {},
    groups: [],
  );

  int get flaggedCount => groupByExpenseId.length;

  bool isFlagged(int expenseId) => groupByExpenseId.containsKey(expenseId);
}

final duplicateExpensesProvider = Provider<DuplicateExpensesState>((ref) {
  final expenses = ref.watch(allExpensesProvider).value;
  if (expenses == null || expenses.isEmpty) {
    return DuplicateExpensesState.empty;
  }
  final groups = groupPotentialDuplicates(expenses);
  if (groups.isEmpty) return DuplicateExpensesState.empty;
  final byId = <int, List<int>>{};
  for (final group in groups) {
    for (final id in group) {
      byId[id] = group;
    }
  }
  return DuplicateExpensesState(groupByExpenseId: byId, groups: groups);
});
