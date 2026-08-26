import 'package:flutter/material.dart';
import 'package:valtero/features/add_expense/ui/add_expense_form.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';

Future<void> showAddExpenseSheet(BuildContext context) {
  return showAppModalSheet(
    context: context,
    initialChildSize: 0.9,
    minChildSize: 0.5,
    child: const AddExpenseForm(),
  );
}
