/// Drift SQLite `user_version` and exchange-payload `schemaVersion`.
///
/// Production baseline is **v8**. Fresh installs use `onCreate` (`createAll`).
/// Bumps above the baseline: add `lib/shared/database/migrations/migrate_to_vN.dart`
/// and wire `if (from < N) await migrateToVN(m, this);` in [AppDatabase.migration].
/// Databases with `user_version` below the baseline are refused (no wipe).
/// Never wipe user data on upgrade — see docs/agent-rules/drift-conventions.md.
const int kAppSchemaVersion = 10;
