import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/utils/money.dart';

/// Batch updates for selected expenses (list multi-select).
class BulkExpenseController {
  final Ref ref;

  BulkExpenseController(this.ref);

  AppDatabase get _db => ref.read(appDatabaseProvider);

  String? _normalizedCountry(String? code) {
    final trimmed = code?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.toUpperCase();
  }

  Future<void> markNotDuplicate(List<int> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      for (final id in ids) {
        final existing = await _db.getExpenseById(id);
        if (existing == null) continue;
        if (existing.duplicateDismissed) continue;
        await _db.updateExpenseRow(
          existing.copyWith(duplicateDismissed: true),
        );
      }
    });
  }

  Future<void> deleteMany(List<int> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      for (final id in ids) {
        await _db.deleteExpenseById(id);
      }
    });
  }

  Future<void> setTags(List<int> ids, List<int> tagIds) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      for (final id in ids) {
        await _db.setExpenseTags(id, tagIds);
      }
    });
  }

  Future<void> setCountry(List<int> ids, String? countryCode) async {
    if (ids.isEmpty) return;
    final normalized = _normalizedCountry(countryCode);
    await _db.transaction(() async {
      for (final id in ids) {
        final existing = await _db.getExpenseById(id);
        if (existing == null) continue;
        await _db.updateExpenseRow(
          existing.copyWith(countryCode: Value(normalized)),
        );
      }
    });
  }

  /// Converts each expense from its original amount into [currencyCode].
  /// Throws [StateError] with `rate_unavailable` if any pair has no rate.
  ///
  /// Rates are resolved **before** the write transaction so network I/O does
  /// not hold the SQLite lock.
  Future<void> convertToCurrency(List<int> ids, String currencyCode) async {
    if (ids.isEmpty) return;
    final target = currencyCode.toUpperCase();
    final resolver = ref.read(rateResolverProvider);

    final expenses = <Expense>[];
    for (final id in ids) {
      final existing = await _db.getExpenseById(id);
      if (existing != null) expenses.add(existing);
    }
    if (expenses.isEmpty) return;

    final ratesByOriginal = <String, double>{};
    for (final expense in expenses) {
      final original = expense.originalCurrencyCode.toUpperCase();
      if (original == target || ratesByOriginal.containsKey(original)) {
        continue;
      }
      final rate = await resolver.getRate(original, target);
      if (rate == null) {
        throw StateError('rate_unavailable');
      }
      ratesByOriginal[original] = rate;
    }

    final now = DateTime.now();
    await _db.transaction(() async {
      for (final existing in expenses) {
        final original = existing.originalCurrencyCode.toUpperCase();
        if (original == target) {
          await _db.updateExpenseRow(
            existing.copyWith(
              storedAmountMinor: existing.originalAmountMinor,
              storedCurrencyCode: target,
              rateUsed: const Value(null),
              rateTimestamp: const Value(null),
            ),
          );
          continue;
        }
        final rate = ratesByOriginal[original]!;
        final storedMinor = Money.convertMinor(
          originalMinor: existing.originalAmountMinor,
          rate: rate,
        );
        await _db.updateExpenseRow(
          existing.copyWith(
            storedAmountMinor: storedMinor,
            storedCurrencyCode: target,
            rateUsed: Value(rate),
            rateTimestamp: Value(now),
          ),
        );
      }
    });
  }
}

final bulkExpenseControllerProvider = Provider<BulkExpenseController>((ref) {
  return BulkExpenseController(ref);
});
