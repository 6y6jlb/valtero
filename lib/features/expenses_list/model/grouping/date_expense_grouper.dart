import 'package:valtero/features/expenses_list/model/grouping/expense_grouper.dart';
import 'package:valtero/features/expenses_list/model/grouping/expense_grouping_context.dart';
import 'package:valtero/shared/database/app_database.dart';

final class DateExpenseGrouper extends ExpenseGrouperBase {
  const DateExpenseGrouper();

  static String formatDay(DateTime date) =>
      '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  Iterable<String> labelsFor(
    Expense expense,
    ExpenseGroupingContext context,
  ) =>
      [formatDay(expense.occurredAt)];

  @override
  int compareGroupLabels(
    String a,
    String b,
    ExpenseGroupingContext context,
  ) =>
      context.ascending ? a.compareTo(b) : b.compareTo(a);
}
