import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_engine.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

/// Pull-to-refresh entry for Dashboard / Expenses.
///
/// No-ops when a modal/sheet is open, Drive sync is not configured, or a
/// sync is already running. Outcomes (toasts / schema dialog) are handled by
/// [GoogleDriveSyncToastListener].
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

  await ref.read(googleDriveSyncControllerProvider.notifier).syncNow();
}
