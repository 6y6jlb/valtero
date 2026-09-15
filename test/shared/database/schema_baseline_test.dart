import 'dart:io';

import 'package:drift/drift.dart' show OpeningDetails, QueryExecutor, QueryExecutorUser;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/schema_version.dart';

void main() {
  test('fresh DB opens at baseline schema v8 with operations tables', () async {
    expect(kAppSchemaVersion, 9);
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
