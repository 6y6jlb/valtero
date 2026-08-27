import 'package:drift/drift.dart';
import 'package:valtero/shared/database/app_database.dart';

/// Schema v2 → v3: stable_key on tags + backfill from legacy names / country.
Future<void> migrateToV3(Migrator m, AppDatabase db) async {
  await m.addColumn(db.tags, db.tags.stableKey);
  const legacy = {
    'Groceries': 'groceries',
    'Transport': 'transport',
    'Housing': 'housing',
    'Dining': 'dining',
    'Health': 'health',
    'Entertainment': 'entertainment',
    'Shopping': 'shopping',
    'Travel': 'travel',
    'Продукты': 'groceries',
    'Транспорт': 'transport',
  };
  for (final entry in legacy.entries) {
    await db.customStatement(
      'UPDATE tags SET stable_key = ? WHERE name = ? AND (stable_key IS NULL OR stable_key = \'\')',
      [entry.value, entry.key],
    );
  }
  await db.customStatement(
    "UPDATE tags SET stable_key = 'country_' || country_code WHERE kind = 'country' AND country_code IS NOT NULL AND (stable_key IS NULL OR stable_key = '')",
  );
}
