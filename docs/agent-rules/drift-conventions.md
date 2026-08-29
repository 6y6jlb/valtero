# Drift conventions

## Native SQLite

- Prefer Drift ≥2.32 with `sqlite3` ≥3.x — SQLite is bundled via build hooks; do **not** add `sqlite3_flutter_libs` (EOL).
- Explicit `sqlite3` in `pubspec.yaml` is optional once Drift pulls 3.x; pin only if you need a floor for hooks.
- If Linux fails to load SQLite after an upgrade, check Dart/Flutter native assets / build hooks before reintroducing discontinued flutter_libs packages.

## Placement

- Table + DAO definitions live under `lib/entities/<name>/data/`
- `lib/shared/database/app_database.dart` composes all tables/DAOs into one `AppDatabase`
- Do not open a second SQLite database for entity data
- Schema version SSOT: `lib/shared/database/schema_version.dart` (`kAppSchemaVersion`)
- Local upgrade steps: `lib/shared/database/migrations/migrate_to_vN.dart`

## Local schema migrations (Drift)

Drift already stores an integer `user_version` in SQLite. On open it compares that to `AppDatabase.schemaVersion` (= `kAppSchemaVersion`) and runs `MigrationStrategy.onUpgrade`. **Do not invent a parallel hash-based migrator** — use the monotonic int.

Production baseline is **v5**. Destructive wipe-on-upgrade is **forbidden**.

### Checklist (same PR as the table change)

1. Update the table class in the entity’s `data/` segment
2. Bump `kAppSchemaVersion` by **exactly 1** (no skipping versions in a single release chain)
3. Add `lib/shared/database/migrations/migrate_to_vN.dart` for the new `N`
4. Wire `if (from < N) await migrateToVN(m, this);` in `AppDatabase.migration`
5. Run `dart run build_runner build --delete-conflicting-outputs` (or `make codegen`)
6. If the change alters the portable payload shape, update **import adapters** for exchange (see below) in the same PR when import already exists

### Rules for each step

- One bump → one `migrateToVN` (schema DDL and/or data backfill)
- Prefer Drift `Migrator` helpers (`addColumn`, `createTable`, …); use `customStatement` when SQLite needs recreate/copy for rename/drop
- New columns: nullable **or** default **or** explicit backfill in the same step — never leave existing rows unreadable
- Steps should be safe if re-entered only after a failed mid-upgrade where possible (`INSERT OR IGNORE`, guarded `UPDATE`)
- **Never wipe** user DB on upgrade
- Hive (`AppSettings`) is **not** Drift: version/default new fields there separately; do not fold Hive into `kAppSchemaVersion`

### Schema vs data

| Kind | Examples | Where |
| --- | --- | --- |
| Schema | add/drop/rename column, new table | `Migrator` / SQL recreate |
| Data | copy `tag_id` → `expense_tags`, set `stable_key` from legacy names | `customStatement` / queries in the same `migrateToVN` |

### Tests (when change is risky)

Prefer a fixture DB at version `N-1` opened with code at `N` for breaking changes (drop/rename, non-null without default, semantic reinterpretation of money/tags).

## Inter-app / backup exchange (encrypted files)

Copy / export / import between devices (and future encrypted interchange) must **not** rely on app semver alone. Persist versions **inside the payload** (outside or inside the ciphertext envelope as designed, but always available after decrypt).

### Recommended envelope fields

| Field | Meaning |
| --- | --- |
| `formatVersion` | Wire/envelope format (encryption, headers, compression). Bump when the **file packaging** changes. |
| `schemaVersion` | Same integer as `kAppSchemaVersion` at export time. Describes the **logical row/field shape** of the payload. |
| `exportedAt` / `appVersion` | Diagnostics only; do not drive migration logic |

Human CSV (share/Telegram convenience) may stay best-effort and unversioned. **Strict interchange** (restore, merge between apps, encrypted backup) must use the versioned envelope.

### Import policy

1. Decrypt / parse envelope → read `formatVersion` + `schemaVersion`
2. Unknown / newer `formatVersion` → refuse with “update the app”
3. `schemaVersion` **>** local `kAppSchemaVersion` → refuse (file from a newer app)
4. `schemaVersion` **≤** local → run **import adapters** `payload vK → … → current` (normalize JSON/maps in memory), then insert into the **already-migrated** local DB
5. Do not dump a foreign payload straight into SQLite without adapting field names / nullability / tag identity (`stableKey` preferred over local numeric `id`)

Local Drift migrations and import adapters solve the same compatibility problem on different media:

- **DB file on disk** → `migrate_to_vN` via Drift `onUpgrade`
- **Exchange file** → adapter chain keyed by `schemaVersion` in the envelope

When adding a schema bump that changes portable fields, document whether an import adapter is required (new optional field with default → often no; rename/drop/semantic change → yes).

### Identity across devices

Prefer stable business keys in interchange (`tags[].stableKey`, ISO timestamps, amounts in **integer minor units**), not autoincrement `id`s. Remap ids on import.

## Examples

```dart
// ❌ BAD — change Expenses columns without bumping kAppSchemaVersion / migrateToVN
// ✅ GOOD — bump to N, add migrations/migrate_to_vN.dart, wire onUpgrade

// ❌ BAD — encrypted backup with only appVersion "1.2.0", no schemaVersion
// ✅ GOOD — envelope includes formatVersion + schemaVersion == kAppSchemaVersion at export

// ❌ BAD — table defined only inside shared/ with no entity ownership
// ✅ GOOD — ExpensesTable in entities/expense/data/, included in AppDatabase
```
