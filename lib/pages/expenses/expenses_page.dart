import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_selection.dart';
import 'package:valtero/features/expenses_list/ui/expense_bulk_fab_actions.dart';
import 'package:valtero/features/expenses_list/ui/expenses_sheet.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/widgets/app_page_scaffold.dart';

class ExpensesPage extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tzId =
        ref.watch(appSettingsProvider).value?.timeZoneId ?? kSystemTimeZoneId;
    final hasSelection = ref.watch(expenseListSelectionProvider).isNotEmpty;

    return AppPageScaffold(
      appBar: AppBar(
        title: Text(l10n.navExpenses),
      ),
      addExpenseHeroTag: 'expenses_add_expense',
      extraFabs: [
        if (hasSelection) const ExpenseBulkFabActions(),
      ],
      body: ExpensesSheetBody(
        initial: initial ?? ExpenseListQuery.sessionDefaults(timeZoneId: tzId),
        showTitleBar: false,
      ),
    );
  }
}
