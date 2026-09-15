import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/shared/utils/currency_symbol.dart';

void main() {
  group('currencySymbolFor', () {
    test('returns known glyphs for major fiats', () {
      expect(currencySymbolFor('RUB'), '₽');
      expect(currencySymbolFor('usd'), r'$');
      expect(currencySymbolFor('EUR'), '€');
    });

    test('falls back to ISO for unknown / crypto codes', () {
      expect(currencySymbolFor('BTC'), 'BTC');
      expect(currencySymbolFor('XYZ'), 'XYZ');
    });

    test('hasCurrencySymbol is false for ISO-only codes', () {
      expect(hasCurrencySymbol('RUB'), isTrue);
      expect(hasCurrencySymbol('BTC'), isFalse);
    });
  });
}
