import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_engine.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_messages.dart';
import 'package:valtero/features/google_drive_sync/ui/google_drive_remote_newer_schema_dialog.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_toast.dart';

/// Global listener that surfaces Google Drive sync progress and outcomes via
/// top toasts. Mount once near [MaterialApp] so an [Overlay] is available.
class GoogleDriveSyncToastListener extends ConsumerStatefulWidget {
  final Widget child;

  const GoogleDriveSyncToastListener({super.key, required this.child});

  @override
  ConsumerState<GoogleDriveSyncToastListener> createState() =>
      _GoogleDriveSyncToastListenerState();
}

class _GoogleDriveSyncToastListenerState
    extends ConsumerState<GoogleDriveSyncToastListener> {
  GoogleDriveSyncStatus? _previousStatus;

  @override
  Widget build(BuildContext context) {
    ref.listen(googleDriveSyncControllerProvider, (previous, next) {
      final l10n = AppLocalizations.of(context)!;
      final prevStatus = previous?.status ?? _previousStatus;

      if (next.status == GoogleDriveSyncStatus.syncing) {
        showAppToast(
          context,
          l10n.googleDriveSyncInProgress,
          variant: AppToastVariant.loading,
          persistent: true,
        );
      } else if (prevStatus == GoogleDriveSyncStatus.syncing) {
        if (next.status == GoogleDriveSyncStatus.success) {
          final result = next.lastResult;
          if (result != null) {
            showAppToast(
              context,
              googleDriveSyncSuccessMessage(l10n, result),
              variant: AppToastVariant.success,
            );
          }
        } else if (next.status == GoogleDriveSyncStatus.error ||
            next.status == GoogleDriveSyncStatus.needsPassphrase) {
          final result = next.lastResult;
          if (result != null && result.messageKey != 'sync_in_progress') {
            final message = googleDriveSyncResultMessage(l10n, result);
            if (result.messageKey == 'remote_newer_schema') {
              // ignore: unawaited_futures
              showGoogleDriveRemoteNewerSchemaDialog(context, message: message);
            } else if (!needsGoogleReauth(result.messageKey)) {
              showAppToast(context, message);
            }
          }
        }
      }

      _previousStatus = next.status;
    });

    return widget.child;
  }
}
