/// Monotonic Drift SQLite `user_version` and exchange-payload `schemaVersion`.
///
/// Bump by 1 when tables/columns change; add `migrations/migrate_to_vN.dart`
/// and wire it in [AppDatabase.migration]. See docs/agent-rules/drift-conventions.md.
const int kAppSchemaVersion = 3;
