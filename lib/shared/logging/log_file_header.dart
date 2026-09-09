import 'dart:io';
import 'dart:math';

import 'package:valtero/shared/database/schema_version.dart';

/// Stable product code written into log headers (not a display name).
const String kAppLogProductCode = 'valtero';

/// Compile-time version from `--dart-define=APP_VERSION=…` (may be empty).
const String kAppLogBuildVersion = String.fromEnvironment('APP_VERSION');

/// Snapshot of non-secret context for a log session / export banner.
class LogFileMetadata {
  final String productCode;
  final String appVersion;
  final int schemaVersion;
  final String platform;
  final String locale;
  final String installId;
  final String sessionId;
  final String? accountEmail;
  final DateTime at;
  final String kind; // `session` | `export` | `cleared`

  const LogFileMetadata({
    required this.productCode,
    required this.appVersion,
    required this.schemaVersion,
    required this.platform,
    required this.locale,
    required this.installId,
    required this.sessionId,
    required this.accountEmail,
    required this.at,
    required this.kind,
  });

  /// Multi-line banner appended to `app.log` (and prepended on export).
  String toBanner() {
    final account = (accountEmail == null || accountEmail!.trim().isEmpty)
        ? '(none)'
        : accountEmail!.trim();
    final version =
        appVersion.trim().isEmpty ? '(unknown)' : appVersion.trim();
    final buf = StringBuffer()
      ..writeln('======== $productCode log $kind ========')
      ..writeln('product=$productCode')
      ..writeln('version=$version')
      ..writeln('schema=$schemaVersion')
      ..writeln('platform=$platform')
      ..writeln('locale=$locale')
      ..writeln('at=${at.toUtc().toIso8601String()}')
      ..writeln('installId=$installId')
      ..writeln('sessionId=$sessionId')
      ..writeln('account=$account')
      ..writeln('=====================================');
    return buf.toString();
  }
}

String logFilePlatformLabel() {
  if (Platform.isAndroid) return 'android';
  if (Platform.isLinux) return 'linux';
  if (Platform.isWindows) return 'windows';
  if (Platform.isMacOS) return 'macos';
  if (Platform.isIOS) return 'ios';
  return 'other';
}

/// Short hex id (16 chars) — no new uuid dependency.
String newLogCorrelationId([Random? random]) {
  final r = random ?? Random.secure();
  final bytes = List<int>.generate(8, (_) => r.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

LogFileMetadata buildLogFileMetadata({
  required String installId,
  required String sessionId,
  required String kind,
  String? accountEmail,
  String? appVersion,
  DateTime? at,
}) {
  final version = (appVersion ?? kAppLogBuildVersion).trim();
  return LogFileMetadata(
    productCode: kAppLogProductCode,
    appVersion: version.isEmpty ? '(unknown)' : version,
    schemaVersion: kAppSchemaVersion,
    platform: logFilePlatformLabel(),
    locale: Platform.localeName,
    installId: installId,
    sessionId: sessionId,
    accountEmail: accountEmail,
    at: at ?? DateTime.now().toUtc(),
    kind: kind,
  );
}
