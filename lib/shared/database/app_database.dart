import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:valtero/entities/exchange_rate/data/exchange_rates_table.dart';
import 'package:valtero/entities/operation/data/operation_tags_table.dart';
import 'package:valtero/entities/operation/data/operations_table.dart';
import 'package:valtero/entities/operation/model/operation_kind.dart';
import 'package:valtero/entities/payment_method/data/payment_methods_table.dart';
import 'package:valtero/entities/tag/data/tags_table.dart';
import 'package:valtero/shared/database/schema_version.dart';

part 'app_database.g.dart';

/// Drift row aliases after schema v8 (single [Operations] table).
typedef Expense = Operation;
typedef Income = Operation;

@DriftDatabase(
  tables: [
    Tags,
    Operations,
    OperationTags,
    ExchangeRates,
    PaymentMethods,
  ],
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
          // Baseline is v8. Pre-baseline DBs are refused — never wipe.
          // Future bumps: stepwise migrate_to_vN only (v9+).
          if (from < kAppSchemaVersion) {
            throw StateError(
              'Database schema $from is older than supported baseline '
              '$kAppSchemaVersion. Restore from a backup created with the '
              'current app, or open once with the last pre-1.0 build to '
              'upgrade in place before installing this version.',
            );
          }
        },
      );

  Future<List<Tag>> watchTagsList() => select(tags).get();

  Stream<List<Tag>> watchAllTags() {
    return (select(tags)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();
  }

  Future<int> insertTag(TagsCompanion entry) => into(tags).insert(entry);

  Future<bool> updateTagRow(Tag row) => update(tags).replace(row);

  Future<int> deleteTagById(int id) =>
      (delete(tags)..where((t) => t.id.equals(id))).go();

  Future<Tag?> findByStableKey(String key) {
    return (select(tags)..where((t) => t.stableKey.equals(key))).getSingleOrNull();
  }

  Future<int> ensureTagByStableKey({
    required String stableKey,
    required String fallbackName,
    bool isDefault = false,
    String kind = 'normal',
    int? colorValue,
    String? iconKey,
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
      if (existing.iconKey == null && iconKey != null) {
        updated = updated.copyWith(iconKey: Value(iconKey));
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
        iconKey: Value(iconKey),
        isDefault: Value(isDefault),
        sortOrder: Value(nextOrder),
      ),
    );
  }

  Stream<List<Operation>> watchOperations({
    OperationKind? kind,
    int? tagId,
    String? currencyCode,
    DateTime? from,
    DateTime? to,
  }) {
    final kindDb = kind == null ? null : operationKindDbValue(kind);
    if (tagId != null) {
      final query = select(operations).join([
        innerJoin(
          operationTags,
          operationTags.operationId.equalsExp(operations.id),
        ),
      ])
        ..where(operationTags.tagId.equals(tagId))
        ..orderBy([OrderingTerm.desc(operations.occurredAt)]);
      if (kindDb != null) {
        query.where(operations.kind.equals(kindDb));
      }
      if (currencyCode != null && currencyCode.isNotEmpty) {
        query.where(operations.storedCurrencyCode.equals(currencyCode));
      }
      if (from != null) {
        query.where(operations.occurredAt.isBiggerOrEqualValue(from));
      }
      if (to != null) {
        query.where(operations.occurredAt.isSmallerOrEqualValue(to));
      }
      return query
          .watch()
          .map((rows) => rows.map((r) => r.readTable(operations)).toList());
    }

    final query =
        select(operations)..orderBy([(e) => OrderingTerm.desc(e.occurredAt)]);
    if (kindDb != null) {
      query.where((e) => e.kind.equals(kindDb));
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

  Future<List<Operation>> getAllOperations({OperationKind? kind}) {
    final query =
        select(operations)..orderBy([(e) => OrderingTerm.desc(e.occurredAt)]);
    if (kind != null) {
      query.where((e) => e.kind.equals(operationKindDbValue(kind)));
    }
    return query.get();
  }

  Future<int> insertOperation(OperationsCompanion entry) =>
      into(operations).insert(entry);

  Future<bool> updateOperationRow(Operation row) =>
      update(operations).replace(row);

  Future<int> deleteOperationById(int id) async {
    await (delete(operationTags)..where((ot) => ot.operationId.equals(id))).go();
    return (delete(operations)..where((e) => e.id.equals(id))).go();
  }

  Future<Operation?> getOperationById(int id) {
    return (select(operations)..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  Future<void> setOperationTags(int operationId, List<int> tagIds) async {
    var ids = tagIds.toSet().toList();
    final op = await getOperationById(operationId);
    if (op != null && ids.isNotEmpty) {
      final expectedKind =
          tagKindDbValueForOperation(operationKindOf(op.kind));
      final tagRows = await (select(tags)..where((t) => t.id.isIn(ids))).get();
      ids = [
        for (final tag in tagRows)
          if (tag.kind == expectedKind) tag.id,
      ];
    }
    await (delete(operationTags)..where((ot) => ot.operationId.equals(operationId)))
        .go();
    for (final tagId in ids) {
      await into(operationTags).insert(
        OperationTagsCompanion.insert(operationId: operationId, tagId: tagId),
      );
    }
  }

  Future<List<int>> getTagIdsForOperation(int operationId) async {
    final rows = await (select(operationTags)
          ..where((ot) => ot.operationId.equals(operationId)))
        .get();
    return rows.map((r) => r.tagId).toList();
  }

  Future<Map<int, List<int>>> getTagIdsByOperationIds(
    List<int> operationIds,
  ) async {
    if (operationIds.isEmpty) return {};
    final rows = await (select(operationTags)
          ..where((ot) => ot.operationId.isIn(operationIds)))
        .get();
    final map = <int, List<int>>{};
    for (final row in rows) {
      map.putIfAbsent(row.operationId, () => []).add(row.tagId);
    }
    return map;
  }

  Stream<Map<int, List<int>>> watchAllOperationTagIds({OperationKind? kind}) {
    if (kind == null) {
      return select(operationTags).watch().map((rows) {
        final map = <int, List<int>>{};
        for (final row in rows) {
          map.putIfAbsent(row.operationId, () => []).add(row.tagId);
        }
        return map;
      });
    }
    final kindDb = operationKindDbValue(kind);
    final query = select(operationTags).join([
      innerJoin(
        operations,
        operations.id.equalsExp(operationTags.operationId),
      ),
    ])
      ..where(operations.kind.equals(kindDb));
    return query.watch().map((rows) {
      final map = <int, List<int>>{};
      for (final row in rows) {
        final link = row.readTable(operationTags);
        map.putIfAbsent(link.operationId, () => []).add(link.tagId);
      }
      return map;
    });
  }

  // --- Direction-specific wrappers (call sites still say expense/income) ---

  Stream<List<Operation>> watchExpenses({
    int? tagId,
    String? currencyCode,
    DateTime? from,
    DateTime? to,
  }) =>
      watchOperations(
        kind: OperationKind.expense,
        tagId: tagId,
        currencyCode: currencyCode,
        from: from,
        to: to,
      );

  Future<List<Operation>> getAllExpenses() =>
      getAllOperations(kind: OperationKind.expense);

  Future<int> insertExpense(OperationsCompanion entry) {
    return insertOperation(
      entry.copyWith(kind: const Value('expense')),
    );
  }

  Future<bool> updateExpenseRow(Operation row) => updateOperationRow(
        row.copyWith(kind: 'expense'),
      );

  Future<int> deleteExpenseById(int id) => deleteOperationById(id);

  Future<Operation?> getExpenseById(int id) async {
    final row = await getOperationById(id);
    if (row == null || row.kind != 'expense') return null;
    return row;
  }

  Future<void> setExpenseTags(int expenseId, List<int> tagIds) =>
      setOperationTags(expenseId, tagIds);

  Future<List<int>> getTagIdsForExpense(int expenseId) =>
      getTagIdsForOperation(expenseId);

  Future<Map<int, List<int>>> getTagIdsByExpenseIds(List<int> expenseIds) =>
      getTagIdsByOperationIds(expenseIds);

  Stream<Map<int, List<int>>> watchAllExpenseTagIds() =>
      watchAllOperationTagIds(kind: OperationKind.expense);

  Stream<List<Operation>> watchIncome({
    int? tagId,
    String? currencyCode,
    DateTime? from,
    DateTime? to,
  }) =>
      watchOperations(
        kind: OperationKind.income,
        tagId: tagId,
        currencyCode: currencyCode,
        from: from,
        to: to,
      );

  Future<List<Operation>> getAllIncome() =>
      getAllOperations(kind: OperationKind.income);

  Future<int> insertIncome(OperationsCompanion entry) {
    return insertOperation(
      entry.copyWith(kind: const Value('income')),
    );
  }

  Future<bool> updateIncomeRow(Operation row) => updateOperationRow(
        row.copyWith(kind: 'income'),
      );

  Future<int> deleteIncomeById(int id) => deleteOperationById(id);

  Future<Operation?> getIncomeById(int id) async {
    final row = await getOperationById(id);
    if (row == null || row.kind != 'income') return null;
    return row;
  }

  Future<void> setIncomeTags(int incomeId, List<int> tagIds) =>
      setOperationTags(incomeId, tagIds);

  Future<List<int>> getTagIdsForIncome(int incomeId) =>
      getTagIdsForOperation(incomeId);

  Future<Map<int, List<int>>> getTagIdsByIncomeIds(List<int> incomeIds) =>
      getTagIdsByOperationIds(incomeIds);

  Stream<Map<int, List<int>>> watchAllIncomeTagIds() =>
      watchAllOperationTagIds(kind: OperationKind.income);

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
    await (update(operations)..where((e) => e.paymentMethodId.equals(id)))
        .write(
      const OperationsCompanion(paymentMethodId: Value(null)),
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

  /// Like [upsertRate], but keeps the local row when it is strictly newer.
  Future<bool> upsertRateIfNewer({
    required String base,
    required String target,
    required String source,
    required double rate,
    required DateTime fetchedAt,
  }) async {
    final existing =
        await getRateRow(base: base, target: target, source: source);
    if (existing != null && !fetchedAt.isAfter(existing.fetchedAt)) {
      return false;
    }
    await upsertRate(
      base: base,
      target: target,
      source: source,
      rate: rate,
      fetchedAt: fetchedAt,
    );
    return true;
  }

  Future<List<String>> distinctStoredCurrencies({OperationKind? kind}) async {
    final rows = await getAllOperations(kind: kind);
    return rows.map((e) => e.storedCurrencyCode).toSet().toList()..sort();
  }

  Future<List<String>> distinctOriginalCurrencies({OperationKind? kind}) async {
    final rows = await getAllOperations(kind: kind);
    return rows.map((e) => e.originalCurrencyCode).toSet().toList()..sort();
  }

  Future<List<String>> distinctStoredIncomeCurrencies() =>
      distinctStoredCurrencies(kind: OperationKind.income);

  Future<List<String>> distinctOriginalIncomeCurrencies() =>
      distinctOriginalCurrencies(kind: OperationKind.income);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'valtero.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
