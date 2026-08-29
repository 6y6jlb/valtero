import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Floating icon action strip shown when one or more expenses are selected.
class ExpenseBulkActionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onDelete;
  final VoidCallback? onChangeTags;
  final VoidCallback? onChangeCountry;
  final VoidCallback? onChangeCurrency;

  const ExpenseBulkActionBar({
    super.key,
    required this.selectedCount,
    this.onDelete,
    this.onChangeTags,
    this.onChangeCountry,
    this.onChangeCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: IconTheme(
        data: IconThemeData(color: theme.colorScheme.onPrimaryContainer),
        child: DefaultTextStyle(
          style: theme.textTheme.labelLarge!.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(l10n.bulkSelectedCount(selectedCount)),
                ),
                IconButton(
                  tooltip: l10n.bulkChangeTags,
                  onPressed: onChangeTags,
                  icon: const Icon(Icons.label_outline),
                ),
                IconButton(
                  tooltip: l10n.bulkChangeCountry,
                  onPressed: onChangeCountry,
                  icon: const Icon(Icons.flag_outlined),
                ),
                IconButton(
                  tooltip: l10n.bulkChangeCurrency,
                  onPressed: onChangeCurrency,
                  icon: const Icon(Icons.currency_exchange),
                ),
                IconButton(
                  tooltip: l10n.delete,
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
