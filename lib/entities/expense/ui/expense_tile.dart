import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/widgets/money_text.dart';

class ExpenseTile extends ConsumerWidget {
  final Expense expense;
  final String tagLabel;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ExpenseTile({
    super.key,
    required this.expense,
    required this.tagLabel,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = StringBuffer()
      ..write(tagLabel)
      ..write(' · ')
      ..write(
        '${expense.occurredAt.year}-'
        '${expense.occurredAt.month.toString().padLeft(2, '0')}-'
        '${expense.occurredAt.day.toString().padLeft(2, '0')}',
      );
    if (expense.originalCurrencyCode != expense.storedCurrencyCode) {
      subtitle.write(' · orig ');
      subtitle.write(
        formatMoneyOf(
          context,
          ref,
          amountMinor: expense.originalAmountMinor,
          currencyCode: expense.originalCurrencyCode,
        ),
      );
    }

    return ListTile(
      onTap: onTap,
      title: MoneyText(
        amountMinor: expense.storedAmountMinor,
        currencyCode: expense.storedCurrencyCode,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(subtitle.toString()),
      trailing: onDelete == null
          ? null
          : IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
    );
  }
}
