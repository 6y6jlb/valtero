import 'package:flutter/material.dart';
import 'package:valtero/features/about_support/model/release_notes.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_ok_button.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';

Future<void> showReleaseNotesSheet(BuildContext context) {
  return showAppModalSheet<void>(
    context: context,
    initialChildSize: 0.72,
    minChildSize: 0.4,
    maxChildSize: 0.95,
    child: const _ReleaseNotesSheetBody(),
  );
}

class _ReleaseNotesSheetBody extends StatelessWidget {
  const _ReleaseNotesSheetBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AppSheetScaffold(
      header: AppSheetHeader(
        title: l10n.whatsNewTitle,
        description: l10n.whatsNewDescription,
      ),
      actions: const AppSheetActionsBar(children: [AppOkButton()]),
      children: [
        for (var i = 0; i < kAppReleaseNotes.length; i++) ...[
          if (i > 0) const SizedBox(height: 20),
          Text(
            kAppReleaseNotes[i].version,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          for (final line in kAppReleaseNotes[i].lines) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•  ',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Expanded(
                    child: Text(
                      line,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}
