import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/cash_flow_selection_key.dart';

/// Selected cash-flow operations on the list (session UI state).
class CashFlowListSelection extends Notifier<Set<CashFlowSelectionKey>> {
  @override
  Set<CashFlowSelectionKey> build() => {};

  void clear() {
    if (state.isEmpty) return;
    state = {};
  }

  void toggle(CashFlowSelectionKey key) {
    final next = {...state};
    if (!next.remove(key)) next.add(key);
    state = next;
  }

  void toggleAll(Iterable<CashFlowSelectionKey> keys) {
    final keySet = keys.toSet();
    if (keySet.isEmpty) return;
    if (keySet.every(state.contains)) {
      state = {...state}..removeAll(keySet);
    } else {
      state = {...state, ...keySet};
    }
  }

  /// Drops keys that are no longer present (deleted / filtered out of source).
  void pruneTo(Iterable<CashFlowSelectionKey> validKeys) {
    final valid = validKeys.toSet();
    final next = state.intersection(valid);
    if (next.length == state.length) return;
    state = next;
  }
}

final cashFlowListSelectionProvider =
    NotifierProvider.autoDispose<CashFlowListSelection, Set<CashFlowSelectionKey>>(
  CashFlowListSelection.new,
);
