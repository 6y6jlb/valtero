import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/grouping/currency_expense_grouper.dart';
import 'package:valtero/features/expenses_list/model/grouping/date_expense_grouper.dart';
import 'package:valtero/features/expenses_list/model/grouping/expense_grouper.dart';
import 'package:valtero/features/expenses_list/model/grouping/tag_expense_grouper.dart';

const _currencyGrouper = CurrencyExpenseGrouper();
const _dateGrouper = DateExpenseGrouper();
const _tagGrouper = TagExpenseGrouper();

ExpenseGrouper expenseGrouperFor(ExpenseListGroup group) {
  return switch (group) {
    ExpenseListGroup.none || ExpenseListGroup.currency => _currencyGrouper,
    ExpenseListGroup.date => _dateGrouper,
    ExpenseListGroup.tag => _tagGrouper,
  };
}
