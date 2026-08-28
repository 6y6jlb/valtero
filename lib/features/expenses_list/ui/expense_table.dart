import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/money_text.dart';

class ExpenseTable extends StatelessWidget {
  final List<Expense> items;
  final Map<int, List<int>> expenseTags;
  final Map<int, String> tagLabels;
  final Map<int, String> paymentLabels;
  final String untaggedLabel;
  final String? displayCurrency;
  final int? Function(Expense expense) convertedMinor;
  final ValueChanged<int> onDelete;
  final ValueChanged<Expense>? onEdit;

  const ExpenseTable({
    super.key,
    required this.items,
    required this.expenseTags,
    required this.tagLabels,
    this.paymentLabels = const {},
    required this.untaggedLabel,
    required this.displayCurrency,
    required this.convertedMinor,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text(l10n.columnDate, style: headerStyle)),
              Expanded(
                flex: 3,
                child: Text(l10n.columnAmount, style: headerStyle),
              ),
              Expanded(
                flex: 2,
                child: Text(l10n.paymentMethod, style: headerStyle),
              ),
              Expanded(
                flex: 2,
                child: Text(l10n.country, style: headerStyle),
              ),
              Expanded(
                flex: 3,
                child: Text(l10n.columnTags, style: headerStyle),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
        const Divider(height: 1),
        for (final expense in items)
          ExpenseTableRow(
            expense: expense,
            tagLabel: _tagLabel(expense.id),
            paymentLabel: expense.paymentMethodId == null
                ? l10n.paymentMethodNone
                : (paymentLabels[expense.paymentMethodId!] ??
                    l10n.paymentMethodNone),
            displayCurrency: displayCurrency,
            convertedAmountMinor: convertedMinor(expense),
            onDelete: () => onDelete(expense.id),
            onEdit: onEdit == null ? null : () => onEdit!(expense),
          ),
      ],
    );
  }

  String _tagLabel(int expenseId) {
    final ids = expenseTags[expenseId] ?? const <int>[];
    if (ids.isEmpty) return untaggedLabel;
    return ids.map((id) => tagLabels[id] ?? '?').join(', ');
  }
}

class ExpenseTableRow extends ConsumerWidget {
  final Expense expense;
  final String tagLabel;
  final String paymentLabel;
  final String? displayCurrency;
  final int? convertedAmountMinor;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const ExpenseTableRow({
    super.key,
    required this.expense,
    required this.tagLabel,
    required this.paymentLabel,
    required this.displayCurrency,
    required this.convertedAmountMinor,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final date =
        '${expense.occurredAt.year}-'
        '${expense.occurredAt.month.toString().padLeft(2, '0')}-'
        '${expense.occurredAt.day.toString().padLeft(2, '0')}';
    final showConverted =
        displayCurrency != null && convertedAmountMinor != null;
    final countryCode = expense.countryCode;
    final countryLabel = countryCode == null || countryCode.isEmpty
        ? l10n.tagKindUnspecifiedCountry
        : countryDisplayName(countryCode, languageCode: lang);

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(date, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MoneyText(
                    amountMinor: showConverted
                        ? convertedAmountMinor!
                        : expense.storedAmountMinor,
                    currencyCode: showConverted
                        ? displayCurrency!
                        : expense.storedCurrencyCode,
                    style: theme.textTheme.titleSmall,
                  ),
                  if (showConverted &&
                      expense.storedCurrencyCode.toUpperCase() !=
                          displayCurrency!.toUpperCase())
                    MoneyText(
                      amountMinor: expense.storedAmountMinor,
                      currencyCode: expense.storedCurrencyCode,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              paymentLabel,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                if (countryCode != null && countryCode.isNotEmpty) ...[
                  FlagIcon.country(countryCode, size: 16),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    countryLabel,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              tagLabel,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );

    return Column(
      children: [
        if (onEdit == null) row else InkWell(onTap: onEdit, child: row),
        const Divider(height: 1),
      ],
    );
  }
}
