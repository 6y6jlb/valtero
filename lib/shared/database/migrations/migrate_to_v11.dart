import 'package:drift/drift.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/sync_id.dart';

/// v11: cross-device [Operations.syncId], [Operations.updatedAt], soft-delete
/// [Operations.deletedAt] for last-write-wins sync.
Future<void> migrateToV11(Migrator m, AppDatabase db) async {
  // SQLite requires a DEFAULT when adding NOT NULL columns to a populated table.
  await db.customStatement(
    "ALTER TABLE operations ADD COLUMN sync_id TEXT NOT NULL DEFAULT ''",
  );
  await db.customStatement(
    'ALTER TABLE operations ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0',
  );
  await db.customStatement(
    'ALTER TABLE operations ADD COLUMN deleted_at INTEGER NULL',
  );

  final rows = await db.customSelect(
    'SELECT id, created_at FROM operations',
  ).get();
  for (final row in rows) {
    final id = row.read<int>('id');
    // Drift stores DateTime as microseconds since epoch (integer) by default.
    final createdRaw = row.data['created_at'];
    final createdMicros = createdRaw is int
        ? createdRaw
        : DateTime.tryParse('$createdRaw')?.microsecondsSinceEpoch ??
            DateTime.now().microsecondsSinceEpoch;
    await db.customStatement(
      'UPDATE operations SET sync_id = ?, updated_at = ?, deleted_at = NULL '
      'WHERE id = ?',
      [newSyncId(), createdMicros, id],
    );
  }

  await db.customStatement(
    'CREATE UNIQUE INDEX IF NOT EXISTS operations_sync_id '
    'ON operations (sync_id)',
  );
}
