import 'package:drift/drift.dart';
import 'package:valtero/entities/operation/data/operations_table.dart';
import 'package:valtero/entities/tag/data/tags_table.dart';

/// Many-to-many: operation ↔ tags.
class OperationTags extends Table {
  IntColumn get operationId =>
      integer().references(Operations, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {operationId, tagId};
}
