import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Baked at build/run via `--dart-define=APP_VERSION=…` (from `VERSION` file).
const String _buildTimeAppVersion = String.fromEnvironment('APP_VERSION');

String _formatVersionLabel(String version, String buildNumber) {
  final trimmedVersion = version.trim();
  final trimmedBuild = buildNumber.trim();
  if (trimmedVersion.isEmpty) {
    throw StateError('Empty app version');
  }
  if (trimmedBuild.isEmpty) {
    return 'v$trimmedVersion';
  }
  return 'v$trimmedVersion+$trimmedBuild';
}

/// In-app version label.
///
/// Prefer compile-time `APP_VERSION` from Make/release scripts so all platforms
/// show the same `VERSION` file value. Fall back to [PackageInfo] for bare
/// `flutter run` without our wrappers (uses synced `pubspec.yaml`).
final appVersionLabelProvider = FutureProvider<String>((ref) async {
  if (_buildTimeAppVersion.isNotEmpty) {
    return 'v$_buildTimeAppVersion';
  }

  final info = await PackageInfo.fromPlatform();
  return _formatVersionLabel(info.version, info.buildNumber);
});
