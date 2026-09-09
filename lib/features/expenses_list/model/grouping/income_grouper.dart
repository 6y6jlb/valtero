import 'package:valtero/features/expenses_list/model/expense_group_row.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/app_timezone.dart';

/// Tag maps and sort hints for income groupers (mirrors expense grouping).
class IncomeGroupingContext {
  final Map<int, List<int>> incomeTags;
  final Map<int, String> tagLabels;
  final Map<int, Tag> tagById;
  final Map<int, String> paymentMethodLabels;
  final String unspecifiedCountryLabel;
  final String unspecifiedIncomeLabel;
  final String unspecifiedPaymentLabel;
  final bool ascending;
  final String timeZoneId;

  const IncomeGroupingContext({
    required this.incomeTags,
    required this.tagLabels,
    required this.tagById,
    required this.paymentMethodLabels,
    required this.unspecifiedCountryLabel,
    required this.unspecifiedIncomeLabel,
    required this.unspecifiedPaymentLabel,
    this.ascending = false,
    this.timeZoneId = kSystemTimeZoneId,
  });
}

abstract interface class IncomeGrouper {
  List<ExpenseGroupRow> aggregate(
    List<Income> incomes,
    IncomeGroupingContext context,
  );
}

/// Buckets incomes by group label and currency; never sums across currencies.
abstract base class IncomeGrouperBase implements IncomeGrouper {
  const IncomeGrouperBase();

  @override
  List<ExpenseGroupRow> aggregate(
    List<Income> incomes,
    IncomeGroupingContext context,
  ) {
    final buckets = <String, _Bucket>{};

    for (final income in incomes) {
      for (final groupLabel in labelsFor(income, context)) {
        _addToBucket(buckets, groupLabel, income);
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

  Iterable<String> labelsFor(Income income, IncomeGroupingContext context);

  int compare(
    ExpenseGroupRow a,
    ExpenseGroupRow b,
    IncomeGroupingContext context,
  ) {
    final groupCmp = compareGroupLabels(a.groupLabel, b.groupLabel, context);
    if (groupCmp != 0) return groupCmp;
    return a.currencyCode.compareTo(b.currencyCode);
  }

  int compareGroupLabels(
    String a,
    String b,
    IncomeGroupingContext context,
  ) =>
      a.compareTo(b);

  void _addToBucket(
    Map<String, _Bucket> buckets,
    String groupLabel,
    Income income,
  ) {
    final currency = income.storedCurrencyCode;
    final key = '$groupLabel\x00${currency.toUpperCase()}';
    final existing = buckets[key];
    if (existing == null) {
      buckets[key] = _Bucket(
        groupLabel: groupLabel,
        currencyCode: currency,
        count: 1,
        amountMinor: income.storedAmountMinor,
      );
    } else {
      buckets[key] = _Bucket(
        groupLabel: groupLabel,
        currencyCode: currency,
        count: existing.count + 1,
        amountMinor: existing.amountMinor + income.storedAmountMinor,
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
