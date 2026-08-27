import 'package:valtero/features/expenses_list/model/grouping/expense_grouper.dart';
import 'package:valtero/features/expenses_list/model/grouping/expense_grouping_context.dart';
import 'package:valtero/shared/database/app_database.dart';

final class CurrencyExpenseGrouper extends ExpenseGrouperBase {
  const CurrencyExpenseGrouper();

  @override
  Iterable<String> labelsFor(
    Expense expense,
    ExpenseGroupingContext context,
  ) =>
      [expense.storedCurrencyCode];
}
