import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/ui/possible_duplicate_badge.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/money_text.dart';

/// Compact recent-operation row for the dashboard list (date is in section header).
class RecentExpenseTile extends ConsumerWidget {
  final Expense expense;
  final String? paymentLabel;
  final String? countryLabel;
  final String? tagsLabel;
  final bool showPossibleDuplicate;
  final VoidCallback onTap;

  const RecentExpenseTile({
    super.key,
    required this.expense,
    required this.paymentLabel,
    required this.countryLabel,
    required this.tagsLabel,
    this.showPossibleDuplicate = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final parts = <String>[
      if (paymentLabel != null && paymentLabel!.isNotEmpty) paymentLabel!,
      if (countryLabel != null && countryLabel!.isNotEmpty) countryLabel!,
      if (tagsLabel != null && tagsLabel!.isNotEmpty) tagsLabel!,
    ];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: expense.countryCode == null || expense.countryCode!.isEmpty
          ? null
          : FlagIcon.country(expense.countryCode, size: 28),
      title: Row(
        children: [
          Flexible(
            child: MoneyText(
              amountMinor: expense.storedAmountMinor,
              currencyCode: expense.storedCurrencyCode,
              style: theme.textTheme.titleSmall,
            ),
          ),
          if (showPossibleDuplicate) ...[
            const SizedBox(width: 6),
            const PossibleDuplicateBadge(size: 16),
          ],
        ],
      ),
      subtitle: parts.isEmpty
          ? null
          : Text(
              parts.join(' · '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
    );
  }
}

String? recentExpenseTagsLabel(
  int expenseId,
  Map<int, List<int>> expenseTags,
  Map<int, String> tagLabels,
) {
  final ids = expenseTags[expenseId] ?? const <int>[];
  if (ids.isEmpty) return null;
  return ids.map((id) => tagLabels[id] ?? '?').join(', ');
}
