import 'dart:io';

import 'package:drift/drift.dart'
    show
        Migrator,
        OpeningDetails,
        QueryExecutor,
        QueryExecutorUser,
        Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/migrations/migrate_to_v10.dart';
import 'package:valtero/shared/database/migrations/migrate_to_v11.dart';
import 'package:valtero/shared/database/schema_version.dart';

void main() {
  test('fresh DB opens at baseline schema v8 with operations tables', () async {
    expect(kAppSchemaVersion, 11);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final expenseId = await db.insertExpense(
      OperationsCompanion.insert(
        kind: 'expense',
        occurredAt: DateTime.utc(2026, 1, 1),
        originalAmountMinor: 100,
        originalCurrencyCode: 'USD',
        storedAmountMinor: 100,
        storedCurrencyCode: 'USD',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );
    final incomeId = await db.insertIncome(
      OperationsCompanion.insert(
        kind: 'income',
        occurredAt: DateTime.utc(2026, 1, 2),
        originalAmountMinor: 200,
        originalCurrencyCode: 'USD',
        storedAmountMinor: 200,
        storedCurrencyCode: 'USD',
        createdAt: DateTime.utc(2026, 1, 2),
      ),
    );

    final expense = await db.getExpenseById(expenseId);
    final income = await db.getIncomeById(incomeId);
    expect(expense, isNotNull);
    expect(income, isNotNull);
    expect(expense!.kind, 'expense');
    expect(income!.kind, 'income');
    expect(expense.duplicateDismissed, isFalse);
    expect(expense.syncId, isNotEmpty);
    expect(expense.updatedAt, isNotNull);
    expect(expense.deletedAt, isNull);
  });

  test('migrateToV11 adds sync_id updated_at deleted_at and backfills', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    // Simulate pre-v11 operations table (no sync columns).
    await db.customStatement('DROP TABLE IF EXISTS operation_tags');
    await db.customStatement('DROP TABLE IF EXISTS operations');
    await db.customStatement('''
CREATE TABLE operations (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  kind TEXT NOT NULL,
  occurred_at INTEGER NOT NULL,
  original_amount_minor INTEGER NOT NULL,
  original_currency_code TEXT NOT NULL,
  stored_amount_minor INTEGER NOT NULL,
  stored_currency_code TEXT NOT NULL,
  rate_used REAL NULL,
  rate_timestamp INTEGER NULL,
  payment_method_id INTEGER NULL,
  country_code TEXT NULL,
  note TEXT NULL,
  created_at INTEGER NOT NULL,
  duplicate_dismissed INTEGER NOT NULL DEFAULT 0 CHECK (duplicate_dismissed IN (0, 1))
)
''');
    final created = DateTime.utc(2026, 1, 1).microsecondsSinceEpoch;
    await db.customStatement(
      'INSERT INTO operations (kind, occurred_at, original_amount_minor, '
      'original_currency_code, stored_amount_minor, stored_currency_code, '
      'created_at, duplicate_dismissed) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      ['expense', created, 100, 'USD', 100, 'USD', created, 0],
    );

    await migrateToV11(Migrator(db), db);

    final cols = await db.customSelect('PRAGMA table_info(operations)').get();
    final names = cols.map((r) => r.read<String>('name')).toSet();
    expect(names.contains('sync_id'), isTrue);
    expect(names.contains('updated_at'), isTrue);
    expect(names.contains('deleted_at'), isTrue);

    final row = await db.customSelect(
      'SELECT sync_id, updated_at, deleted_at FROM operations WHERE id = 1',
    ).getSingle();
    expect(row.read<String>('sync_id'), isNotEmpty);
    expect(row.read<int>('updated_at'), created);
    expect(row.data['deleted_at'], isNull);
  });

  test('migrateToV10 adds payment_methods.icon_key', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    // Simulate a pre-v10 table (no icon_key), then run the stepwise migrator.
    await db.customStatement('DROP TABLE IF EXISTS payment_methods');
    await db.customStatement('''
CREATE TABLE payment_methods (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  color_value INTEGER NULL,
  is_default INTEGER NOT NULL DEFAULT 0 CHECK (is_default IN (0, 1)),
  sort_order INTEGER NOT NULL DEFAULT 0,
  stable_key TEXT NULL
)
''');

    await migrateToV10(Migrator(db), db);

    final cols =
        await db.customSelect('PRAGMA table_info(payment_methods)').get();
    expect(
      cols.any((row) => row.read<String>('name') == 'icon_key'),
      isTrue,
    );

    final id = await db.insertPaymentMethod(
      PaymentMethodsCompanion.insert(
        name: 'Card',
        stableKey: const Value('card'),
        iconKey: const Value('card'),
      ),
    );
    final row = await db.findPaymentMethodByStableKey('card');
    expect(row?.id, id);
    expect(row?.iconKey, 'card');
  });

  test('opening DB older than baseline refuses without wipe', () async {
    final file = File(
      '${Directory.systemTemp.path}/valtero_schema_baseline_'
      '${DateTime.now().microsecondsSinceEpoch}.sqlite',
    );
    if (await file.exists()) await file.delete();
    addTearDown(() async {
      if (await file.exists()) await file.delete();
    });

    final setupExecutor = NativeDatabase(file);
    await setupExecutor.ensureOpen(_DummyUser());
    await setupExecutor.runCustom('''
CREATE TABLE tags (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL
)
''');
    await setupExecutor.runCustom('PRAGMA user_version = 7');
    await setupExecutor.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(() async {
      try {
        await db.close();
      } catch (_) {}
    });

    await expectLater(
      db.getAllExpenses(),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('older than supported baseline'),
        ),
      ),
    );

    // Refuse path must not delete the DB file.
    expect(await file.exists(), isTrue);
  });
}

class _DummyUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 7;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
