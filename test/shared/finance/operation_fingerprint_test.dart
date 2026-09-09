import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/entities/expense/model/duplicate_matcher.dart';
import 'package:valtero/shared/finance/operation_fingerprint.dart';

void main() {
  group('OperationFingerprint', () {
    test('same day amount currency match', () {
      final a = fingerprintOf(
        occurredAt: DateTime(2026, 3, 15, 10),
        originalAmountMinor: 1000,
        originalCurrencyCode: 'usd',
      );
      final b = fingerprintOf(
        occurredAt: DateTime(2026, 3, 15, 22),
        originalAmountMinor: 1000,
        originalCurrencyCode: 'USD',
      );
      expect(a, b);
      expect(a, isA<OperationFingerprint>());
      expect(a, isA<ExpenseFingerprint>());
    });

    test('different day does not match', () {
      final a = fingerprintOf(
        occurredAt: DateTime(2026, 3, 15),
        originalAmountMinor: 1000,
        originalCurrencyCode: 'USD',
      );
      final b = fingerprintOf(
        occurredAt: DateTime(2026, 3, 16),
        originalAmountMinor: 1000,
        originalCurrencyCode: 'USD',
      );
      expect(a, isNot(b));
    });
  });
}
