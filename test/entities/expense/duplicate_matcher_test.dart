import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/entities/expense/model/duplicate_matcher.dart';
import 'package:valtero/shared/database/app_database.dart';

Expense _expense({
  required int id,
  required DateTime occurredAt,
  required int originalAmountMinor,
  required String originalCurrencyCode,
  bool duplicateDismissed = false,
}) {
  return Expense(
    id: id,
    occurredAt: occurredAt,
    originalAmountMinor: originalAmountMinor,
    originalCurrencyCode: originalCurrencyCode,
    storedAmountMinor: originalAmountMinor,
    storedCurrencyCode: originalCurrencyCode,
    rateUsed: null,
    rateTimestamp: null,
    tagId: null,
    paymentMethodId: null,
    countryCode: null,
    note: null,
    createdAt: occurredAt,
    duplicateDismissed: duplicateDismissed,
  );
}

void main() {
  group('fingerprintOf', () {
    test('normalizes currency and strips time-of-day', () {
      final a = fingerprintOf(
        occurredAt: DateTime(2026, 3, 15, 9, 30),
        originalAmountMinor: 1500,
        originalCurrencyCode: 'usd',
      );
      final b = fingerprintOf(
        occurredAt: DateTime(2026, 3, 15, 23, 59),
        originalAmountMinor: 1500,
        originalCurrencyCode: 'USD',
      );
      expect(a, b);
    });

    test('differs when day, amount, or currency changes', () {
      final base = fingerprintOf(
        occurredAt: DateTime(2026, 3, 15),
        originalAmountMinor: 1500,
        originalCurrencyCode: 'USD',
      );
      expect(
        base ==
            fingerprintOf(
              occurredAt: DateTime(2026, 3, 16),
              originalAmountMinor: 1500,
              originalCurrencyCode: 'USD',
            ),
        isFalse,
      );
      expect(
        base ==
            fingerprintOf(
              occurredAt: DateTime(2026, 3, 15),
              originalAmountMinor: 1501,
              originalCurrencyCode: 'USD',
            ),
        isFalse,
      );
      expect(
        base ==
            fingerprintOf(
              occurredAt: DateTime(2026, 3, 15),
              originalAmountMinor: 1500,
              originalCurrencyCode: 'EUR',
            ),
        isFalse,
      );
    });
  });

  group('groupPotentialDuplicates', () {
    test('groups matching fingerprints and skips dismissed', () {
      final day = DateTime(2026, 4, 1, 12);
      final expenses = [
        _expense(
          id: 1,
          occurredAt: day,
          originalAmountMinor: 100,
          originalCurrencyCode: 'RUB',
        ),
        _expense(
          id: 2,
          occurredAt: DateTime(2026, 4, 1, 18),
          originalAmountMinor: 100,
          originalCurrencyCode: 'RUB',
        ),
        _expense(
          id: 3,
          occurredAt: day,
          originalAmountMinor: 100,
          originalCurrencyCode: 'RUB',
          duplicateDismissed: true,
        ),
        _expense(
          id: 4,
          occurredAt: day,
          originalAmountMinor: 200,
          originalCurrencyCode: 'RUB',
        ),
      ];
      final groups = groupPotentialDuplicates(expenses);
      expect(groups, hasLength(1));
      expect(groups.first.toSet(), {1, 2});
    });
  });

  group('findMatches', () {
    test('excludes self and dismissed rows', () {
      final day = DateTime(2026, 5, 1);
      final pool = [
        _expense(
          id: 10,
          occurredAt: day,
          originalAmountMinor: 50,
          originalCurrencyCode: 'EUR',
        ),
        _expense(
          id: 11,
          occurredAt: day,
          originalAmountMinor: 50,
          originalCurrencyCode: 'EUR',
          duplicateDismissed: true,
        ),
        _expense(
          id: 12,
          occurredAt: day,
          originalAmountMinor: 50,
          originalCurrencyCode: 'EUR',
        ),
      ];
      final matches = findMatches(
        pool: pool,
        fingerprint: fingerprintOf(
          occurredAt: day,
          originalAmountMinor: 50,
          originalCurrencyCode: 'EUR',
        ),
        excludeId: 10,
      );
      expect(matches.map((e) => e.id), [12]);
    });
  });
}
