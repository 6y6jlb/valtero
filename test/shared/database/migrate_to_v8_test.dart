import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/schema_version.dart';

void main() {
  test('migrate v7→v8 merges expense/income rows and tag links', () async {
    expect(kAppSchemaVersion, 8);

    final file = File(
      '${Directory.systemTemp.path}/valtero_migrate_v8_'
      '${DateTime.now().microsecondsSinceEpoch}.sqlite',
    );
    if (await file.exists()) await file.delete();
    addTearDown(() async {
      if (await file.exists()) await file.delete();
    });

    final setupExecutor = NativeDatabase(file);
    final setup = _RawDb(setupExecutor);
    await setup.createV7Schema();
    await setup.seedV7Rows();
    await setup.customStatement('PRAGMA user_version = 7');
    await setup.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final expenses = await db.getAllExpenses();
    final incomes = await db.getAllIncome();
    expect(expenses, hasLength(1));
    expect(incomes, hasLength(1));
    expect(expenses.first.originalAmountMinor, 100);
    expect(incomes.first.originalAmountMinor, 200);
    // Income id was offset by max(expense id)=1 → operation id 2.
    expect(incomes.first.id, 2);

    final expenseTags = await db.getTagIdsForExpense(expenses.first.id);
    final incomeTags = await db.getTagIdsForIncome(incomes.first.id);
    expect(expenseTags, [1]); // from legacy tag_id
    expect(incomeTags, [2]);
  });
}

class _RawDb {
  _RawDb(this._executor);

  final QueryExecutor _executor;
  bool _opened = false;

  Future<void> _ensureOpen() async {
    if (_opened) return;
    await _executor.ensureOpen(_DummyUser());
    _opened = true;
  }

  Future<void> customStatement(String sql, [List<Object?>? args]) async {
    await _ensureOpen();
    await _executor.runCustom(sql, args ?? const []);
  }

  Future<void> close() => _executor.close();

  Future<void> createV7Schema() async {
    await customStatement('''
CREATE TABLE tags (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  color_value INTEGER NULL,
  is_default INTEGER NOT NULL DEFAULT 0,
  sort_order INTEGER NOT NULL DEFAULT 0,
  kind TEXT NOT NULL DEFAULT 'normal',
  country_code TEXT NULL,
  stable_key TEXT NULL,
  icon_key TEXT NULL
)
''');
    await customStatement('''
CREATE TABLE payment_methods (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  color_value INTEGER NULL,
  is_default INTEGER NOT NULL DEFAULT 0,
  sort_order INTEGER NOT NULL DEFAULT 0,
  stable_key TEXT NULL
)
''');
    await customStatement('''
CREATE TABLE expenses (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  occurred_at INTEGER NOT NULL,
  original_amount_minor INTEGER NOT NULL,
  original_currency_code TEXT NOT NULL,
  stored_amount_minor INTEGER NOT NULL,
  stored_currency_code TEXT NOT NULL,
  rate_used REAL NULL,
  rate_timestamp INTEGER NULL,
  tag_id INTEGER NULL REFERENCES tags (id),
  payment_method_id INTEGER NULL REFERENCES payment_methods (id),
  country_code TEXT NULL,
  note TEXT NULL,
  created_at INTEGER NOT NULL,
  duplicate_dismissed INTEGER NOT NULL DEFAULT 0
)
''');
    await customStatement('''
CREATE TABLE expense_tags (
  expense_id INTEGER NOT NULL REFERENCES expenses (id) ON DELETE CASCADE,
  tag_id INTEGER NOT NULL REFERENCES tags (id) ON DELETE CASCADE,
  PRIMARY KEY (expense_id, tag_id)
)
''');
    await customStatement('''
CREATE TABLE incomes (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  occurred_at INTEGER NOT NULL,
  original_amount_minor INTEGER NOT NULL,
  original_currency_code TEXT NOT NULL,
  stored_amount_minor INTEGER NOT NULL,
  stored_currency_code TEXT NOT NULL,
  rate_used REAL NULL,
  rate_timestamp INTEGER NULL,
  payment_method_id INTEGER NULL REFERENCES payment_methods (id),
  country_code TEXT NULL,
  note TEXT NULL,
  created_at INTEGER NOT NULL,
  duplicate_dismissed INTEGER NOT NULL DEFAULT 0
)
''');
    await customStatement('''
CREATE TABLE income_tags (
  income_id INTEGER NOT NULL REFERENCES incomes (id) ON DELETE CASCADE,
  tag_id INTEGER NOT NULL REFERENCES tags (id) ON DELETE CASCADE,
  PRIMARY KEY (income_id, tag_id)
)
''');
    await customStatement('''
CREATE TABLE exchange_rates (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  base_currency_code TEXT NOT NULL,
  target_currency_code TEXT NOT NULL,
  source TEXT NOT NULL,
  rate REAL NOT NULL,
  fetched_at INTEGER NOT NULL,
  UNIQUE (base_currency_code, target_currency_code, source)
)
''');
  }

  Future<void> seedV7Rows() async {
    final unixSeconds =
        DateTime.utc(2026, 1, 1).millisecondsSinceEpoch ~/ 1000;

    await customStatement(
      "INSERT INTO tags (id, name, kind, stable_key) VALUES (1, 'food', 'normal', 'groceries')",
    );
    await customStatement(
      "INSERT INTO tags (id, name, kind, stable_key) VALUES (2, 'salary', 'income', 'salary')",
    );
    await customStatement('''
INSERT INTO expenses (
  id, occurred_at, original_amount_minor, original_currency_code,
  stored_amount_minor, stored_currency_code, tag_id, created_at, duplicate_dismissed
) VALUES (1, ?, 100, 'USD', 100, 'USD', 1, ?, 0)
''', [unixSeconds, unixSeconds]);
    await customStatement('''
INSERT INTO incomes (
  id, occurred_at, original_amount_minor, original_currency_code,
  stored_amount_minor, stored_currency_code, created_at, duplicate_dismissed
) VALUES (1, ?, 200, 'USD', 200, 'USD', ?, 0)
''', [unixSeconds, unixSeconds]);
    await customStatement(
      'INSERT INTO income_tags (income_id, tag_id) VALUES (1, 2)',
    );
  }
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
