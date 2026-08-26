import 'package:flutter/material.dart';
import 'package:valtero/shared/settings/hive_service.dart';
import 'package:valtero/shared/utils/app_timezone.dart';

class AppInitializer {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await HiveService.init();
    await initTimeZones();
  }
}
