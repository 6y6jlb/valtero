import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_drive_sync_integration.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/features/google_drive_sync/model/google_drive_sync_engine.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/settings/app_settings.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

/// Debounced push after local DB changes + one-shot pull on launch.
class GoogleDriveSyncScheduler {
  GoogleDriveSyncScheduler(this.ref);

  final Ref ref;
  Timer? _debounce;
  StreamSubscription<dynamic>? _expenseSub;
  StreamSubscription<dynamic>? _ratesSub;
  bool _started = false;
  bool _syncing = false;

  void start() {
    if (_started) return;
    _started = true;
    // ignore: unawaited_futures
    _runSync();

    final db = ref.read(appDatabaseProvider);
    _expenseSub = db.watchExpenses().listen((_) => schedulePush());
    _ratesSub = db.watchAllExchangeRates().listen((_) => schedulePush());
  }

  void schedulePush() {
    final settings = ref.read(appSettingsProvider).value;
    if (settings == null || !_isConfigured(settings)) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 4), () {
      // ignore: unawaited_futures
      _runSync();
    });
  }

  Future<void> _runSync() async {
    if (_syncing) return;
    final settings = ref.read(appSettingsProvider).value;
    if (settings == null || !_isConfigured(settings)) return;
    _syncing = true;
    try {
      await ref.read(googleDriveSyncControllerProvider.notifier).syncNow();
    } finally {
      _syncing = false;
    }
  }

  bool _isConfigured(AppSettings settings) {
    return ref
        .read(isIntegrationConfiguredProvider(kGoogleDriveSyncIntegrationId));
  }

  void dispose() {
    _debounce?.cancel();
    _expenseSub?.cancel();
    _ratesSub?.cancel();
  }
}

final googleDriveSyncSchedulerProvider =
    Provider<GoogleDriveSyncScheduler>((ref) {
  final scheduler = GoogleDriveSyncScheduler(ref);
  ref.onDispose(scheduler.dispose);
  return scheduler;
});
