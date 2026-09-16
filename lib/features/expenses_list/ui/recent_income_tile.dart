import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/expenses_list/ui/operation_leading_icon.dart';
import 'package:valtero/features/expenses_list/ui/possible_duplicate_badge.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/money_text.dart';

/// Compact recent-operation row for income (mirrors [RecentExpenseTile]
/// with a tinted amount to distinguish it from expenses).
class RecentIncomeTile extends ConsumerWidget {
  final Income income;
  final String? paymentLabel;
  final String? countryLabel;
  final String? tagsLabel;
  final String? tagIconKey;
  final String? paymentIconKey;
  final String? paymentStableKey;
  final bool showPossibleDuplicate;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RecentIncomeTile({
    super.key,
    required this.income,
    required this.paymentLabel,
    required this.countryLabel,
    required this.tagsLabel,
    this.tagIconKey,
    this.paymentIconKey,
    this.paymentStableKey,
    this.showPossibleDuplicate = false,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final positiveColor = theme.colorScheme.tertiary;
    final parts = <String>[
      if (paymentLabel != null && paymentLabel!.isNotEmpty) paymentLabel!,
      if (countryLabel != null && countryLabel!.isNotEmpty) countryLabel!,
      if (tagsLabel != null && tagsLabel!.isNotEmpty) tagsLabel!,
    ];
    final showOriginal = _hasDistinctOriginal(income);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: OperationLeadingIcon.maybe(
        tagIconKey: tagIconKey,
        currencyCode: income.storedCurrencyCode,
        paymentIconKey: paymentIconKey,
        paymentStableKey: paymentStableKey,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: MoneyText(
                  amountMinor: income.storedAmountMinor,
                  currencyCode: income.storedCurrencyCode,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: positiveColor,
                  ),
                ),
              ),
              if (showPossibleDuplicate) ...[
                const SizedBox(width: 6),
                const PossibleDuplicateBadge(size: 16),
              ],
            ],
          ),
          if (showOriginal)
            MoneyText(
              amountMinor: income.originalAmountMinor,
              currencyCode: income.originalCurrencyCode,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      subtitle: parts.isEmpty
          ? null
          : Text(
              parts.join(' · '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: l10n.editIncome,
            onPressed: onEdit,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            tooltip: l10n.delete,
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

bool _hasDistinctOriginal(Income income) {
  return income.originalAmountMinor != income.storedAmountMinor ||
      income.originalCurrencyCode.toUpperCase() !=
          income.storedCurrencyCode.toUpperCase();
}

String? recentIncomeTagsLabel(
  int incomeId,
  Map<int, List<int>> incomeTags,
  Map<int, String> tagLabels, {
  Map<int, int?> tagParentIds = const {},
}) {
  final ids = incomeTags[incomeId] ?? const <int>[];
  if (ids.isEmpty) return null;
  final combined = formatTagLabelsCombined(ids, tagLabels, tagParentIds);
  return combined.isEmpty ? null : combined;
}
