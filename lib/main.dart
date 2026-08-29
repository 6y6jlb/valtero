import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/app/app.dart';
import 'package:valtero/app/app_initializer.dart';
import 'package:valtero/shared/logging/logging_providers.dart';

Future<void> main() async {
  await AppInitializer.init();
  final container = ProviderContainer();
  final logger = container.read(appLoggerProvider);
  await logger.init();

  FlutterError.onError = (details) {
    // Always persist Flutter framework errors.
    // ignore: unawaited_futures
    logger.error(
      'FlutterError: ${details.exceptionAsString()}',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    // ignore: unawaited_futures
    logger.error('Uncaught async error', error: error, stackTrace: stack);
    return true;
  };

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const App(),
    ),
  );
}
