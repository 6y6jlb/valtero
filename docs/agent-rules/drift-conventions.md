# Drift conventions

## Native SQLite

- Prefer Drift ≥2.32 with `sqlite3` ≥3.x — SQLite is bundled via build hooks; do **not** add `sqlite3_flutter_libs` (EOL).
- Explicit `sqlite3` in `pubspec.yaml` is optional once Drift pulls 3.x; pin only if you need a floor for hooks.
- If Linux fails to load SQLite after an upgrade, check Dart/Flutter native assets / build hooks before reintroducing discontinued flutter_libs packages.

## Placement

- Table + DAO definitions live under `lib/entities/<name>/data/`
- `lib/shared/database/app_database.dart` composes all tables/DAOs into one `AppDatabase`
- Do not open a second SQLite database for entity data

## Migrations

When changing a table:

1. Update the table class in the entity’s `data/` segment
2. Bump `schemaVersion` in `AppDatabase`
3. Add a `MigrationStrategy.onUpgrade` step
4. Run `dart run build_runner build --delete-conflicting-outputs`

## Examples

```dart
// ❌ BAD — table defined only inside shared/ with no entity ownership
// ✅ GOOD — ExpensesTable in entities/expense/data/, included in AppDatabase
```
