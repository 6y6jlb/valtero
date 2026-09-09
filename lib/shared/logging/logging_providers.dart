import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/logging/app_logger.dart';
import 'package:valtero/shared/logging/log_file_header.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_version_provider.dart';

/// Singleton logger. Created once; [debugEnabled] tracks settings via listen.
///
/// Must not [Ref.watch] [appSettingsProvider]: recreating this provider
/// invalidates every integration that depends on it and can trigger
/// `setState() during build` when opening Settings → Integrations.
final appLoggerProvider = Provider<AppLogger>((ref) {
  final logger = AppLogger(
    debugEnabled:
        ref.read(appSettingsProvider).value?.debugLoggingEnabled ?? false,
    contextResolver: () {
      final settings = ref.read(appSettingsProvider).value;
      final versionLabel = ref.read(appVersionLabelProvider);
      // Strip leading `v` from the Settings label so the log stays parseable.
      final version = versionLabel == null
          ? kAppLogBuildVersion
          : (versionLabel.startsWith('v')
              ? versionLabel.substring(1)
              : versionLabel);
      return LogContextHints(
        appVersion: version,
        accountEmail: settings?.googleDriveAccountEmail,
      );
    },
  );
  ref.listen(appSettingsProvider, (_, next) {
    logger.debugEnabled = next.value?.debugLoggingEnabled ?? false;
  });
  // Fire-and-forget init; callers also call init() before read/write.
  // ignore: unawaited_futures
  logger.init();
  return logger;
});
