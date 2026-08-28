import 'package:flutter/material.dart';
import 'package:valtero/features/add_expense/ui/add_expense_form.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';

Future<void> showAddExpenseSheet(
  BuildContext context, {
  Expense? expense,
}) {
  return showAppModalSheet(
    context: context,
    initialChildSize: 0.9,
    minChildSize: 0.5,
    child: AddExpenseForm(expense: expense),
  );
}
