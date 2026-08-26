import 'package:drift/drift.dart';
import 'package:valtero/entities/expense/data/expenses_table.dart';
import 'package:valtero/entities/tag/data/tags_table.dart';

/// Many-to-many: expense ↔ tags.
class ExpenseTags extends Table {
  IntColumn get expenseId => integer().references(Expenses, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId => integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {expenseId, tagId};
}
