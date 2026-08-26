import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/app/app.dart';
import 'package:valtero/app/app_initializer.dart';

Future<void> main() async {
  await AppInitializer.init();
  runApp(const ProviderScope(child: App()));
}
