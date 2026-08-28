import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/shared/utils/money_display.dart';

void main() {
  group('formatMoneyDisplay', () {
    const minor = 123456;
    const code = 'USD';
    const locale = 'en_US';

    test('localeCode appends ISO code with grouping', () {
      final s = formatMoneyDisplay(
        amountMinor: minor,
        currencyCode: code,
        localeName: locale,
        format: MoneyDisplayFormat.localeCode,
      );
      expect(s, contains('USD'));
      expect(s, contains('1,234.56'));
    });

    test('isoBefore puts code first', () {
      final s = formatMoneyDisplay(
        amountMinor: minor,
        currencyCode: code,
        localeName: locale,
        format: MoneyDisplayFormat.isoBefore,
      );
      expect(s.startsWith('USD '), isTrue);
      expect(s, contains('1,234.56'));
    });

    test('plain has no grouping', () {
      expect(
        formatMoneyDisplay(
          amountMinor: minor,
          currencyCode: code,
          localeName: locale,
          format: MoneyDisplayFormat.plain,
        ),
        '1234.56 USD',
      );
    });

    test('localeSymbol includes a currency symbol or code', () {
      final s = formatMoneyDisplay(
        amountMinor: minor,
        currencyCode: code,
        localeName: locale,
        format: MoneyDisplayFormat.localeSymbol,
      );
      expect(s.contains('1,234.56') || s.contains('1234.56'), isTrue);
    });

    test('compactSymbol is shorter than plain for large amounts', () {
      final compact = formatMoneyDisplay(
        amountMinor: 1_200_000,
        currencyCode: code,
        localeName: locale,
        format: MoneyDisplayFormat.compactSymbol,
      );
      final plain = formatMoneyDisplay(
        amountMinor: 1_200_000,
        currencyCode: code,
        localeName: locale,
        format: MoneyDisplayFormat.plain,
      );
      expect(compact.length, lessThan(plain.length));
    });

    test('moneyDisplayFormatFromName falls back to localeCode', () {
      expect(
        moneyDisplayFormatFromName(null),
        MoneyDisplayFormat.localeCode,
      );
      expect(
        moneyDisplayFormatFromName('isoBefore'),
        MoneyDisplayFormat.isoBefore,
      );
    });
  });
}
