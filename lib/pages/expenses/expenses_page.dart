import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/model/expense_list_query.dart';
import 'package:valtero/features/expenses_list/model/expense_list_selection.dart';
import 'package:valtero/features/expenses_list/model/transaction_direction.dart';
import 'package:valtero/features/expenses_list/ui/cash_flow_list_body.dart';
import 'package:valtero/features/expenses_list/ui/expense_bulk_fab_actions.dart';
import 'package:valtero/features/expenses_list/ui/expenses_sheet.dart';
import 'package:valtero/features/expenses_list/ui/income_list_body.dart';
import 'package:valtero/features/expenses_list/ui/operation_direction_tabs.dart';
import 'package:valtero/features/google_drive_sync/ui/google_drive_sync_app_bar_button.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/widgets/app_page_scaffold.dart';

class ExpensesPage extends ConsumerStatefulWidget {
  final ExpenseListQuery? initial;
  final TransactionDirection initialDirection;

  const ExpensesPage({
    super.key,
    this.initial,
    this.initialDirection = TransactionDirection.expenses,
  });

  static Future<void> open(
    BuildContext context, {
    ExpenseListQuery? initial,
    TransactionDirection direction = TransactionDirection.expenses,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ExpensesPage(initial: initial, initialDirection: direction),
      ),
    );
  }

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  late TransactionDirection _direction;

  @override
  void initState() {
    super.initState();
    _direction = widget.initialDirection;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tzId =
        ref.watch(appSettingsProvider).value?.timeZoneId ?? kSystemTimeZoneId;
    final hasSelection = _direction == TransactionDirection.expenses &&
        ref.watch(expenseListSelectionProvider).isNotEmpty;
    final initialQuery =
        widget.initial ?? ExpenseListQuery.sessionDefaults(timeZoneId: tzId);

    final Widget body = switch (_direction) {
      TransactionDirection.expenses => ExpensesSheetBody(
          initial: initialQuery,
          showTitleBar: false,
        ),
      TransactionDirection.income => IncomeListBody(initial: initialQuery),
      TransactionDirection.cashFlow => CashFlowListBody(initial: initialQuery),
    };

    final title = switch (_direction) {
      TransactionDirection.expenses => l10n.navExpenses,
      TransactionDirection.income => l10n.navIncome,
      TransactionDirection.cashFlow => l10n.directionCashFlow,
    };

    return AppPageScaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const [
          GoogleDriveSyncAppBarButton(),
        ],
      ),
      addOperationHeroTag: 'expenses_add_operation',
      extraFabs: [
        if (hasSelection) const ExpenseBulkFabActions(),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: OperationDirectionTabs(
              selected: _direction,
              onChanged: (next) => setState(() => _direction = next),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
