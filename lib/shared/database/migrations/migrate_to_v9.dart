import 'package:drift/drift.dart';
import 'package:valtero/shared/database/app_database.dart';

/// v9: add optional [Tags.parentTagId] for one-level subcategories.
Future<void> migrateToV9(Migrator m, AppDatabase db) async {
  await m.addColumn(db.tags, db.tags.parentTagId);
}
