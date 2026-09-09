import 'package:drift/drift.dart';
import 'package:valtero/shared/database/app_database.dart';

/// Adds `expenses.duplicate_dismissed` (default false).
///
/// Uses raw SQL because [Expenses] was removed from the Drift database class
/// at schema v8 (merged into [Operations]).
Future<void> migrateToV6(Migrator m, AppDatabase db) async {
  await db.customStatement(
    'ALTER TABLE expenses ADD COLUMN duplicate_dismissed INTEGER NOT NULL '
    'DEFAULT 0',
  );
}
