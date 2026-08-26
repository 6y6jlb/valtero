# Drift conventions

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
