import 'package:valtero/features/expenses_list/model/grouping/expense_grouper.dart';
import 'package:valtero/features/expenses_list/model/grouping/expense_grouping_context.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';

final class CountryExpenseGrouper extends ExpenseGrouperBase {
  final String? languageCode;

  const CountryExpenseGrouper({this.languageCode});

  @override
  Iterable<String> labelsFor(
    Expense expense,
    ExpenseGroupingContext context,
  ) {
    final code = expense.countryCode;
    if (code == null || code.isEmpty) {
      return [context.unspecifiedCountryLabel];
    }
    return [
      countryDisplayName(code, languageCode: languageCode),
    ];
  }
}
