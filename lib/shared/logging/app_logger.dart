import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:valtero/shared/logging/log_file_header.dart';
import 'package:valtero/shared/logging/log_redactor.dart';

enum LogLevel { debug, info, warning, error }

/// Optional version / account for log banners (ids come from [AppLogger]).
class LogContextHints {
  final String? appVersion;
  final String? accountEmail;

  const LogContextHints({this.appVersion, this.accountEmail});
}

typedef LogContextResolver = LogContextHints Function();

/// File-backed app logger. Error/warning always persist; info/debug only when
/// [debugEnabled] is true. All messages pass through [LogRedactor].
class AppLogger {
  static const maxBytes = 1024 * 1024; // 1 MiB
  static const keepTailBytes = 512 * 1024;
  static const _installIdFileName = 'install.id';

  bool debugEnabled;

  /// Supplies app version + account email for session/export banners.
  LogContextResolver? contextResolver;

  File? _file;
  Future<void> _writeQueue = Future.value();
  bool _initialized = false;
  bool _sessionHeaderWritten = false;
  late final String _sessionId = newLogCorrelationId();
  String? _installId;

  AppLogger({
    this.debugEnabled = false,
    this.contextResolver,
  });

  String get sessionId => _sessionId;

  String? get installId => _installId;

  Future<void> init() async {
    if (_initialized) return;
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'logs'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _installId = await _readOrCreateInstallId(dir);
    _file = File(p.join(dir.path, 'app.log'));
    if (!await _file!.exists()) {
      await _file!.create();
    }
    _initialized = true;
    await _ensureSessionHeader();
  }

  File? get logFile => _file;

  Future<void> debug(String message, {Object? error, StackTrace? stackTrace}) {
    return _log(LogLevel.debug, message, error: error, stackTrace: stackTrace);
  }

  Future<void> info(String message, {Object? error, StackTrace? stackTrace}) {
    return _log(LogLevel.info, message, error: error, stackTrace: stackTrace);
  }

  Future<void> warning(String message, {Object? error, StackTrace? stackTrace}) {
    return _log(LogLevel.warning, message, error: error, stackTrace: stackTrace);
  }

  Future<void> error(String message, {Object? error, StackTrace? stackTrace}) {
    return _log(LogLevel.error, message, error: error, stackTrace: stackTrace);
  }

  Future<String> readAll() async {
    await init();
    final file = _file;
    if (file == null || !await file.exists()) return '';
    return file.readAsString();
  }

  /// Log body wrapped with a fresh export banner (for share / clipboard).
  Future<String> readAllForExport() async {
    final body = await readAll();
    final banner = _bannerFor('export');
    if (banner == null || banner.isEmpty) return body;
    if (body.trim().isEmpty) return banner;
    return '$banner\n$body';
  }

  Future<void> clear() async {
    await init();
    final file = _file;
    if (file == null) return;
    await file.writeAsString('');
    _sessionHeaderWritten = false;
    await _ensureSessionHeader(kind: 'cleared');
  }

  Future<void> _ensureSessionHeader({String kind = 'session'}) async {
    if (_sessionHeaderWritten) return;
    final banner = _bannerFor(kind);
    if (banner == null || banner.isEmpty) {
      _sessionHeaderWritten = true;
      return;
    }
    final file = _file;
    if (file == null) return;
    try {
      await file.writeAsString(banner, mode: FileMode.append, flush: true);
      _sessionHeaderWritten = true;
    } catch (_) {
      // Never let logging crash the app.
    }
  }

  String? _bannerFor(String kind) {
    LogContextHints hints = const LogContextHints();
    try {
      hints = contextResolver?.call() ?? const LogContextHints();
    } catch (_) {
      hints = const LogContextHints();
    }
    return buildLogFileMetadata(
      installId: _installId ?? 'unknown',
      sessionId: _sessionId,
      kind: kind,
      accountEmail: hints.accountEmail,
      appVersion: hints.appVersion,
    ).toBanner();
  }

  Future<String> _readOrCreateInstallId(Directory dir) async {
    final file = File(p.join(dir.path, _installIdFileName));
    try {
      if (await file.exists()) {
        final existing = (await file.readAsString()).trim();
        if (existing.isNotEmpty) return existing;
      }
      final id = newLogCorrelationId();
      await file.writeAsString(id, flush: true);
      return id;
    } catch (_) {
      return newLogCorrelationId();
    }
  }

  Future<void> _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level == LogLevel.debug || level == LogLevel.info) {
      if (!debugEnabled) return Future.value();
    }
    _writeQueue = _writeQueue.then((_) async {
      await _append(level, message, error: error, stackTrace: stackTrace);
    });
    return _writeQueue;
  }

  Future<void> _append(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) async {
    try {
      await init();
      final file = _file;
      if (file == null) return;

      final buf = StringBuffer();
      buf.write(DateTime.now().toUtc().toIso8601String());
      buf.write(' [${level.name.toUpperCase()}] ');
      buf.write(LogRedactor.redact(message));
      if (error != null) {
        buf.write(' | ');
        buf.write(LogRedactor.redact(error.toString()));
      }
      if (stackTrace != null) {
        buf.write('\n');
        buf.write(LogRedactor.redact(stackTrace.toString()));
      }
      buf.writeln();

      await file.writeAsString(buf.toString(), mode: FileMode.append, flush: true);
      await _rotateIfNeeded(file);
    } catch (_) {
      // Never let logging crash the app.
    }
  }

  Future<void> _rotateIfNeeded(File file) async {
    final length = await file.length();
    if (length <= maxBytes) return;
    final bytes = await file.readAsBytes();
    final start = bytes.length - keepTailBytes;
    final tail = bytes.sublist(start < 0 ? 0 : start);
    // Align to next newline so we don't start mid-line.
    var offset = 0;
    while (offset < tail.length && tail[offset] != 0x0a) {
      offset++;
    }
    if (offset < tail.length) offset++;
    // Keep correlation after rotation.
    final banner = _bannerFor('session');
    final rebuilt = StringBuffer();
    if (banner != null) rebuilt.write(banner);
    rebuilt.write(String.fromCharCodes(tail.sublist(offset)));
    await file.writeAsString(rebuilt.toString(), flush: true);
    _sessionHeaderWritten = true;
  }
}
