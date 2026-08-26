import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_filter/model/expense_filter.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';

final expensesStreamProvider =
    StreamProvider.family<List<Expense>, ExpenseFilter>((ref, filter) {
  return ref.watch(appDatabaseProvider).watchExpenses(
        tagId: filter.tagId,
        currencyCode: filter.currencyCode,
        from: filter.from,
        to: filter.to,
      );
});

final allExpensesProvider = StreamProvider<List<Expense>>((ref) {
  return ref.watch(appDatabaseProvider).watchExpenses();
});
