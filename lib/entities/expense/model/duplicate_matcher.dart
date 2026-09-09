import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/finance/operation_fingerprint.dart';

export 'package:valtero/shared/finance/operation_fingerprint.dart'
    show OperationFingerprint, fingerprintOf;

/// Typed alias kept for expense-call-site compatibility.
typedef ExpenseFingerprint = OperationFingerprint;

OperationFingerprint fingerprintOfExpense(Expense expense) {
  return fingerprintOf(
    occurredAt: expense.occurredAt,
    originalAmountMinor: expense.originalAmountMinor,
    originalCurrencyCode: expense.originalCurrencyCode,
  );
}

/// Indexes expenses that are still candidates for duplicate matching
/// (skips rows the user already marked as not-a-duplicate).
Map<OperationFingerprint, List<Expense>> indexByFingerprint(
  List<Expense> expenses,
) {
  final map = <OperationFingerprint, List<Expense>>{};
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
  required OperationFingerprint fingerprint,
  int? excludeId,
}) {
  return pool.where((expense) {
    if (expense.duplicateDismissed) return false;
    if (excludeId != null && expense.id == excludeId) return false;
    return fingerprintOfExpense(expense) == fingerprint;
  }).toList();
}
