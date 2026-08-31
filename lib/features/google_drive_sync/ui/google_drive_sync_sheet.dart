import 'package:flutter/material.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_drive_sync_integration.dart';
import 'package:valtero/features/google_drive_sync/ui/google_drive_sync_quick_card.dart';
import 'package:valtero/features/integrations/model/integration_ui_meta.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';

/// Opens the Google Drive sync quick card in a modal sheet.
Future<void> showGoogleDriveSyncSheet(BuildContext context) {
  return showAppModalSheet<void>(
    context: context,
    initialChildSize: 0.45,
    minChildSize: 0.3,
    maxChildSize: 0.85,
    child: const _GoogleDriveSyncSheetBody(),
  );
}

class _GoogleDriveSyncSheetBody extends StatelessWidget {
  const _GoogleDriveSyncSheetBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final meta = integrationUiMeta(kGoogleDriveSyncIntegrationId);
    final scrollController = PrimaryScrollController.maybeOf(context);

    return ListView(
      controller: scrollController,
      padding: appModalScrollPadding(context),
      children: [
        Text(meta.title(l10n), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        const GoogleDriveSyncQuickCard(),
      ],
    );
  }
}
