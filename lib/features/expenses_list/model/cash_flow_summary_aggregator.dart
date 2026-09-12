import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/features/expenses_list/model/recent_operation.dart';
import 'package:valtero/shared/utils/money.dart';

/// Income / expense / net totals for one stored currency in the cash-flow
/// summary card. Mirrors `CurrencyExpenseSummary` but keeps both directions.
class CurrencyCashFlowSummary {
  final String currency;
  final int count;
  final int incomeMinor;
  final int expenseMinor;

  const CurrencyCashFlowSummary({
    required this.currency,
    required this.count,
    required this.incomeMinor,
    required this.expenseMinor,
  });

  int get netMinor => incomeMinor - expenseMinor;

  /// Income + expenses, used to rank currencies by activity.
  int get grossMinor => incomeMinor + expenseMinor;
}

/// Groups merged operations by stored currency (native amounts, no FX).
List<CurrencyCashFlowSummary> aggregateCashFlowByCurrency(
  List<RecentOperation> operations,
) {
  final counts = <String, int>{};
  final income = <String, int>{};
  final expense = <String, int>{};
  for (final op in operations) {
    final code = op.currencyCode.toUpperCase();
    counts[code] = (counts[code] ?? 0) + 1;
    if (op.kind == OperationKind.income) {
      income[code] = (income[code] ?? 0) + op.amountMinor;
    } else {
      expense[code] = (expense[code] ?? 0) + op.amountMinor;
    }
  }
  final rows = [
    for (final code in counts.keys)
      CurrencyCashFlowSummary(
        currency: code,
        count: counts[code]!,
        incomeMinor: income[code] ?? 0,
        expenseMinor: expense[code] ?? 0,
      ),
  ]..sort((a, b) {
      final grossCmp = b.grossMinor.compareTo(a.grossMinor);
      if (grossCmp != 0) return grossCmp;
      return a.currency.compareTo(b.currency);
    });
  return rows;
}

typedef CashFlowConvertedTotals = ({
  int incomeMinor,
  int expenseMinor,
  int netMinor,
  int convertibleCount,
});

/// Converts every operation into [targetCurrency] and splits the totals by
/// direction. Operations without a usable rate are skipped (reported through
/// `convertibleCount`), same as `sumExpensesInCurrency`.
Future<CashFlowConvertedTotals> sumCashFlowInCurrency({
  required List<RecentOperation> operations,
  required String targetCurrency,
  required RateResolver resolver,
}) async {
  final target = targetCurrency.toUpperCase();
  var income = 0;
  var expense = 0;
  var convertible = 0;
  for (final op in operations) {
    final from = op.currencyCode.toUpperCase();
    final int converted;
    if (from == target) {
      converted = op.amountMinor;
    } else {
      final rate = await resolver.getRate(from, target);
      if (rate == null) continue;
      converted = Money.convertMinor(
        originalMinor: op.amountMinor,
        rate: rate,
      );
    }
    if (op.kind == OperationKind.income) {
      income += converted;
    } else {
      expense += converted;
    }
    convertible++;
  }
  return (
    incomeMinor: income,
    expenseMinor: expense,
    netMinor: income - expense,
    convertibleCount: convertible,
  );
}

/// Stable key for FutureBuilder invalidation; expense and income ids overlap,
/// so the kind is part of each token.
String cashFlowSnapshotKey(Iterable<RecentOperation> operations) {
  final tokens = operations
      .map((op) => '${op.kind == OperationKind.income ? 'i' : 'e'}${op.id}')
      .toList()
    ..sort();
  return tokens.join(',');
}
