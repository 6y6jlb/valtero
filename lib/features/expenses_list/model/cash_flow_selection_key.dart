import 'package:valtero/features/expenses_list/model/recent_operation.dart';

/// Stable selection identity for a cash-flow list row (kind + id).
class CashFlowSelectionKey {
  final OperationKind kind;
  final int id;

  const CashFlowSelectionKey(this.kind, this.id);

  factory CashFlowSelectionKey.fromOperation(RecentOperation operation) {
    return CashFlowSelectionKey(operation.kind, operation.id);
  }

  @override
  bool operator ==(Object other) {
    return other is CashFlowSelectionKey && other.kind == kind && other.id == id;
  }

  @override
  int get hashCode => Object.hash(kind, id);
}
