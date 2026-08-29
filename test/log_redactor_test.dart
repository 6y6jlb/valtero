import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/shared/logging/log_redactor.dart';

void main() {
  test('redacts Telegram bot token shape', () {
    const token = '123456789:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw';
    final out = LogRedactor.redact('token=$token used');
    expect(out.contains(token), isFalse);
    expect(out.contains('[REDACTED_TOKEN]'), isTrue);
  });

  test('redacts ExchangeRate-API URL key segment', () {
    const url =
        'https://v6.exchangerate-api.com/v6/super-secret-key-xyz/latest/USD';
    final out = LogRedactor.redact(url);
    expect(out.contains('super-secret-key-xyz'), isFalse);
    expect(out.contains('[REDACTED_KEY]'), isTrue);
  });

  test('redacts Telegram Bot API URL token', () {
    const url =
        'https://api.telegram.org/bot123456:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw/sendDocument';
    final out = LogRedactor.redact(url);
    expect(out.contains('123456:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw'), isFalse);
    expect(out.contains('[REDACTED_TOKEN]'), isTrue);
  });

  test('redacts sensitive map keys', () {
    final out = LogRedactor.redactMap({
      'telegramBotToken': '123456:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw',
      'exchangeRateApiKey': 'secret-key',
      'chat_id': '-100123',
      'primaryCurrency': 'USD',
    });
    expect(out['telegramBotToken'], '[REDACTED]');
    expect(out['exchangeRateApiKey'], '[REDACTED]');
    expect(out['chat_id'], '[REDACTED]');
    expect(out['primaryCurrency'], 'USD');
  });

  test('redacts query secrets', () {
    final out = LogRedactor.redact(
      'https://example.com/x?api_key=abc123&chat_id=-99&ok=1',
    );
    expect(out.contains('abc123'), isFalse);
    expect(out.contains('-99'), isFalse);
    expect(out.contains('[REDACTED]'), isTrue);
  });
}
