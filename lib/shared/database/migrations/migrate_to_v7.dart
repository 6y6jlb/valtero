import 'package:drift/drift.dart';
import 'package:valtero/shared/consts/tag_icons.dart';
import 'package:valtero/shared/database/app_database.dart';

/// Adds [Incomes] + [IncomeTags], and [Tags.iconKey] with seed backfill.
Future<void> migrateToV7(Migrator m, AppDatabase db) async {
  await m.createTable(db.incomes);
  await m.createTable(db.incomeTags);
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
