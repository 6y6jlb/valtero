import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Alert-colored warning icon for rows that share a soft-duplicate fingerprint.
class PossibleDuplicateBadge extends StatelessWidget {
  final double size;

  const PossibleDuplicateBadge({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Tooltip(
      message: l10n.possibleDuplicateTooltip,
      child: Icon(
        Icons.warning_amber_rounded,
        size: size,
        color: theme.colorScheme.error,
      ),
    );
  }
}
