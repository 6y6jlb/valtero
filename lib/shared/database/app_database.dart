import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:valtero/entities/exchange_rate/data/exchange_rates_table.dart';
import 'package:valtero/entities/expense/data/expense_tags_table.dart';
import 'package:valtero/entities/expense/data/expenses_table.dart';
import 'package:valtero/entities/payment_method/data/payment_methods_table.dart';
import 'package:valtero/entities/tag/data/tags_table.dart';
import 'package:valtero/shared/database/migrations/migrate_to_v6.dart';
import 'package:valtero/shared/database/schema_version.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Tags, Expenses, ExpenseTags, ExchangeRates, PaymentMethods],
)
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
          // Production: stepwise migrate_to_vN only — never wipe user data.
          // Baseline schema is v5.
          if (from < 6) await migrateToV6(m, this);
        },
      );

  Future<List<Tag>> watchTagsList() => select(tags).get();

  Stream<List<Tag>> watchAllTags() {
    return (select(tags)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();
  }

  Future<int> insertTag(TagsCompanion entry) => into(tags).insert(entry);

  Future<bool> updateTagRow(Tag row) => update(tags).replace(row);

  Future<int> deleteTagById(int id) => (delete(tags)..where((t) => t.id.equals(id))).go();

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

  Stream<List<PaymentMethod>> watchAllPaymentMethods() {
    return (select(paymentMethods)
          ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
        .watch();
  }

  Future<List<PaymentMethod>> getAllPaymentMethods() {
    return (select(paymentMethods)
          ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
        .get();
  }

  Future<PaymentMethod?> findPaymentMethodByStableKey(String key) {
    return (select(paymentMethods)..where((p) => p.stableKey.equals(key)))
        .getSingleOrNull();
  }

  Future<int> insertPaymentMethod(PaymentMethodsCompanion entry) =>
      into(paymentMethods).insert(entry);

  Future<bool> updatePaymentMethodRow(PaymentMethod row) =>
      update(paymentMethods).replace(row);

  Future<int> deletePaymentMethodById(int id) async {
    await (update(expenses)..where((e) => e.paymentMethodId.equals(id))).write(
      const ExpensesCompanion(paymentMethodId: Value(null)),
    );
    return (delete(paymentMethods)..where((p) => p.id.equals(id))).go();
  }

  Future<int> ensurePaymentMethodByStableKey({
    required String stableKey,
    required String fallbackName,
    bool isDefault = false,
    int? colorValue,
  }) async {
    final existing = await findPaymentMethodByStableKey(stableKey);
    if (existing != null) {
      var updated = existing;
      if (existing.colorValue == null && colorValue != null) {
        updated = updated.copyWith(colorValue: Value(colorValue));
      }
      if (updated != existing) {
        await updatePaymentMethodRow(updated);
      }
      return existing.id;
    }
    final all = await getAllPaymentMethods();
    final nextOrder =
        all.isEmpty ? 0 : all.map((p) => p.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    return insertPaymentMethod(
      PaymentMethodsCompanion.insert(
        name: fallbackName,
        colorValue: Value(colorValue),
        stableKey: Value(stableKey),
        isDefault: Value(isDefault),
        sortOrder: Value(nextOrder),
      ),
    );
  }

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

  Stream<Map<int, List<int>>> watchAllExpenseTagIds() {
    return select(expenseTags).watch().map((rows) {
      final map = <int, List<int>>{};
      for (final row in rows) {
        map.putIfAbsent(row.expenseId, () => []).add(row.tagId);
      }
      return map;
    });
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

  Future<List<ExchangeRate>> getManualExchangeRates() {
    return (select(exchangeRates)
          ..where((r) => r.source.equals('manual'))
          ..orderBy([
            (r) => OrderingTerm.asc(r.baseCurrencyCode),
            (r) => OrderingTerm.asc(r.targetCurrencyCode),
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
