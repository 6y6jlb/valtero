import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/expense/model/duplicate_matcher.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/utils/money.dart';

class AddExpenseInput {
  final int originalAmountMinor;
  final String originalCurrencyCode;
  final bool convert;
  final String? targetCurrencyCode;
  final List<int> tagIds;
  final int? paymentMethodId;
  final String? countryCode;
  final String? note;
  final DateTime occurredAt;

  const AddExpenseInput({
    required this.originalAmountMinor,
    required this.originalCurrencyCode,
    required this.convert,
    this.targetCurrencyCode,
    this.tagIds = const [],
    this.paymentMethodId,
    this.countryCode,
    this.note,
    required this.occurredAt,
  });
}

class AddExpenseController {
  final Ref ref;

  AddExpenseController(this.ref);

  Future<double?> previewRate(String from, String to) {
    return ref.read(rateResolverProvider).getRate(from, to);
  }

  Future<({int storedMinor, String storedCurrency, double? rateUsed, DateTime? rateTimestamp})>
      _resolveStored(AddExpenseInput input) async {
    final original = input.originalCurrencyCode.toUpperCase();
    var storedMinor = input.originalAmountMinor;
    var storedCurrency = original;
    double? rateUsed;
    DateTime? rateTimestamp;

    if (input.convert &&
        input.targetCurrencyCode != null &&
        input.targetCurrencyCode!.toUpperCase() != original) {
      final target = input.targetCurrencyCode!.toUpperCase();
      final rate =
          await ref.read(rateResolverProvider).getRate(original, target);
      if (rate == null) {
        throw StateError('rate_unavailable');
      }
      storedMinor = Money.convertMinor(
        originalMinor: input.originalAmountMinor,
        rate: rate,
      );
      storedCurrency = target;
      rateUsed = rate;
      rateTimestamp = DateTime.now();
    }

    return (
      storedMinor: storedMinor,
      storedCurrency: storedCurrency,
      rateUsed: rateUsed,
      rateTimestamp: rateTimestamp,
    );
  }

  String? _normalizedCountry(String? code) {
    final trimmed = code?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.toUpperCase();
  }

  Future<List<Expense>> findPotentialDuplicates(
    AddExpenseInput input, {
    int? excludeId,
  }) async {
    final pool = await ref.read(appDatabaseProvider).getAllExpenses();
    final key = fingerprintOf(
      occurredAt: input.occurredAt,
      originalAmountMinor: input.originalAmountMinor,
      originalCurrencyCode: input.originalCurrencyCode,
    );
    return findMatches(pool: pool, fingerprint: key, excludeId: excludeId);
  }

  Future<int> save(
    AddExpenseInput input, {
    bool markUnique = false,
  }) async {
    final db = ref.read(appDatabaseProvider);
    final resolved = await _resolveStored(input);
    final original = input.originalCurrencyCode.toUpperCase();

    final id = await db.insertExpense(
      ExpensesCompanion.insert(
        occurredAt: input.occurredAt,
        originalAmountMinor: input.originalAmountMinor,
        originalCurrencyCode: original,
        storedAmountMinor: resolved.storedMinor,
        storedCurrencyCode: resolved.storedCurrency,
        rateUsed: Value(resolved.rateUsed),
        rateTimestamp: Value(resolved.rateTimestamp),
        paymentMethodId: Value(input.paymentMethodId),
        countryCode: Value(_normalizedCountry(input.countryCode)),
        note: Value(
          input.note?.trim().isEmpty == true ? null : input.note?.trim(),
        ),
        createdAt: DateTime.now(),
        duplicateDismissed: Value(markUnique),
      ),
    );
    await db.setExpenseTags(id, input.tagIds);
    return id;
  }

  Future<void> update(
    int id,
    AddExpenseInput input, {
    bool markUnique = false,
  }) async {
    final db = ref.read(appDatabaseProvider);
    final existing = await db.getExpenseById(id);
    if (existing == null) {
      throw StateError('expense_not_found');
    }
    final resolved = await _resolveStored(input);
    final original = input.originalCurrencyCode.toUpperCase();

    final oldKey = fingerprintOfExpense(existing);
    final newKey = fingerprintOf(
      occurredAt: input.occurredAt,
      originalAmountMinor: input.originalAmountMinor,
      originalCurrencyCode: original,
    );
    final fingerprintChanged = oldKey != newKey;

    var dismissed = existing.duplicateDismissed;
    if (markUnique) {
      dismissed = true;
    } else if (fingerprintChanged) {
      dismissed = false;
    }

    await db.updateExpenseRow(
      existing.copyWith(
        occurredAt: input.occurredAt,
        originalAmountMinor: input.originalAmountMinor,
        originalCurrencyCode: original,
        storedAmountMinor: resolved.storedMinor,
        storedCurrencyCode: resolved.storedCurrency,
        rateUsed: Value(resolved.rateUsed),
        rateTimestamp: Value(resolved.rateTimestamp),
        paymentMethodId: Value(input.paymentMethodId),
        countryCode: Value(_normalizedCountry(input.countryCode)),
        note: Value(
          input.note?.trim().isEmpty == true ? null : input.note?.trim(),
        ),
        duplicateDismissed: dismissed,
      ),
    );
    await db.setExpenseTags(id, input.tagIds);
  }

  Future<void> delete(int id) {
    return ref.read(appDatabaseProvider).deleteExpenseById(id);
  }

  Future<void> deleteMany(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = ref.read(appDatabaseProvider);
    await db.transaction(() async {
      for (final id in ids) {
        await db.deleteExpenseById(id);
      }
    });
  }
}

final addExpenseControllerProvider = Provider<AddExpenseController>((ref) {
  return AddExpenseController(ref);
});
