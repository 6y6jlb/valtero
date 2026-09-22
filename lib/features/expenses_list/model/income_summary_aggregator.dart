import 'package:valtero/shared/database/app_database.dart';

/// Mirrors `aggregateExpensesByCurrency` / `CurrencyExpenseSummary` for
/// [Income] rows.
typedef CurrencyIncomeSummary = ({
  String currency,
  int count,
  int totalMinor,
});

/// Groups filtered incomes by stored currency (native amounts, no FX).
List<CurrencyIncomeSummary> aggregateIncomesByCurrency(
  List<Income> incomes,
) {
  final counts = <String, int>{};
  final totals = <String, int>{};
  for (final income in incomes) {
    final code = income.storedCurrencyCode.toUpperCase();
    counts[code] = (counts[code] ?? 0) + 1;
    totals[code] = (totals[code] ?? 0) + income.storedAmountMinor;
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

/// Stable fingerprint for [FutureBuilder] keys when income data changes.
String incomesSnapshotKey(Iterable<Income> incomes) {
  final buffer = StringBuffer();
  for (final e in incomes) {
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
