import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Baked at build/run via `--dart-define=APP_VERSION=…` (from `VERSION` file).
/// Use `make run-*` / `build-*` / `release-*` so the Settings label matches [VERSION].
const String _buildTimeAppVersion = String.fromEnvironment('APP_VERSION');

/// In-app version label from compile-time `APP_VERSION` (Make / release scripts).
final appVersionLabelProvider = Provider<String?>((ref) {
  if (_buildTimeAppVersion.isEmpty) {
    return null;
  }
  return 'v$_buildTimeAppVersion';
});
