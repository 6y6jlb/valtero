import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/logging/app_logger.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

/// Singleton logger. Created once; [debugEnabled] tracks settings.
final appLoggerProvider = Provider<AppLogger>((ref) {
  final logger = AppLogger(
    debugEnabled:
        ref.watch(appSettingsProvider).value?.debugLoggingEnabled ?? false,
  );
  ref.listen(appSettingsProvider, (_, next) {
    logger.debugEnabled = next.value?.debugLoggingEnabled ?? false;
  });
  // Fire-and-forget init; callers also call init() before read/write.
  // ignore: unawaited_futures
  logger.init();
  return logger;
});
