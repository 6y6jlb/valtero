import 'package:valtero/features/expenses_list/model/grouping/expense_grouper.dart';
import 'package:valtero/features/expenses_list/model/grouping/expense_grouping_context.dart';
import 'package:valtero/shared/database/app_database.dart';

final class PaymentMethodExpenseGrouper extends ExpenseGrouperBase {
  const PaymentMethodExpenseGrouper();

  @override
  Iterable<String> labelsFor(
    Expense expense,
    ExpenseGroupingContext context,
  ) {
    final id = expense.paymentMethodId;
    if (id == null) return [context.unspecifiedPaymentLabel];
    return [context.paymentMethodLabels[id] ?? '?'];
  }
}
