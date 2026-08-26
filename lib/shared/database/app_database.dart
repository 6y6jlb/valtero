import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:valtero/entities/exchange_rate/data/exchange_rates_table.dart';
import 'package:valtero/entities/expense/data/expenses_table.dart';
import 'package:valtero/entities/tag/data/tags_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Tags, Expenses, ExchangeRates])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
      );

  Future<List<Tag>> watchTagsList() => select(tags).get();

  Stream<List<Tag>> watchAllTags() {
    return (select(tags)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();
  }

  Future<int> insertTag(TagsCompanion entry) => into(tags).insert(entry);

  Future<bool> updateTagRow(Tag row) => update(tags).replace(row);

  Future<int> deleteTagById(int id) => (delete(tags)..where((t) => t.id.equals(id))).go();

  Stream<List<Expense>> watchExpenses({
    int? tagId,
    String? currencyCode,
    DateTime? from,
    DateTime? to,
  }) {
    final query = select(expenses)
      ..orderBy([(e) => OrderingTerm.desc(e.occurredAt)]);
    if (tagId != null) {
      query.where((e) => e.tagId.equals(tagId));
    }
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

  Future<bool> updateExpenseRow(Expense row) => update(expenses).replace(row);

  Future<int> deleteExpenseById(int id) =>
      (delete(expenses)..where((e) => e.id.equals(id))).go();

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
