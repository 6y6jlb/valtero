import 'package:valtero/shared/database/app_database.dart';

typedef CurrencyExpenseSummary = ({
  String currency,
  int count,
  int totalMinor,
});

/// Groups filtered expenses by stored currency (native amounts, no FX).
List<CurrencyExpenseSummary> aggregateExpensesByCurrency(
  List<Expense> expenses,
) {
  final counts = <String, int>{};
  final totals = <String, int>{};
  for (final expense in expenses) {
    final code = expense.storedCurrencyCode.toUpperCase();
    counts[code] = (counts[code] ?? 0) + 1;
    totals[code] = (totals[code] ?? 0) + expense.storedAmountMinor;
  }
  final entries = counts.entries.toList()
    ..sort((a, b) {
      final totalCmp = (totals[b.key] ?? 0).compareTo(totals[a.key] ?? 0);
      if (totalCmp != 0) return totalCmp;
      return a.key.compareTo(b.key);
    });
  return [
    for (final e in entries)
      (currency: e.key, count: e.value, totalMinor: totals[e.key]!),
  ];
}

/// Stable fingerprint for [FutureBuilder] keys when expense data changes.
String expensesSnapshotKey(Iterable<Expense> expenses) {
  final buffer = StringBuffer();
  for (final e in expenses) {
    buffer
      ..write(e.id)
      ..write(':')
      ..write(e.storedAmountMinor)
      ..write(':')
      ..write(e.storedCurrencyCode)
      ..write(';');
  }
  return buffer.toString();
}
