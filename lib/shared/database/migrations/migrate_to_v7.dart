import 'package:drift/drift.dart';
import 'package:valtero/shared/consts/tag_icons.dart';
import 'package:valtero/shared/database/app_database.dart';

/// Adds incomes + income_tags (intermediate; folded into operations at v8),
/// and [Tags.iconKey] with seed backfill.
///
/// Income DDL is raw SQL because those tables are not in the Drift database
/// class after schema v8.
Future<void> migrateToV7(Migrator m, AppDatabase db) async {
  await db.customStatement('''
CREATE TABLE IF NOT EXISTS incomes (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  occurred_at INTEGER NOT NULL,
  original_amount_minor INTEGER NOT NULL,
  original_currency_code TEXT NOT NULL CHECK(LENGTH(original_currency_code) >= 3 AND LENGTH(original_currency_code) <= 3),
  stored_amount_minor INTEGER NOT NULL,
  stored_currency_code TEXT NOT NULL CHECK(LENGTH(stored_currency_code) >= 3 AND LENGTH(stored_currency_code) <= 3),
  rate_used REAL NULL,
  rate_timestamp INTEGER NULL,
  payment_method_id INTEGER NULL REFERENCES payment_methods (id),
  country_code TEXT NULL,
  note TEXT NULL,
  created_at INTEGER NOT NULL,
  duplicate_dismissed INTEGER NOT NULL DEFAULT 0
)
''');

  await db.customStatement('''
CREATE TABLE IF NOT EXISTS income_tags (
  income_id INTEGER NOT NULL REFERENCES incomes (id) ON DELETE CASCADE,
  tag_id INTEGER NOT NULL REFERENCES tags (id) ON DELETE CASCADE,
  PRIMARY KEY (income_id, tag_id)
)
''');

  await m.addColumn(db.tags, db.tags.iconKey);

  // Backfill iconKey for known seeded stableKeys so upgraded installs
  // don't render blank icons for existing category tags.
  for (final entry in _seedIconBackfill.entries) {
    await db.customStatement(
      'UPDATE tags SET icon_key = ? WHERE stable_key = ? AND icon_key IS NULL',
      [entry.value, entry.key],
    );
  }
}

Map<String, String> get _seedIconBackfill {
  final map = <String, String>{};
  for (final key in [
    'groceries',
    'transport',
    'housing',
    'dining',
    'health',
    'entertainment',
    'shopping',
    'travel',
    'utilities',
    'salary',
    'sale',
    'gift',
    'refund',
    'investment',
    'other_income',
  ]) {
    final icon = defaultIconKeyForStableKey(key);
    if (icon != null) map[key] = icon;
  }
  return map;
}
