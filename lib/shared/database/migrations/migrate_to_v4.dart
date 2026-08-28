import 'package:drift/drift.dart';
import 'package:valtero/shared/database/app_database.dart';

/// Schema v3 → v4: payment_methods table + expenses.payment_method_id.
/// Drops MVP resource tags (payment is no longer a tag kind).
Future<void> migrateToV4(Migrator m, AppDatabase db) async {
  await m.createTable(db.paymentMethods);
  await m.addColumn(db.expenses, db.expenses.paymentMethodId);

  await db.customStatement(
    'DELETE FROM expense_tags WHERE tag_id IN '
    "(SELECT id FROM tags WHERE kind = 'resource')",
  );
  await db.customStatement("DELETE FROM tags WHERE kind = 'resource'");
}
