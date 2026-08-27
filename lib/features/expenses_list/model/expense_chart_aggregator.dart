import 'package:valtero/entities/exchange_rate/model/rate_resolver.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/money.dart';

Future<({int totalMinor, int convertibleCount})> sumExpensesInCurrency({
  required List<Expense> expenses,
  required String targetCurrency,
  required RateResolver resolver,
}) async {
  final target = targetCurrency.toUpperCase();
  var total = 0;
  var convertible = 0;
  for (final expense in expenses) {
    final from = expense.storedCurrencyCode.toUpperCase();
    if (from == target) {
      total += expense.storedAmountMinor;
      convertible++;
      continue;
    }
    final rate = await resolver.getRate(from, target);
    if (rate == null) continue;
    total += Money.convertMinor(
      originalMinor: expense.storedAmountMinor,
      rate: rate,
    );
    convertible++;
  }
  return (totalMinor: total, convertibleCount: convertible);
}

Future<Map<String, int>> aggregateExpensesForChart({
  required List<Expense> expenses,
  required String primaryCurrency,
  required RateResolver resolver,
  required ExpenseChartBreakdown breakdown,
  required Map<int, List<int>> expenseTags,
  required Map<int, String> tagLabels,
  required String untaggedLabel,
}) async {
  final amounts = <String, int>{};
  for (final expense in expenses) {
    final rate = await resolver.getRate(
      expense.storedCurrencyCode,
      primaryCurrency,
    );
    final amount = rate == null
        ? (expense.storedCurrencyCode.toUpperCase() ==
                primaryCurrency.toUpperCase()
            ? expense.storedAmountMinor
            : 0)
        : Money.convertMinor(
            originalMinor: expense.storedAmountMinor,
            rate: rate,
          );
    if (amount <= 0) continue;

    switch (breakdown) {
      case ExpenseChartBreakdown.currency:
        final key = expense.storedCurrencyCode.toUpperCase();
        amounts[key] = (amounts[key] ?? 0) + amount;
      case ExpenseChartBreakdown.month:
        final key =
            '${expense.occurredAt.year}-'
            '${expense.occurredAt.month.toString().padLeft(2, '0')}';
        amounts[key] = (amounts[key] ?? 0) + amount;
      case ExpenseChartBreakdown.year:
        final key = '${expense.occurredAt.year}';
        amounts[key] = (amounts[key] ?? 0) + amount;
      case ExpenseChartBreakdown.tags:
        final ids = expenseTags[expense.id] ?? const <int>[];
        if (ids.isEmpty) {
          amounts[untaggedLabel] = (amounts[untaggedLabel] ?? 0) + amount;
        } else {
          final share = amount ~/ ids.length;
          var remainder = amount - share * ids.length;
          for (final id in ids) {
            final label = tagLabels[id] ?? untaggedLabel;
            final part = share + (remainder > 0 ? 1 : 0);
            if (remainder > 0) remainder--;
            amounts[label] = (amounts[label] ?? 0) + part;
          }
        }
    }
  }
  return amounts;
}
