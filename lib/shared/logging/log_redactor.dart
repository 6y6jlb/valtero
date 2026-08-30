/// Redacts secrets from log lines and maps so credentials never reach disk.
class LogRedactor {
  static const sensitiveKeys = {
    'exchangerateapikey',
    'apikey',
    'api_key',
    'telegrambottoken',
    'bottoken',
    'bot_token',
    'telegramchatid',
    'chatid',
    'chat_id',
    'token',
    'passphrase',
    'password',
    'secret',
    'authorization',
    'googledriverefreshtoken',
    'googledrivesyncpassphrase',
    'refreshtoken',
  };

  /// Telegram bot tokens look like `123456789:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw`
  static final _telegramToken = RegExp(r'\d{6,}:[\w-]{20,}');

  /// ExchangeRate-API path segment: `/v6/<key>/…`
  static final _exchangeRateApiPath = RegExp(
    r'(https?://v6\.exchangerate-api\.com/v6/)[^/\s]+',
    caseSensitive: false,
  );

  /// Telegram Bot API path: `/bot<token>/…`
  static final _telegramBotPath = RegExp(
    r'(https?://api\.telegram\.org/bot)[^/\s]+',
    caseSensitive: false,
  );

  static final _querySecret = RegExp(
    r'([?&](?:token|api_key|apiKey|chat_id|chatId|password|passphrase|secret)=)[^&\s]+',
    caseSensitive: false,
  );

  static String redact(String input) {
    var out = input;
    out = out.replaceAll(_telegramToken, '[REDACTED_TOKEN]');
    out = out.replaceAllMapped(
      _exchangeRateApiPath,
      (m) => '${m[1]}[REDACTED_KEY]',
    );
    out = out.replaceAllMapped(
      _telegramBotPath,
      (m) => '${m[1]}[REDACTED_TOKEN]',
    );
    out = out.replaceAllMapped(
      _querySecret,
      (m) => '${m[1]}[REDACTED]',
    );
    return out;
  }

  static Map<String, Object?> redactMap(Map<String, Object?> input) {
    final out = <String, Object?>{};
    for (final entry in input.entries) {
      final key = entry.key;
      final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '');
      if (sensitiveKeys.contains(normalized) ||
          sensitiveKeys.contains(key.toLowerCase())) {
        out[key] = '[REDACTED]';
        continue;
      }
      final value = entry.value;
      if (value is String) {
        out[key] = redact(value);
      } else if (value is Map<String, Object?>) {
        out[key] = redactMap(value);
      } else {
        out[key] = value;
      }
    }
    return out;
  }
}
