import 'package:valtero/features/expenses_list/model/cash_flow_group_row.dart';
import 'package:valtero/features/expenses_list/model/recent_operation.dart';
import 'package:valtero/shared/utils/app_timezone.dart';

/// Label maps and sort hints for cash-flow groupers. No tag maps: expense and
/// income categories are separate tag kinds, so cash flow never groups by tag.
class CashFlowGroupingContext {
  final Map<int, String> paymentMethodLabels;
  final String unspecifiedCountryLabel;
  final String unspecifiedPaymentLabel;
  final bool ascending;
  final String timeZoneId;

  const CashFlowGroupingContext({
    required this.paymentMethodLabels,
    required this.unspecifiedCountryLabel,
    required this.unspecifiedPaymentLabel,
    this.ascending = false,
    this.timeZoneId = kSystemTimeZoneId,
  });
}

abstract interface class CashFlowGrouper {
  List<CashFlowGroupRow> aggregate(
    List<RecentOperation> operations,
    CashFlowGroupingContext context,
  );
}

/// Buckets operations by group label and currency; never sums across
/// currencies, and keeps income and expense totals apart inside a bucket.
abstract base class CashFlowGrouperBase implements CashFlowGrouper {
  const CashFlowGrouperBase();

  @override
  List<CashFlowGroupRow> aggregate(
    List<RecentOperation> operations,
    CashFlowGroupingContext context,
  ) {
    final buckets = <String, _Bucket>{};

    for (final op in operations) {
      for (final groupLabel in labelsFor(op, context)) {
        _addToBucket(buckets, groupLabel, op);
      }
    }

    final rows = buckets.values
        .map(
          (bucket) => CashFlowGroupRow(
            groupLabel: bucket.groupLabel,
            currencyCode: bucket.currencyCode,
            count: bucket.count,
            incomeMinor: bucket.incomeMinor,
            expenseMinor: bucket.expenseMinor,
          ),
        )
        .toList();

    rows.sort((a, b) => compare(a, b, context));
    return rows;
  }

  Iterable<String> labelsFor(
    RecentOperation op,
    CashFlowGroupingContext context,
  );

  int compare(
    CashFlowGroupRow a,
    CashFlowGroupRow b,
    CashFlowGroupingContext context,
  ) {
    final groupCmp = compareGroupLabels(a.groupLabel, b.groupLabel, context);
    if (groupCmp != 0) return groupCmp;
    return a.currencyCode.compareTo(b.currencyCode);
  }

  int compareGroupLabels(
    String a,
    String b,
    CashFlowGroupingContext context,
  ) =>
      a.compareTo(b);

  void _addToBucket(
    Map<String, _Bucket> buckets,
    String groupLabel,
    RecentOperation op,
  ) {
    final currency = op.currencyCode;
    final key = '$groupLabel\x00${currency.toUpperCase()}';
    final isIncome = op.kind == OperationKind.income;
    final existing = buckets[key];
    buckets[key] = _Bucket(
      groupLabel: groupLabel,
      currencyCode: currency,
      count: (existing?.count ?? 0) + 1,
      incomeMinor:
          (existing?.incomeMinor ?? 0) + (isIncome ? op.amountMinor : 0),
      expenseMinor:
          (existing?.expenseMinor ?? 0) + (isIncome ? 0 : op.amountMinor),
    );
  }
}

class _Bucket {
  final String groupLabel;
  final String currencyCode;
  final int count;
  final int incomeMinor;
  final int expenseMinor;

  const _Bucket({
    required this.groupLabel,
    required this.currencyCode,
    required this.count,
    required this.incomeMinor,
    required this.expenseMinor,
  });
}
