import 'package:valtero/features/expenses_list/model/grouping/expense_grouper.dart';
import 'package:valtero/features/expenses_list/model/grouping/expense_grouping_context.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/app_timezone.dart';

final class DateExpenseGrouper extends ExpenseGrouperBase {
  const DateExpenseGrouper();

  @override
  Iterable<String> labelsFor(
    Expense expense,
    ExpenseGroupingContext context,
  ) =>
      [calendarDayKey(expense.occurredAt, context.timeZoneId)];

  @override
  int compareGroupLabels(
    String a,
    String b,
    ExpenseGroupingContext context,
  ) =>
      context.ascending ? a.compareTo(b) : b.compareTo(a);
}
