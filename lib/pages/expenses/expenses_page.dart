import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/ui/expenses_sheet.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_page_scaffold.dart';

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
    return AppPageScaffold(
      appBar: AppBar(
        title: Text(l10n.navExpenses),
      ),
      addExpenseHeroTag: 'expenses_add_expense',
      body: ExpensesSheetBody(
        initial: initial ?? ExpenseListQuery.sessionDefaults(),
        showTitleBar: false,
      ),
    );
  }
}
