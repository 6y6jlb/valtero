import 'package:drift/drift.dart';
import 'package:valtero/shared/database/app_database.dart';

/// Adds [Expenses.duplicateDismissed] (default false).
Future<void> migrateToV6(Migrator m, AppDatabase db) async {
  await m.addColumn(db.expenses, db.expenses.duplicateDismissed);
}
