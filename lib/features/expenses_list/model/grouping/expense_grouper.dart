import 'package:valtero/features/expenses_list/model/expense_group_row.dart';
import 'package:valtero/features/expenses_list/model/grouping/expense_grouping_context.dart';
import 'package:valtero/shared/database/app_database.dart';

abstract interface class ExpenseGrouper {
  List<ExpenseGroupRow> aggregate(
    List<Expense> expenses,
    ExpenseGroupingContext context,
  );
}

/// Buckets expenses by group label and currency; never sums across currencies.
abstract base class ExpenseGrouperBase implements ExpenseGrouper {
  const ExpenseGrouperBase();

  @override
  List<ExpenseGroupRow> aggregate(
    List<Expense> expenses,
    ExpenseGroupingContext context,
  ) {
    final buckets = <String, _Bucket>{};

    for (final expense in expenses) {
      for (final groupLabel in labelsFor(expense, context)) {
        _addToBucket(buckets, groupLabel, expense);
      }
    }

    final rows = buckets.values
        .map(
          (bucket) => ExpenseGroupRow(
            groupLabel: bucket.groupLabel,
            count: bucket.count,
            amountMinor: bucket.amountMinor,
            currencyCode: bucket.currencyCode,
          ),
        )
        .toList();

    rows.sort((a, b) => compare(a, b, context));
    return rows;
  }

  Iterable<String> labelsFor(
    Expense expense,
    ExpenseGroupingContext context,
  );

  int compare(
    ExpenseGroupRow a,
    ExpenseGroupRow b,
    ExpenseGroupingContext context,
  ) {
    final groupCmp = compareGroupLabels(
      a.groupLabel,
      b.groupLabel,
      context,
    );
    if (groupCmp != 0) return groupCmp;
    return a.currencyCode.compareTo(b.currencyCode);
  }

  int compareGroupLabels(
    String a,
    String b,
    ExpenseGroupingContext context,
  ) =>
      a.compareTo(b);

  void _addToBucket(
    Map<String, _Bucket> buckets,
    String groupLabel,
    Expense expense,
  ) {
    final currency = expense.storedCurrencyCode;
    final key = '$groupLabel\x00${currency.toUpperCase()}';
    final existing = buckets[key];
    if (existing == null) {
      buckets[key] = _Bucket(
        groupLabel: groupLabel,
        currencyCode: currency,
        count: 1,
        amountMinor: expense.storedAmountMinor,
      );
    } else {
      buckets[key] = _Bucket(
        groupLabel: groupLabel,
        currencyCode: currency,
        count: existing.count + 1,
        amountMinor: existing.amountMinor + expense.storedAmountMinor,
      );
    }
  }
}

class _Bucket {
  final String groupLabel;
  final String currencyCode;
  final int count;
  final int amountMinor;

  const _Bucket({
    required this.groupLabel,
    required this.currencyCode,
    required this.count,
    required this.amountMinor,
  });
}
