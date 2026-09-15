import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/shared/utils/money_display.dart';

void main() {
  group('formatMoneyDisplay', () {
    const minor = 123456;
    const code = 'USD';
    const locale = 'en_US';

    test('localeCode appends currency glyph with grouping', () {
      final s = formatMoneyDisplay(
        amountMinor: minor,
        currencyCode: code,
        localeName: locale,
        format: MoneyDisplayFormat.localeCode,
      );
      expect(s, contains(r'$'));
      expect(s, isNot(contains('USD')));
      expect(s, contains('1,234.56'));
    });

    test('isoBefore puts glyph first', () {
      final s = formatMoneyDisplay(
        amountMinor: minor,
        currencyCode: code,
        localeName: locale,
        format: MoneyDisplayFormat.isoBefore,
      );
      expect(s.startsWith(r'$ '), isTrue);
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
      expect(moneyDisplayFormatFromName(null), MoneyDisplayFormat.localeCode);
      expect(
        moneyDisplayFormatFromName('isoBefore'),
        MoneyDisplayFormat.isoBefore,
      );
    });

    test('RUB uses ₽ glyph in en_US and ru for localeCode and localeSymbol', () {
      for (final localeName in ['en_US', 'ru']) {
        for (final format in [
          MoneyDisplayFormat.localeCode,
          MoneyDisplayFormat.localeSymbol,
          MoneyDisplayFormat.isoBefore,
        ]) {
          final s = formatMoneyDisplay(
            amountMinor: minor,
            currencyCode: 'RUB',
            localeName: localeName,
            format: format,
          );
          expect(s, contains('₽'), reason: '$format @ $localeName');
          expect(s, isNot(contains('RUB')), reason: '$format @ $localeName');
        }
        final plain = formatMoneyDisplay(
          amountMinor: minor,
          currencyCode: 'RUB',
          localeName: localeName,
          format: MoneyDisplayFormat.plain,
        );
        expect(plain, contains('RUB'), reason: 'plain @ $localeName');
        expect(plain, isNot(contains('₽')), reason: 'plain @ $localeName');
      }
    });
  });

  group('formatMoneyDisplay hideFraction', () {
    const code = 'USD';
    const locale = 'en_US';

    test('drops decimals for every format', () {
      for (final format in MoneyDisplayFormat.values) {
        final s = formatMoneyDisplay(
          amountMinor: 2000000,
          currencyCode: code,
          localeName: locale,
          format: format,
          hideFraction: true,
        );
        expect(s, isNot(contains('.00')), reason: 'format=$format');
        expect(s, contains('20'), reason: 'format=$format');
      }
    });

    test('drops decimals with grouping for locale-aware formats', () {
      for (final format in [
        MoneyDisplayFormat.localeCode,
        MoneyDisplayFormat.isoBefore,
        MoneyDisplayFormat.localeSymbol,
      ]) {
        final s = formatMoneyDisplay(
          amountMinor: 2000000,
          currencyCode: code,
          localeName: locale,
          format: format,
          hideFraction: true,
        );
        expect(s, contains('20,000'), reason: 'format=$format');
      }
    });

    test('rounds instead of truncating non-zero cents', () {
      final s = formatMoneyDisplay(
        amountMinor: 199951, // $1,999.51
        currencyCode: code,
        localeName: locale,
        format: MoneyDisplayFormat.localeCode,
        hideFraction: true,
      );
      expect(s, contains('2,000'));
    });

    test('compactSymbol drops the .0 when hideFraction is set', () {
      final s = formatMoneyDisplay(
        amountMinor: 2000000,
        currencyCode: code,
        localeName: locale,
        format: MoneyDisplayFormat.compactSymbol,
        hideFraction: true,
      );
      expect(s, isNot(contains('.0')));
      expect(s.toUpperCase(), contains('K'));
    });

    test('unaffected when hideFraction is false (default)', () {
      final s = formatMoneyDisplay(
        amountMinor: 123456,
        currencyCode: code,
        localeName: locale,
        format: MoneyDisplayFormat.localeCode,
      );
      expect(s, contains('1,234.56'));
    });
  });
}
