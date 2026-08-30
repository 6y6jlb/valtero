import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';

Future<void> showGoogleDriveSyncHelpSheet(BuildContext context) {
  return showAppModalSheet(
    context: context,
    initialChildSize: 0.85,
    child: const GoogleDriveSyncHelpSheet(),
  );
}

class GoogleDriveSyncHelpSheet extends StatelessWidget {
  const GoogleDriveSyncHelpSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scrollController = PrimaryScrollController.maybeOf(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Text(l10n.googleDriveHelpTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Text(
          l10n.googleDriveHelpSameAccountTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(l10n.googleDriveHelpSameAccountBody),
        const SizedBox(height: 20),
        Text(
          l10n.googleDriveHelpCrossAccountTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(l10n.googleDriveHelpCrossAccountBody),
        const SizedBox(height: 20),
        Material(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.googleDriveHelpPassphraseNote),
                const SizedBox(height: 8),
                Text(l10n.googleDriveHelpRegenNote),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
