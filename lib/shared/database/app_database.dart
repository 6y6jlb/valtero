import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:valtero/entities/exchange_rate/data/exchange_rates_table.dart';
import 'package:valtero/entities/expense/data/expense_tags_table.dart';
import 'package:valtero/entities/expense/data/expenses_table.dart';
import 'package:valtero/entities/tag/data/tags_table.dart';
import 'package:valtero/shared/database/migrations/migrate_to_v2.dart';
import 'package:valtero/shared/database/migrations/migrate_to_v3.dart';
import 'package:valtero/shared/database/schema_version.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Tags, Expenses, ExpenseTags, ExchangeRates])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => kAppSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) await migrateToV2(m, this);
          if (from < 3) await migrateToV3(m, this);
        },
      );

  Future<List<Tag>> watchTagsList() => select(tags).get();

  Stream<List<Tag>> watchAllTags() {
    return (select(tags)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();
  }

  Future<int> insertTag(TagsCompanion entry) => into(tags).insert(entry);

  Future<bool> updateTagRow(Tag row) => update(tags).replace(row);

  Future<int> deleteTagById(int id) => (delete(tags)..where((t) => t.id.equals(id))).go();

  Future<Tag?> findCountryTag(String countryCode) {
    return (select(tags)
          ..where(
            (t) =>
                t.kind.equals('country') &
                t.countryCode.equals(countryCode.toUpperCase()),
          ))
        .getSingleOrNull();
  }

  Future<Tag?> findByStableKey(String key) {
    return (select(tags)..where((t) => t.stableKey.equals(key))).getSingleOrNull();
  }

  Future<int> ensureTagByStableKey({
    required String stableKey,
    required String fallbackName,
    bool isDefault = false,
    String kind = 'normal',
    int? colorValue,
  }) async {
    final existing = await findByStableKey(stableKey);
    if (existing != null) {
      var updated = existing;
      if (existing.kind != kind) {
        updated = updated.copyWith(kind: kind);
      }
      if (existing.colorValue == null && colorValue != null) {
        updated = updated.copyWith(colorValue: Value(colorValue));
      }
      if (updated != existing) {
        await updateTagRow(updated);
      }
      return existing.id;
    }
    final all = await watchTagsList();
    final nextOrder =
        all.isEmpty ? 0 : all.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    return insertTag(
      TagsCompanion.insert(
        name: fallbackName,
        kind: Value(kind),
        colorValue: Value(colorValue),
        stableKey: Value(stableKey),
        isDefault: Value(isDefault),
        sortOrder: Value(nextOrder),
      ),
    );
  }

  Future<int> ensureCountryTag({
    required String countryCode,
    required String displayName,
  }) async {
    final code = countryCode.toUpperCase();
    final existing = await findCountryTag(code);
    if (existing != null) {
      if (existing.name != displayName) {
        await updateTagRow(existing.copyWith(name: displayName));
      }
      return existing.id;
    }
    final all = await watchTagsList();
    final nextOrder =
        all.isEmpty ? 0 : all.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    return insertTag(
      TagsCompanion.insert(
        name: displayName,
        kind: const Value('country'),
        countryCode: Value(code),
        stableKey: Value('country_$code'),
        isDefault: const Value(true),
        sortOrder: Value(nextOrder),
      ),
    );
  }

  Stream<List<Expense>> watchExpenses({
    int? tagId,
    String? currencyCode,
    DateTime? from,
    DateTime? to,
  }) {
    if (tagId != null) {
      final query = select(expenses).join([
        innerJoin(
          expenseTags,
          expenseTags.expenseId.equalsExp(expenses.id),
        ),
      ])
        ..where(expenseTags.tagId.equals(tagId))
        ..orderBy([OrderingTerm.desc(expenses.occurredAt)]);
      if (currencyCode != null && currencyCode.isNotEmpty) {
        query.where(expenses.storedCurrencyCode.equals(currencyCode));
      }
      if (from != null) {
        query.where(expenses.occurredAt.isBiggerOrEqualValue(from));
      }
      if (to != null) {
        query.where(expenses.occurredAt.isSmallerOrEqualValue(to));
      }
      return query.watch().map((rows) => rows.map((r) => r.readTable(expenses)).toList());
    }

    final query = select(expenses)..orderBy([(e) => OrderingTerm.desc(e.occurredAt)]);
    if (currencyCode != null && currencyCode.isNotEmpty) {
      query.where((e) => e.storedCurrencyCode.equals(currencyCode));
    }
    if (from != null) {
      query.where((e) => e.occurredAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((e) => e.occurredAt.isSmallerOrEqualValue(to));
    }
    return query.watch();
  }

  Future<List<Expense>> getAllExpenses() {
    return (select(expenses)..orderBy([(e) => OrderingTerm.desc(e.occurredAt)])).get();
  }

  Future<int> insertExpense(ExpensesCompanion entry) => into(expenses).insert(entry);

  Future<void> setExpenseTags(int expenseId, List<int> tagIds) async {
    await (delete(expenseTags)..where((et) => et.expenseId.equals(expenseId))).go();
    for (final tagId in tagIds.toSet()) {
      await into(expenseTags).insert(
        ExpenseTagsCompanion.insert(expenseId: expenseId, tagId: tagId),
      );
    }
  }

  Future<List<int>> getTagIdsForExpense(int expenseId) async {
    final rows = await (select(expenseTags)
          ..where((et) => et.expenseId.equals(expenseId)))
        .get();
    return rows.map((r) => r.tagId).toList();
  }

  Future<Map<int, List<int>>> getTagIdsByExpenseIds(List<int> expenseIds) async {
    if (expenseIds.isEmpty) return {};
    final rows = await (select(expenseTags)
          ..where((et) => et.expenseId.isIn(expenseIds)))
        .get();
    final map = <int, List<int>>{};
    for (final row in rows) {
      map.putIfAbsent(row.expenseId, () => []).add(row.tagId);
    }
    return map;
  }

  Future<bool> updateExpenseRow(Expense row) => update(expenses).replace(row);

  Future<int> deleteExpenseById(int id) async {
    await (delete(expenseTags)..where((et) => et.expenseId.equals(id))).go();
    return (delete(expenses)..where((e) => e.id.equals(id))).go();
  }

  Future<Expense?> getExpenseById(int id) {
    return (select(expenses)..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  Future<ExchangeRate?> getRateRow({
    required String base,
    required String target,
    required String source,
  }) {
    return (select(exchangeRates)
          ..where(
            (r) =>
                r.baseCurrencyCode.equals(base) &
                r.targetCurrencyCode.equals(target) &
                r.source.equals(source),
          ))
        .getSingleOrNull();
  }

  Future<List<ExchangeRate>> getRatesForPair(String base, String target) {
    return (select(exchangeRates)
          ..where(
            (r) =>
                r.baseCurrencyCode.equals(base) &
                r.targetCurrencyCode.equals(target),
          ))
        .get();
  }

  Stream<List<ExchangeRate>> watchAllExchangeRates() {
    return (select(exchangeRates)
          ..orderBy([
            (r) => OrderingTerm.asc(r.baseCurrencyCode),
            (r) => OrderingTerm.asc(r.targetCurrencyCode),
            (r) => OrderingTerm.asc(r.source),
          ]))
        .watch();
  }

  Future<List<ExchangeRate>> getAllExchangeRates() {
    return (select(exchangeRates)
          ..orderBy([
            (r) => OrderingTerm.asc(r.baseCurrencyCode),
            (r) => OrderingTerm.asc(r.targetCurrencyCode),
            (r) => OrderingTerm.asc(r.source),
          ]))
        .get();
  }

  Future<void> upsertRate({
    required String base,
    required String target,
    required String source,
    required double rate,
    required DateTime fetchedAt,
  }) async {
    final existing = await getRateRow(base: base, target: target, source: source);
    if (existing == null) {
      await into(exchangeRates).insert(
        ExchangeRatesCompanion.insert(
          baseCurrencyCode: base,
          targetCurrencyCode: target,
          source: source,
          rate: rate,
          fetchedAt: fetchedAt,
        ),
      );
    } else {
      await (update(exchangeRates)..where((r) => r.id.equals(existing.id))).write(
        ExchangeRatesCompanion(
          rate: Value(rate),
          fetchedAt: Value(fetchedAt),
        ),
      );
    }
  }

  Future<List<String>> distinctStoredCurrencies() async {
    final rows = await select(expenses).get();
    return rows.map((e) => e.storedCurrencyCode).toSet().toList()..sort();
  }

  Future<List<String>> distinctOriginalCurrencies() async {
    final rows = await select(expenses).get();
    return rows.map((e) => e.originalCurrencyCode).toSet().toList()..sort();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'valtero.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
