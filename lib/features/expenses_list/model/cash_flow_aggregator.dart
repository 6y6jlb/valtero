import 'dart:ui' show Color;

import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_slice.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/money.dart';

class CashFlowBucket {
  final String key;
  final String label;
  final int incomeTotalMinor;
  final int expenseTotalMinor;

  const CashFlowBucket({
    required this.key,
    required this.label,
    required this.incomeTotalMinor,
    required this.expenseTotalMinor,
  });

  int get netMinor => incomeTotalMinor - expenseTotalMinor;
}

/// Totals income vs expense across [buckets] as two donut slices.
List<DonutChartSlice> cashFlowDirectionSlices({
  required List<CashFlowBucket> buckets,
  required String incomeLabel,
  required String expenseLabel,
  required Color incomeColor,
  required Color expenseColor,
}) {
  final income = buckets.fold<int>(0, (sum, b) => sum + b.incomeTotalMinor);
  final expense = buckets.fold<int>(0, (sum, b) => sum + b.expenseTotalMinor);
  return [
    if (income > 0)
      DonutChartSlice(
        key: 'income',
        label: incomeLabel,
        amountMinor: income,
        color: incomeColor,
      ),
    if (expense > 0)
      DonutChartSlice(
        key: 'expense',
        label: expenseLabel,
        amountMinor: expense,
        color: expenseColor,
      ),
  ];
}

typedef CashFlowAggregation = ({
  List<CashFlowBucket> buckets,
  int missingRateCount,
});

Future<int?> _convertedMinor({
  required int amountMinor,
  required String fromCurrency,
  required String targetCurrency,
  required RateResolver resolver,
}) async {
  final from = fromCurrency.toUpperCase();
  final target = targetCurrency.toUpperCase();
  if (from == target) return amountMinor;
  final rate = await resolver.getRate(from, target);
  if (rate == null) return null;
  return Money.convertMinor(originalMinor: amountMinor, rate: rate);
}

String _bucketKey(
  DateTime occurredAt,
  ExpenseChartBreakdown breakdown,
  String timeZoneId,
) {
  final z = zonedFromInstant(occurredAt, timeZoneId);
  return switch (breakdown) {
    ExpenseChartBreakdown.day =>
      '${z.year}-${z.month.toString().padLeft(2, '0')}-${z.day.toString().padLeft(2, '0')}',
    ExpenseChartBreakdown.week => () {
        final start = z.subtract(Duration(days: z.weekday - 1));
        return '${start.year}-W${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
      }(),
    ExpenseChartBreakdown.month =>
      '${z.year}-${z.month.toString().padLeft(2, '0')}',
    ExpenseChartBreakdown.year => '${z.year}',
    _ => '${z.year}-${z.month.toString().padLeft(2, '0')}',
  };
}

String _bucketLabel(String key, ExpenseChartBreakdown breakdown) => key;

/// Aggregates income vs expenses into temporal buckets for the cash-flow chart.
///
/// Only date-range / currency filters should be applied upstream; tag/payment
/// /country filters are direction-specific and not used here.
Future<CashFlowAggregation> aggregateCashFlow({
  required List<Expense> expenses,
  required List<Income> incomes,
  required String primaryCurrency,
  required RateResolver resolver,
  required ExpenseChartBreakdown breakdown,
  String timeZoneId = kSystemTimeZoneId,
}) async {
  final temporal = {
    ExpenseChartBreakdown.day,
    ExpenseChartBreakdown.week,
    ExpenseChartBreakdown.month,
    ExpenseChartBreakdown.year,
  };
  final effective = temporal.contains(breakdown)
      ? breakdown
      : ExpenseChartBreakdown.month;

  final incomeByKey = <String, int>{};
  final expenseByKey = <String, int>{};
  final labels = <String, String>{};
  var missing = 0;

  for (final expense in expenses) {
    final converted = await _convertedMinor(
      amountMinor: expense.storedAmountMinor,
      fromCurrency: expense.storedCurrencyCode,
      targetCurrency: primaryCurrency,
      resolver: resolver,
    );
    if (converted == null) {
      missing++;
      continue;
    }
    final key = _bucketKey(expense.occurredAt, effective, timeZoneId);
    expenseByKey[key] = (expenseByKey[key] ?? 0) + converted;
    labels[key] = _bucketLabel(key, effective);
  }

  for (final income in incomes) {
    final converted = await _convertedMinor(
      amountMinor: income.storedAmountMinor,
      fromCurrency: income.storedCurrencyCode,
      targetCurrency: primaryCurrency,
      resolver: resolver,
    );
    if (converted == null) {
      missing++;
      continue;
    }
    final key = _bucketKey(income.occurredAt, effective, timeZoneId);
    incomeByKey[key] = (incomeByKey[key] ?? 0) + converted;
    labels[key] = _bucketLabel(key, effective);
  }

  final keys = {...incomeByKey.keys, ...expenseByKey.keys}.toList()..sort();
  final buckets = [
    for (final key in keys)
      CashFlowBucket(
        key: key,
        label: labels[key] ?? key,
        incomeTotalMinor: incomeByKey[key] ?? 0,
        expenseTotalMinor: expenseByKey[key] ?? 0,
      ),
  ];
  return (buckets: buckets, missingRateCount: missing);
}
