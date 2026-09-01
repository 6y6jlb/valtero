import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/ui/duplicate_review_sheet.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Tappable banner shown above the expenses listing when soft duplicates exist.
class PossibleDuplicatesBanner extends StatelessWidget {
  final int flaggedCount;

  const PossibleDuplicatesBanner({super.key, required this.flaggedCount});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.55),
      child: InkWell(
        onTap: () => showDuplicateReviewSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.possibleDuplicatesBannerTitle(flaggedCount),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onErrorContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
