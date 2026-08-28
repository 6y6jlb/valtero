import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/grouping/country_expense_grouper.dart';
import 'package:valtero/features/expenses_list/model/grouping/currency_expense_grouper.dart';
import 'package:valtero/features/expenses_list/model/grouping/date_expense_grouper.dart';
import 'package:valtero/features/expenses_list/model/grouping/expense_grouper.dart';
import 'package:valtero/features/expenses_list/model/grouping/payment_method_expense_grouper.dart';
import 'package:valtero/features/expenses_list/model/grouping/tag_kind_expense_grouper.dart';

const _currencyGrouper = CurrencyExpenseGrouper();
const _dateGrouper = DateExpenseGrouper();
const _paymentGrouper = PaymentMethodExpenseGrouper();
const _countryGrouper = CountryExpenseGrouper();
const _tagCustomGrouper = TagKindExpenseGrouper(TagKind.custom);

ExpenseGrouper expenseGrouperFor(ExpenseListGroup group) {
  return switch (group) {
    ExpenseListGroup.none || ExpenseListGroup.currency => _currencyGrouper,
    ExpenseListGroup.date => _dateGrouper,
    ExpenseListGroup.payment => _paymentGrouper,
    ExpenseListGroup.tag || ExpenseListGroup.tagCustom => _tagCustomGrouper,
    ExpenseListGroup.country => _countryGrouper,
  };
}
