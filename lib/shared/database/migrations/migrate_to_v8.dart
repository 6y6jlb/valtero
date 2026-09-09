import 'package:drift/drift.dart';
import 'package:valtero/shared/database/app_database.dart';

/// Merges [expenses]/[incomes] (+ tag junctions) into [operations]/[operation_tags].
///
/// Uses raw SQL so old tables need not stay in the Drift database class.
/// Expense ids are preserved; income ids are offset by max(expense id).
Future<void> migrateToV8(Migrator m, AppDatabase db) async {
  await m.createTable(db.operations);
  await m.createTable(db.operationTags);

  await db.customStatement('''
INSERT INTO operations (
  id, kind, occurred_at, original_amount_minor, original_currency_code,
  stored_amount_minor, stored_currency_code, rate_used, rate_timestamp,
  payment_method_id, country_code, note, created_at, duplicate_dismissed
)
SELECT
  id, 'expense', occurred_at, original_amount_minor, original_currency_code,
  stored_amount_minor, stored_currency_code, rate_used, rate_timestamp,
  payment_method_id, country_code, note, created_at, duplicate_dismissed
FROM expenses
''');

  await db.customStatement('''
INSERT INTO operations (
  id, kind, occurred_at, original_amount_minor, original_currency_code,
  stored_amount_minor, stored_currency_code, rate_used, rate_timestamp,
  payment_method_id, country_code, note, created_at, duplicate_dismissed
)
SELECT
  id + (SELECT COALESCE(MAX(id), 0) FROM expenses),
  'income', occurred_at, original_amount_minor, original_currency_code,
  stored_amount_minor, stored_currency_code, rate_used, rate_timestamp,
  payment_method_id, country_code, note, created_at, duplicate_dismissed
FROM incomes
''');

  await db.customStatement('''
INSERT OR IGNORE INTO operation_tags (operation_id, tag_id)
SELECT expense_id, tag_id FROM expense_tags
''');

  // Legacy single-tag column on expenses.
  await db.customStatement('''
INSERT OR IGNORE INTO operation_tags (operation_id, tag_id)
SELECT id, tag_id FROM expenses WHERE tag_id IS NOT NULL
''');

  await db.customStatement('''
INSERT OR IGNORE INTO operation_tags (operation_id, tag_id)
SELECT
  income_id + (SELECT COALESCE(MAX(id), 0) FROM expenses),
  tag_id
FROM income_tags
''');

  await db.customStatement('DROP TABLE IF EXISTS expense_tags');
  await db.customStatement('DROP TABLE IF EXISTS income_tags');
  await db.customStatement('DROP TABLE IF EXISTS expenses');
  await db.customStatement('DROP TABLE IF EXISTS incomes');

  // Keep autoincrement past the highest remapped id.
  await db.customStatement('''
UPDATE sqlite_sequence
SET seq = (SELECT COALESCE(MAX(id), 0) FROM operations)
WHERE name = 'operations'
''');
}
