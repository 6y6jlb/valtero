import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/schema_version.dart';

void main() {
  test('schema v6 creates expenses.duplicateDismissed defaulting to false',
      () async {
    expect(kAppSchemaVersion, 6);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final id = await db.insertExpense(
      ExpensesCompanion.insert(
        occurredAt: DateTime.utc(2026, 1, 1),
        originalAmountMinor: 100,
        originalCurrencyCode: 'USD',
        storedAmountMinor: 100,
        storedCurrencyCode: 'USD',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );
    final row = await db.getExpenseById(id);
    expect(row, isNotNull);
    expect(row!.duplicateDismissed, isFalse);
  });
}
