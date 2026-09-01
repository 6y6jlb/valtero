import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/ui/expense_payment_filter_dialog.dart';
import 'package:valtero/features/expenses_list/ui/expense_tag_filter_dialog.dart';
import 'package:valtero/features/expenses_list/ui/expenses_filter_sheet.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/date_period.dart';
import 'package:valtero/widgets/period_picker.dart';

/// Opens the expenses filter sheet (period / tags / payment) and returns the
/// applied draft, or `null` if cancelled.
Future<ExpenseListQuery?> openExpensesFilterSheet({
  required BuildContext context,
  required ExpenseListQuery draft,
  required List<String> currencyOptions,
  required Map<int, String> tagLabels,
  required Map<int, String> paymentLabels,
  required List<Tag> tags,
  required List<PaymentMethod> paymentMethods,
}) {
  return showExpensesFilterSheet(
    context: context,
    initial: draft,
    currencyOptions: currencyOptions,
    tagLabels: tagLabels,
    paymentLabels: paymentLabels,
    onPickPeriod: (current) async {
      final picked = await showPeriodPicker(
        context,
        initial: DatePeriod(from: current.from, to: current.to),
      );
      if (picked == null) return null;
      return current.copyWith(
        from: picked.from,
        to: picked.to,
        clearFrom: picked.from == null,
        clearTo: picked.to == null,
      );
    },
    onPickTags: (current) async {
      final selected = await showExpenseTagFilterDialog(
        context,
        tags: tags,
        initialSelection: current.tagIds,
      );
      if (selected == null) return null;
      return current.copyWith(tagIds: selected);
    },
    onPickPayment: (current) async {
      final selected = await showExpensePaymentFilterDialog(
        context,
        methods: paymentMethods,
        initialSelection: current.paymentMethodIds,
      );
      if (selected == null) return null;
      return current.copyWith(paymentMethodIds: selected);
    },
  );
}
