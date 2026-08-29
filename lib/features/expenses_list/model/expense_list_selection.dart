import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Selected expense ids on the expenses list (session UI state).
class ExpenseListSelection extends Notifier<Set<int>> {
  @override
  Set<int> build() => {};

  void clear() {
    if (state.isEmpty) return;
    state = {};
  }

  void toggle(int id) {
    final next = {...state};
    if (!next.remove(id)) next.add(id);
    state = next;
  }

  void toggleAll(Iterable<int> ids) {
    final idSet = ids.toSet();
    if (idSet.isEmpty) return;
    if (idSet.every(state.contains)) {
      state = {...state}..removeAll(idSet);
    } else {
      state = {...state, ...idSet};
    }
  }

  /// Drops ids that are no longer present (deleted / filtered out of source).
  void pruneTo(Iterable<int> validIds) {
    final valid = validIds.toSet();
    final next = state.intersection(valid);
    if (next.length == state.length) return;
    state = next;
  }
}

final expenseListSelectionProvider =
    NotifierProvider.autoDispose<ExpenseListSelection, Set<int>>(
  ExpenseListSelection.new,
);
