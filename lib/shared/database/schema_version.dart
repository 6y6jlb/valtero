/// Drift SQLite `user_version` and exchange-payload `schemaVersion`.
///
/// MVP: single baseline schema (no stepwise migrate_to_vN). Bumped past prior
/// local installs so [AppDatabase] can wipe + recreate on upgrade. Before
/// production data, restore monotonic migrate_to_vN steps — see
/// docs/agent-rules/drift-conventions.md.
const int kAppSchemaVersion = 5;
