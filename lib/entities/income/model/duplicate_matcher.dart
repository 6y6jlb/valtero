import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/finance/operation_fingerprint.dart';

export 'package:valtero/shared/finance/operation_fingerprint.dart'
    show OperationFingerprint, fingerprintOf;

OperationFingerprint fingerprintOfIncome(Income income) {
  return fingerprintOf(
    occurredAt: income.occurredAt,
    originalAmountMinor: income.originalAmountMinor,
    originalCurrencyCode: income.originalCurrencyCode,
  );
}

Map<OperationFingerprint, List<Income>> indexIncomeByFingerprint(
  List<Income> incomes,
) {
  final map = <OperationFingerprint, List<Income>>{};
  for (final income in incomes) {
    if (income.duplicateDismissed) continue;
    final key = fingerprintOfIncome(income);
    map.putIfAbsent(key, () => []).add(income);
  }
  return map;
}

List<List<int>> groupPotentialIncomeDuplicates(List<Income> incomes) {
  final indexed = indexIncomeByFingerprint(incomes);
  final groups = <List<int>>[];
  for (final entries in indexed.values) {
    if (entries.length < 2) continue;
    groups.add(entries.map((e) => e.id).toList());
  }
  return groups;
}

List<Income> findIncomeMatches({
  required List<Income> pool,
  required OperationFingerprint fingerprint,
  int? excludeId,
}) {
  return pool.where((income) {
    if (income.duplicateDismissed) return false;
    if (excludeId != null && income.id == excludeId) return false;
    return fingerprintOfIncome(income) == fingerprint;
  }).toList();
}
