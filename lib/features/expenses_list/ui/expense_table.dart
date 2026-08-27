import 'package:flutter/material.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/money.dart';
import 'package:valtero/widgets/money_text.dart';

class ExpenseTable extends StatelessWidget {
  final List<Expense> items;
  final Map<int, List<int>> expenseTags;
  final Map<int, String> tagLabels;
  final String untaggedLabel;
  final String? displayCurrency;
  final int? Function(Expense expense) convertedMinor;
  final ValueChanged<int> onDelete;

  const ExpenseTable({
    super.key,
    required this.items,
    required this.expenseTags,
    required this.tagLabels,
    required this.untaggedLabel,
    required this.displayCurrency,
    required this.convertedMinor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  l10n.columnDate,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  l10n.columnAmount,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  l10n.columnTags,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
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
            displayCurrency: displayCurrency,
            convertedAmountMinor: convertedMinor(expense),
            onDelete: () => onDelete(expense.id),
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

class ExpenseTableRow extends StatelessWidget {
  final Expense expense;
  final String tagLabel;
  final String? displayCurrency;
  final int? convertedAmountMinor;
  final VoidCallback onDelete;

  const ExpenseTableRow({
    super.key,
    required this.expense,
    required this.tagLabel,
    required this.displayCurrency,
    required this.convertedAmountMinor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date =
        '${expense.occurredAt.year}-'
        '${expense.occurredAt.month.toString().padLeft(2, '0')}-'
        '${expense.occurredAt.day.toString().padLeft(2, '0')}';
    final showConverted =
        displayCurrency != null && convertedAmountMinor != null;

    return Column(
      children: [
        Padding(
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
                        Text(
                          '${Money.formatMinor(expense.storedAmountMinor)} '
                          '${expense.storedCurrencyCode}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text(
                      tagLabel,
                      overflow: TextOverflow.ellipsis,
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
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
        ),
        const Divider(height: 1),
      ],
    );
  }
}
