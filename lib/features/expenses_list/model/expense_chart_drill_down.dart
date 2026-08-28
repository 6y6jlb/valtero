import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_view.dart';

/// Narrow [base] filters to the chart segment identified by [sliceKey].
ExpenseListQuery? expenseChartDrillDownQuery({
  required ExpenseListQuery base,
  required ExpenseChartBreakdown breakdown,
  required String sliceKey,
}) {
  switch (breakdown) {
    case ExpenseChartBreakdown.tagCountry:
    case ExpenseChartBreakdown.tagTrip:
    case ExpenseChartBreakdown.tagCustom:
      if (sliceKey == '__untagged__') return null;
      final id = int.tryParse(sliceKey.replaceFirst('tag_', ''));
      if (id == null) return null;
      return base.copyWith(tagIds: {id});
    case ExpenseChartBreakdown.payment:
      if (sliceKey == '__untagged__') return null;
      final id = int.tryParse(sliceKey.replaceFirst('pay_', ''));
      if (id == null) return null;
      return base.copyWith(paymentMethodIds: {id});
    case ExpenseChartBreakdown.month:
      final parts = sliceKey.split('-');
      if (parts.length != 2) return null;
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      if (year == null || month == null) return null;
      final from = DateTime(year, month, 1);
      final to = DateTime(year, month + 1, 0);
      return base.copyWith(from: from, to: to);
    case ExpenseChartBreakdown.year:
      final year = int.tryParse(sliceKey);
      if (year == null) return null;
      return base.copyWith(
        from: DateTime(year, 1, 1),
        to: DateTime(year, 12, 31),
      );
    case ExpenseChartBreakdown.currency:
      return base.copyWith(currencyCode: sliceKey);
  }
}

bool expenseChartBreakdownUsesTagKind(ExpenseChartBreakdown breakdown) {
  return switch (breakdown) {
    ExpenseChartBreakdown.tagCountry ||
    ExpenseChartBreakdown.tagTrip ||
    ExpenseChartBreakdown.tagCustom =>
      true,
    _ => false,
  };
}

bool expenseChartBreakdownUsesPayment(ExpenseChartBreakdown breakdown) {
  return breakdown == ExpenseChartBreakdown.payment;
}
