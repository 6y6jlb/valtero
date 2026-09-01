import 'package:flutter/material.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/features/expenses_list/ui/expense_delete_flow.dart';
import 'package:valtero/features/add_expense/ui/add_expense_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';
import 'package:valtero/widgets/date_text.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/money_text.dart';

Future<void> showExpenseDetailSheet(
  BuildContext context, {
  required Expense expense,
  String? paymentLabel,
  String? countryLabel,
  String? tagsLabel,
  required VoidCallback onEdit,
  required Future<bool> Function() onDelete,
}) {
  return showAppModalSheet<void>(
    context: context,
    initialChildSize: 0.55,
    minChildSize: 0.35,
    maxChildSize: 0.9,
    child: _ExpenseDetailSheet(
      expense: expense,
      paymentLabel: paymentLabel,
      countryLabel: countryLabel,
      tagsLabel: tagsLabel,
      onEdit: onEdit,
      onDelete: onDelete,
    ),
  );
}


/// Opens the expense detail sheet, resolving payment/country/tags labels from maps.
Future<void> openExpenseDetail(
  BuildContext context,
  WidgetRef ref, {
  required Expense expense,
  required Map<int, List<int>> expenseTags,
  required Map<int, String> tagLabels,
  required Map<int, String> paymentLabels,
}) {
  final lang = Localizations.localeOf(context).languageCode;
  final paymentLabel = expense.paymentMethodId == null
      ? null
      : paymentLabels[expense.paymentMethodId!];
  final countryLabel = expense.countryCode == null || expense.countryCode!.isEmpty
      ? null
      : countryDisplayName(expense.countryCode!, languageCode: lang);
  final tagIds = expenseTags[expense.id] ?? const <int>[];
  final tagsLabel =
      tagIds.isEmpty ? null : tagIds.map((id) => tagLabels[id] ?? '?').join(', ');

  return showExpenseDetailSheet(
    context,
    expense: expense,
    paymentLabel: paymentLabel,
    countryLabel: countryLabel,
    tagsLabel: tagsLabel,
    onEdit: () => showAddExpenseSheet(context, expense: expense),
    onDelete: () => confirmAndDeleteExpense(
      context,
      ref,
      expense.id,
      expense: expense,
    ),
  );
}


class _ExpenseDetailSheet extends ConsumerWidget {
  final Expense expense;
  final String? paymentLabel;
  final String? countryLabel;
  final String? tagsLabel;
  final VoidCallback onEdit;
  final Future<bool> Function() onDelete;

  const _ExpenseDetailSheet({
    required this.expense,
    required this.paymentLabel,
    required this.countryLabel,
    required this.tagsLabel,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final note = expense.note?.trim();
    final hasDistinctOriginal =
        expense.originalAmountMinor != expense.storedAmountMinor ||
            expense.originalCurrencyCode.toUpperCase() !=
                expense.storedCurrencyCode.toUpperCase();

    return AppSheetScaffold(
      header: AppSheetHeader(
        title: l10n.expenseDetails,
        centered: true,
      ),
      actions: AppSheetActionsBar(
        children: [
          AppCloseIconButton(
            onPressed: () => Navigator.pop(context),
          ),
          AppOutlinedButton(
            label: l10n.delete,
            icon: Icons.delete_outline,
            destructive: true,
            onPressed: () async {
              final deleted = await onDelete();
              if (deleted && context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          AppFilledButton(
            label: l10n.editExpense,
            icon: Icons.check,
            onPressed: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
        ],
      ),
      children: [
        _DetailRow(
          label: l10n.columnDate,
          child: DateText(instant: expense.occurredAt),
        ),
        _DetailRow(
          label: l10n.amount,
          child: MoneyText(
            amountMinor: expense.storedAmountMinor,
            currencyCode: expense.storedCurrencyCode,
            style: theme.textTheme.titleMedium,
          ),
        ),
        if (hasDistinctOriginal)
          _DetailRow(
            label: l10n.columnOriginalAmount,
            child: MoneyText(
              amountMinor: expense.originalAmountMinor,
              currencyCode: expense.originalCurrencyCode,
            ),
          ),
        if (expense.rateUsed != null)
          _DetailRow(
            label: l10n.rate,
            child: Text(expense.rateUsed!.toString()),
          ),
        _DetailRow(
          label: l10n.paymentMethod,
          child: Text(
            (paymentLabel != null && paymentLabel!.isNotEmpty)
                ? paymentLabel!
                : l10n.paymentMethodNone,
          ),
        ),
        _DetailRow(
          label: l10n.country,
          child: Row(
            children: [
              if (expense.countryCode != null &&
                  expense.countryCode!.isNotEmpty) ...[
                FlagIcon.country(expense.countryCode, size: 18),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  (countryLabel != null && countryLabel!.isNotEmpty)
                      ? countryLabel!
                      : '—',
                ),
              ),
            ],
          ),
        ),
        _DetailRow(
          label: l10n.columnTags,
          child: Text(
            (tagsLabel != null && tagsLabel!.isNotEmpty)
                ? tagsLabel!
                : l10n.untagged,
          ),
        ),
        if (note != null && note.isNotEmpty)
          _DetailRow(
            label: l10n.note,
            child: Text(note),
          ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _DetailRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
