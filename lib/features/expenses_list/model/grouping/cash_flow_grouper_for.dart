import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/grouping/cash_flow_grouper.dart';
import 'package:valtero/features/expenses_list/model/recent_operation.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/utils/app_timezone.dart';

final class _CurrencyCashFlowGrouper extends CashFlowGrouperBase {
  const _CurrencyCashFlowGrouper();

  @override
  Iterable<String> labelsFor(
    RecentOperation op,
    CashFlowGroupingContext context,
  ) =>
      [op.currencyCode];
}

final class _DateCashFlowGrouper extends CashFlowGrouperBase {
  const _DateCashFlowGrouper();

  @override
  Iterable<String> labelsFor(
    RecentOperation op,
    CashFlowGroupingContext context,
  ) =>
      [calendarDayKey(op.occurredAt, context.timeZoneId)];

  @override
  int compareGroupLabels(
    String a,
    String b,
    CashFlowGroupingContext context,
  ) =>
      context.ascending ? a.compareTo(b) : b.compareTo(a);
}

final class _CountryCashFlowGrouper extends CashFlowGrouperBase {
  const _CountryCashFlowGrouper();

  @override
  Iterable<String> labelsFor(
    RecentOperation op,
    CashFlowGroupingContext context,
  ) {
    final code = op.countryCode;
    if (code == null || code.isEmpty) {
      return [context.unspecifiedCountryLabel];
    }
    return [countryDisplayName(code)];
  }
}

final class _PaymentCashFlowGrouper extends CashFlowGrouperBase {
  const _PaymentCashFlowGrouper();

  @override
  Iterable<String> labelsFor(
    RecentOperation op,
    CashFlowGroupingContext context,
  ) {
    final id = op.paymentMethodId;
    if (id == null) return [context.unspecifiedPaymentLabel];
    return [context.paymentMethodLabels[id] ?? '?'];
  }
}

const _currency = _CurrencyCashFlowGrouper();
const _date = _DateCashFlowGrouper();
const _payment = _PaymentCashFlowGrouper();
const _country = _CountryCashFlowGrouper();

/// Cash flow has no category grouping (expense and income tags differ), so
/// tag groups fall back to currency.
const cashFlowGroupOptions = <ExpenseListGroup>[
  ExpenseListGroup.currency,
  ExpenseListGroup.date,
  ExpenseListGroup.country,
  ExpenseListGroup.payment,
];

CashFlowGrouper cashFlowGrouperFor(ExpenseListGroup group) {
  return switch (group) {
    ExpenseListGroup.date => _date,
    ExpenseListGroup.payment => _payment,
    ExpenseListGroup.country => _country,
    ExpenseListGroup.none ||
    ExpenseListGroup.currency ||
    ExpenseListGroup.tag ||
    ExpenseListGroup.tagCustom =>
      _currency,
  };
}
