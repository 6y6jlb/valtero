import 'dart:io';

import 'package:valtero/entities/integrations/model/app_integration.dart';
import 'package:valtero/shared/settings/app_settings.dart';

/// Integration that can receive an exported file (e.g. Telegram).
abstract class ExportDestinationIntegration implements AppIntegration {
  Future<void> exportFile({
    required File file,
    required String filename,
    required AppSettings settings,
  });
}
