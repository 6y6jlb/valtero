import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/entities/integrations/exchange_rate_api/model/exchange_rate_api_integration.dart';
import 'package:valtero/entities/integrations/telegram/model/telegram_integration.dart';
import 'package:valtero/entities/exchange_rate/model/exchange_rate_provider.dart';
import 'package:valtero/shared/settings/app_settings.dart';

class _FakeDioAdapter implements HttpClientAdapter {
  _FakeDioAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options);
  }
}

class _FakeRateProvider implements ExchangeRateProvider {
  _FakeRateProvider({required this.valid});

  final bool valid;

  @override
  String get id => 'exchangerate_api';

  @override
  bool get requiresApiKey => true;

  @override
  Future<Map<String, double>> fetchRates({
    required String base,
    required List<String> targets,
    String? apiKey,
  }) async =>
      {};

  @override
  Future<bool> validateApiKey(String apiKey) async => valid;
}

void main() {
  group('TelegramIntegration', () {
    test('isConfigured requires enabled + token + chat', () {
      final integration = TelegramIntegration(Dio());
      expect(
        integration.isConfigured(AppSettings.initial()),
        isFalse,
      );
      expect(
        integration.isConfigured(
          AppSettings.initial().copyWith(
            telegramEnabled: true,
            telegramBotToken: '1:token',
            telegramChatId: '42',
          ),
        ),
        isTrue,
      );
    });

    test('testConnection fails when fields empty', () async {
      final integration = TelegramIntegration(Dio());
      final result = await integration.testConnection(AppSettings.initial());
      expect(result.success, isFalse);
      expect(result.messageKey, 'connectionMissingFields');
    });

    test('testConnection succeeds when getMe and getChat ok', () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeDioAdapter((options) async {
        if (options.path.contains('getMe') ||
            options.uri.path.contains('getMe')) {
          return ResponseBody.fromString(
            '{"ok":true,"result":{"id":1}}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString(
          '{"ok":true,"result":{"id":42}}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
      final integration = TelegramIntegration(dio);
      final result = await integration.testConnection(
        AppSettings.initial().copyWith(
          telegramBotToken: '1:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw',
          telegramChatId: '42',
        ),
      );
      expect(result.success, isTrue);
    });

    test('testConnection fails on invalid token', () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeDioAdapter((options) async {
        return ResponseBody.fromString(
          '{"ok":false}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
      final integration = TelegramIntegration(dio);
      final result = await integration.testConnection(
        AppSettings.initial().copyWith(
          telegramBotToken: '1:bad',
          telegramChatId: '42',
        ),
      );
      expect(result.success, isFalse);
      expect(result.messageKey, 'connectionInvalidToken');
    });
  });

  group('ExchangeRateApiIntegration', () {
    test('isConfigured when api key present', () {
      final integration = ExchangeRateApiIntegration(
        _FakeRateProvider(valid: true),
      );
      expect(integration.isConfigured(AppSettings.initial()), isFalse);
      expect(
        integration.isConfigured(
          AppSettings.initial().copyWith(exchangeRateApiKey: 'key'),
        ),
        isTrue,
      );
    });

    test('testApiKey maps validate result', () async {
      final ok = ExchangeRateApiIntegration(_FakeRateProvider(valid: true));
      final bad = ExchangeRateApiIntegration(_FakeRateProvider(valid: false));
      expect((await ok.testApiKey('abc')).success, isTrue);
      expect((await bad.testApiKey('abc')).success, isFalse);
      expect((await ok.testApiKey('')).messageKey, 'connectionMissingFields');
    });
  });
}
