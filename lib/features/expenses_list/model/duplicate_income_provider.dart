import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/income/model/duplicate_matcher.dart';
import 'package:valtero/entities/income/model/income_provider.dart';

/// Derived view of local incomes that share a soft-duplicate fingerprint.
/// Mirrors [DuplicateExpensesState] / `duplicateExpensesProvider`.
class DuplicateIncomeState {
  /// incomeId → sibling ids in the same group (including self).
  final Map<int, List<int>> groupByIncomeId;

  /// Distinct groups (each list length ≥ 2).
  final List<List<int>> groups;

  const DuplicateIncomeState({
    required this.groupByIncomeId,
    required this.groups,
  });

  static const empty = DuplicateIncomeState(
    groupByIncomeId: {},
    groups: [],
  );

  int get flaggedCount => groupByIncomeId.length;

  bool isFlagged(int incomeId) => groupByIncomeId.containsKey(incomeId);
}

final duplicateIncomeProvider = Provider<DuplicateIncomeState>((ref) {
  final incomes = ref.watch(allIncomeProvider).value;
  if (incomes == null || incomes.isEmpty) {
    return DuplicateIncomeState.empty;
  }
  final groups = groupPotentialIncomeDuplicates(incomes);
  if (groups.isEmpty) return DuplicateIncomeState.empty;
  final byId = <int, List<int>>{};
  for (final group in groups) {
    for (final id in group) {
      byId[id] = group;
    }
  }
  return DuplicateIncomeState(groupByIncomeId: byId, groups: groups);
});
