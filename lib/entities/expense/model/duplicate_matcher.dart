import 'package:valtero/shared/database/app_database.dart';

/// Calendar-day + original amount/currency identity used for soft duplicate
/// detection (same day, same original minor units, same original currency).
class ExpenseFingerprint {
  final DateTime day;
  final int originalAmountMinor;
  final String originalCurrencyCode;

  const ExpenseFingerprint({
    required this.day,
    required this.originalAmountMinor,
    required this.originalCurrencyCode,
  });

  @override
  bool operator ==(Object other) {
    return other is ExpenseFingerprint &&
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

ExpenseFingerprint fingerprintOf({
  required DateTime occurredAt,
  required int originalAmountMinor,
  required String originalCurrencyCode,
}) {
  return ExpenseFingerprint(
    day: DateTime(occurredAt.year, occurredAt.month, occurredAt.day),
    originalAmountMinor: originalAmountMinor,
    originalCurrencyCode: originalCurrencyCode.toUpperCase(),
  );
}

ExpenseFingerprint fingerprintOfExpense(Expense expense) {
  return fingerprintOf(
    occurredAt: expense.occurredAt,
    originalAmountMinor: expense.originalAmountMinor,
    originalCurrencyCode: expense.originalCurrencyCode,
  );
}

/// Indexes expenses that are still candidates for duplicate matching
/// (skips rows the user already marked as not-a-duplicate).
Map<ExpenseFingerprint, List<Expense>> indexByFingerprint(
  List<Expense> expenses,
) {
  final map = <ExpenseFingerprint, List<Expense>>{};
  for (final expense in expenses) {
    if (expense.duplicateDismissed) continue;
    final key = fingerprintOfExpense(expense);
    map.putIfAbsent(key, () => []).add(expense);
  }
  return map;
}

/// Returns only groups with 2+ expenses sharing a fingerprint.
List<List<int>> groupPotentialDuplicates(List<Expense> expenses) {
  final indexed = indexByFingerprint(expenses);
  final groups = <List<int>>[];
  for (final entries in indexed.values) {
    if (entries.length < 2) continue;
    groups.add(entries.map((e) => e.id).toList());
  }
  return groups;
}

/// Finds pool expenses matching [fingerprint], skipping dismissed rows and
/// optionally excluding [excludeId] (the expense being edited).
List<Expense> findMatches({
  required List<Expense> pool,
  required ExpenseFingerprint fingerprint,
  int? excludeId,
}) {
  return pool.where((expense) {
    if (expense.duplicateDismissed) return false;
    if (excludeId != null && expense.id == excludeId) return false;
    return fingerprintOfExpense(expense) == fingerprint;
  }).toList();
}
