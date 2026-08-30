import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:valtero/entities/integrations/model/export_destination_integration.dart';
import 'package:valtero/entities/integrations/model/integration_test_result.dart';
import 'package:valtero/shared/logging/app_logger.dart';
import 'package:valtero/shared/settings/app_settings.dart';

const kTelegramIntegrationId = 'telegram';

class TelegramIntegration implements ExportDestinationIntegration {
  final Dio _dio;
  final AppLogger? _logger;

  TelegramIntegration(this._dio, {AppLogger? logger}) : _logger = logger;

  @override
  String get id => kTelegramIntegrationId;

  @override
  bool isConfigured(AppSettings settings) {
    return settings.telegramEnabled &&
        settings.telegramBotToken.trim().isNotEmpty &&
        settings.telegramChatId.trim().isNotEmpty;
  }

  @override
  Future<IntegrationTestResult> testConnection(AppSettings settings) async {
    final token = settings.telegramBotToken.trim();
    final chatId = settings.telegramChatId.trim();
    if (token.isEmpty || chatId.isEmpty) {
      return IntegrationTestResult.fail('connectionMissingFields');
    }
    try {
      final me = await _dio.get<Map<String, dynamic>>(
        'https://api.telegram.org/bot$token/getMe',
      );
      if (me.data?['ok'] != true) {
        // ignore: unawaited_futures
        _logger?.warning('Telegram testConnection: getMe not ok');
        return IntegrationTestResult.fail('connectionInvalidToken');
      }
      final chat = await _dio.get<Map<String, dynamic>>(
        'https://api.telegram.org/bot$token/getChat',
        queryParameters: {'chat_id': chatId},
      );
      if (chat.data?['ok'] != true) {
        // ignore: unawaited_futures
        _logger?.warning('Telegram testConnection: getChat not ok');
        return IntegrationTestResult.fail('connectionInvalidChat');
      }
      return IntegrationTestResult.ok();
    } on DioException catch (e, st) {
      // ignore: unawaited_futures
      _logger?.error(
        'Telegram testConnection failed',
        error: e,
        stackTrace: st,
      );
      return IntegrationTestResult.fail('connectionFailed');
    } catch (e, st) {
      // ignore: unawaited_futures
      _logger?.error(
        'Telegram testConnection failed',
        error: e,
        stackTrace: st,
      );
      return IntegrationTestResult.fail('connectionFailed');
    }
  }

  @override
  Future<void> exportFile({
    required File file,
    required String filename,
    required AppSettings settings,
  }) async {
    if (!isConfigured(settings)) {
      throw StateError('telegram_not_configured');
    }
    final token = settings.telegramBotToken.trim();
    final form = FormData.fromMap({
      'chat_id': settings.telegramChatId.trim(),
      'document': await MultipartFile.fromFile(
        file.path,
        filename: filename.isEmpty ? p.basename(file.path) : filename,
      ),
    });
    await _dio.post(
      'https://api.telegram.org/bot$token/sendDocument',
      data: form,
    );
  }
}
