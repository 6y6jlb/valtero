import 'package:drift/drift.dart';
import 'package:valtero/shared/database/app_database.dart';

/// Schema v1 → v2: tag kind/country + many-to-many expense tags.
Future<void> migrateToV2(Migrator m, AppDatabase db) async {
  await m.addColumn(db.tags, db.tags.kind);
  await m.addColumn(db.tags, db.tags.countryCode);
  await m.createTable(db.expenseTags);
  await db.customStatement('''
    INSERT OR IGNORE INTO expense_tags (expense_id, tag_id)
    SELECT id, tag_id FROM expenses WHERE tag_id IS NOT NULL
  ''');
}
