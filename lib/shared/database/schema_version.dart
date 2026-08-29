/// Drift SQLite `user_version` and exchange-payload `schemaVersion`.
///
/// Production baseline is v5. Bump by exactly 1 and add
/// `lib/shared/database/migrations/migrate_to_vN.dart`, then wire
/// `if (from < N) await migrateToVN(m, this);` in [AppDatabase.migration].
/// Never wipe user data on upgrade — see docs/agent-rules/drift-conventions.md.
const int kAppSchemaVersion = 5;
