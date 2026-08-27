import 'package:valtero/features/expenses_list/model/grouping/expense_grouper.dart';
import 'package:valtero/features/expenses_list/model/grouping/expense_grouping_context.dart';
import 'package:valtero/shared/database/app_database.dart';

final class TagExpenseGrouper extends ExpenseGrouperBase {
  const TagExpenseGrouper();

  @override
  Iterable<String> labelsFor(
    Expense expense,
    ExpenseGroupingContext context,
  ) {
    final ids = context.expenseTags[expense.id] ?? const <int>[];
    if (ids.isEmpty) return [context.untaggedLabel];
    return [for (final id in ids) context.tagLabels[id] ?? '?'];
  }
}
