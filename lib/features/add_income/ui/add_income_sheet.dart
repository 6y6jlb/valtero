import 'package:flutter/material.dart';
import 'package:valtero/features/add_income/ui/add_income_form.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';

Future<void> showAddIncomeSheet(
  BuildContext context, {
  Income? income,
}) {
  return showAppModalSheet(
    context: context,
    initialChildSize: 0.9,
    minChildSize: 0.5,
    child: AddIncomeForm(income: income),
  );
}
