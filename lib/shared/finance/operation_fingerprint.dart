/// Calendar-day + original amount/currency identity used for soft duplicate
/// detection (same day, same original minor units, same original currency).
class OperationFingerprint {
  final DateTime day;
  final int originalAmountMinor;
  final String originalCurrencyCode;

  const OperationFingerprint({
    required this.day,
    required this.originalAmountMinor,
    required this.originalCurrencyCode,
  });

  @override
  bool operator ==(Object other) {
    return other is OperationFingerprint &&
        other.day.year == day.year &&
        other.day.month == day.month &&
        other.day.day == day.day &&
        other.originalAmountMinor == originalAmountMinor &&
        other.originalCurrencyCode == originalCurrencyCode;
  }

  @override
  int get hashCode => Object.hash(
        day.year,
        day.month,
        day.day,
        originalAmountMinor,
        originalCurrencyCode,
      );
}

OperationFingerprint fingerprintOf({
  required DateTime occurredAt,
  required int originalAmountMinor,
  required String originalCurrencyCode,
}) {
  return OperationFingerprint(
    day: DateTime(occurredAt.year, occurredAt.month, occurredAt.day),
    originalAmountMinor: originalAmountMinor,
    originalCurrencyCode: originalCurrencyCode.toUpperCase(),
  );
}
