import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:valtero/shared/logging/log_redactor.dart';

enum LogLevel { debug, info, warning, error }

/// File-backed app logger. Error/warning always persist; info/debug only when
/// [debugEnabled] is true. All messages pass through [LogRedactor].
class AppLogger {
  static const maxBytes = 1024 * 1024; // 1 MiB
  static const keepTailBytes = 512 * 1024;

  bool debugEnabled;
  File? _file;
  Future<void> _writeQueue = Future.value();
  bool _initialized = false;

  AppLogger({this.debugEnabled = false});

  Future<void> init() async {
    if (_initialized) return;
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'logs'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _file = File(p.join(dir.path, 'app.log'));
    if (!await _file!.exists()) {
      await _file!.create();
    }
    _initialized = true;
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

  Future<void> clear() async {
    await init();
    final file = _file;
    if (file == null) return;
    await file.writeAsString('');
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
    await file.writeAsBytes(tail.sublist(offset), flush: true);
  }
}
