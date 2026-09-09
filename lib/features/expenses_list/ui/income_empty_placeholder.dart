import 'package:flutter/material.dart';
import 'package:valtero/features/add_income/ui/add_income_sheet.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Compact empty state for the income list (icon + one line + add CTA).
class IncomeEmptyPlaceholder extends StatelessWidget {
  const IncomeEmptyPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.south_west_outlined,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.incomeEmptyTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => showAddIncomeSheet(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.addIncome),
          ),
        ],
      ),
    );
  }
}
