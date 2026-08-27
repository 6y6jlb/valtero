import 'package:flutter/material.dart';
import 'package:valtero/features/add_expense/ui/add_expense_sheet.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/ui/expenses_sheet.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

class ExpensesPage extends StatelessWidget {
  final ExpenseListQuery? initial;

  const ExpensesPage({super.key, this.initial});

  static Future<void> open(
    BuildContext context, {
    ExpenseListQuery? initial,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ExpensesPage(initial: initial),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navExpenses),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'expenses_add_expense',
        tooltip: l10n.addExpense,
        onPressed: () => showAddExpenseSheet(context),
        child: const Icon(Icons.add, size: 32),
      ),
      body: ExpensesSheetBody(
        initial: initial ?? ExpenseListQuery.sessionDefaults(),
        showTitleBar: false,
      ),
    );
  }
}
