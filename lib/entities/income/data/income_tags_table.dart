import 'package:drift/drift.dart';
import 'package:valtero/entities/income/data/incomes_table.dart';
import 'package:valtero/entities/tag/data/tags_table.dart';

/// Many-to-many: income ↔ tags.
class IncomeTags extends Table {
  IntColumn get incomeId =>
      integer().references(Incomes, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {incomeId, tagId};
}
