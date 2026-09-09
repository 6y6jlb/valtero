/// Stored `operations.kind` and domain filter for money rows.
enum OperationKind { expense, income }

String operationKindDbValue(OperationKind kind) {
  return switch (kind) {
    OperationKind.expense => 'expense',
    OperationKind.income => 'income',
  };
}

OperationKind operationKindOf(String dbValue) {
  return dbValue == 'income' ? OperationKind.income : OperationKind.expense;
}

/// Tag `tags.kind` expected for an operation of [kind].
String tagKindDbValueForOperation(OperationKind kind) {
  return switch (kind) {
    OperationKind.expense => 'normal',
    OperationKind.income => 'income',
  };
}
