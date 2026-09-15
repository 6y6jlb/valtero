import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_engine.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_messages.dart';
import 'package:valtero/features/google_drive_sync/ui/google_drive_remote_newer_schema_dialog.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/widgets/app_toast.dart';

/// Pull-to-refresh entry for Dashboard / Expenses.
///
/// No-ops when a modal/sheet is open, Drive sync is not configured, or a
/// sync is already running. Surfaces failures via toast (or a blocking dialog
/// for remote_newer_schema).
Future<void> triggerPullToRefreshSync(
  BuildContext context,
  WidgetRef ref,
) async {
  final route = ModalRoute.of(context);
  if (route == null || !route.isCurrent) return;

  final settings = ref.read(appSettingsProvider).value;
  final integration = ref.read(googleDriveSyncIntegrationProvider);
  if (settings == null || !integration.isConfigured(settings)) return;

  if (ref.read(googleDriveSyncControllerProvider).status ==
      GoogleDriveSyncStatus.syncing) {
    return;
  }

  final result =
      await ref.read(googleDriveSyncControllerProvider.notifier).syncNow();
  if (!context.mounted || result.success) return;
  final l10n = AppLocalizations.of(context)!;
  final message = googleDriveSyncResultMessage(l10n, result);
  if (result.messageKey == 'remote_newer_schema') {
    await showGoogleDriveRemoteNewerSchemaDialog(context, message: message);
    return;
  }
  showAppToast(context, message);
}
