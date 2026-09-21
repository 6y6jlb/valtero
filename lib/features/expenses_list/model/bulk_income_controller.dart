import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/utils/money.dart';

/// Batch updates for selected income entries (list multi-select).
class BulkIncomeController {
  final Ref ref;

  BulkIncomeController(this.ref);

  AppDatabase get _db => ref.read(appDatabaseProvider);

  String? _normalizedCountry(String? code) {
    final trimmed = code?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.toUpperCase();
  }

  Future<void> markNotDuplicate(List<int> ids) async {
    if (ids.isEmpty) return;
    final now = DateTime.now();
    await _db.transaction(() async {
      for (final id in ids) {
        final existing = await _db.getIncomeById(id);
        if (existing == null) continue;
        if (existing.duplicateDismissed) continue;
        await _db.updateIncomeRow(
          existing.copyWith(
            duplicateDismissed: true,
            updatedAt: now,
          ),
        );
      }
    });
  }

  Future<void> deleteMany(List<int> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      for (final id in ids) {
        await _db.deleteIncomeById(id);
      }
    });
  }

  Future<void> setTags(List<int> ids, List<int> tagIds) async {
    if (ids.isEmpty) return;
    final now = DateTime.now();
    await _db.transaction(() async {
      for (final id in ids) {
        final existing = await _db.getIncomeById(id);
        if (existing == null) continue;
        await _db.setIncomeTags(id, tagIds);
        await _db.updateIncomeRow(existing.copyWith(updatedAt: now));
      }
    });
  }

  Future<void> setCountry(List<int> ids, String? countryCode) async {
    if (ids.isEmpty) return;
    final normalized = _normalizedCountry(countryCode);
    final now = DateTime.now();
    await _db.transaction(() async {
      for (final id in ids) {
        final existing = await _db.getIncomeById(id);
        if (existing == null) continue;
        await _db.updateIncomeRow(
          existing.copyWith(
            countryCode: Value(normalized),
            updatedAt: now,
          ),
        );
      }
    });
  }

  /// Converts each income from its original amount into [currencyCode].
  /// Throws [StateError] with `rate_unavailable` if any pair has no rate.
  Future<void> convertToCurrency(List<int> ids, String currencyCode) async {
    if (ids.isEmpty) return;
    final target = currencyCode.toUpperCase();
    final resolver = ref.read(rateResolverProvider);

    final incomes = <Income>[];
    for (final id in ids) {
      final existing = await _db.getIncomeById(id);
      if (existing != null) incomes.add(existing);
    }
    if (incomes.isEmpty) return;

    final ratesByOriginal = <String, double>{};
    for (final income in incomes) {
      final original = income.originalCurrencyCode.toUpperCase();
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
      for (final existing in incomes) {
        final original = existing.originalCurrencyCode.toUpperCase();
        if (original == target) {
          await _db.updateIncomeRow(
            existing.copyWith(
              storedAmountMinor: existing.originalAmountMinor,
              storedCurrencyCode: target,
              rateUsed: const Value(null),
              rateTimestamp: const Value(null),
              updatedAt: now,
            ),
          );
          continue;
        }
        final rate = ratesByOriginal[original]!;
        final storedMinor = Money.convertMinor(
          originalMinor: existing.originalAmountMinor,
          rate: rate,
        );
        await _db.updateIncomeRow(
          existing.copyWith(
            storedAmountMinor: storedMinor,
            storedCurrencyCode: target,
            rateUsed: Value(rate),
            rateTimestamp: Value(now),
            updatedAt: now,
          ),
        );
      }
    });
  }
}

final bulkIncomeControllerProvider = Provider<BulkIncomeController>((ref) {
  return BulkIncomeController(ref);
});
