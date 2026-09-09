import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/schema_version.dart';

void main() {
  test('schema v7 creates incomes table and tags.iconKey', () async {
    expect(kAppSchemaVersion, 7);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final incomeId = await db.insertIncome(
      IncomesCompanion.insert(
        occurredAt: DateTime.utc(2026, 1, 1),
        originalAmountMinor: 50000,
        originalCurrencyCode: 'USD',
        storedAmountMinor: 50000,
        storedCurrencyCode: 'USD',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );
    final income = await db.getIncomeById(incomeId);
    expect(income, isNotNull);
    expect(income!.duplicateDismissed, isFalse);
    expect(income.originalAmountMinor, 50000);

    final tagId = await db.insertTag(
      TagsCompanion.insert(
        name: 'salary',
        stableKey: const Value('salary'),
        iconKey: const Value('salary'),
      ),
    );
    final tag = (await db.watchTagsList()).firstWhere((t) => t.id == tagId);
    expect(tag.iconKey, 'salary');

    await db.setIncomeTags(incomeId, [tagId]);
    final linked = await db.getTagIdsForIncome(incomeId);
    expect(linked, [tagId]);
  });
}
