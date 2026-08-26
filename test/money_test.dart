import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/shared/utils/money.dart';

void main() {
  group('Money', () {
    test('parseMajorToMinor handles decimals', () {
      expect(Money.parseMajorToMinor('10.50'), 1050);
      expect(Money.parseMajorToMinor('10,5'), 1050);
      expect(Money.parseMajorToMinor('0.01'), 1);
    });

    test('formatMinor formats with two digits', () {
      expect(Money.formatMinor(1050), '10.50');
      expect(Money.formatMinor(1), '0.01');
    });

    test('convertMinor applies rate without float storage', () {
      // 10.00 USD * 90 = 900.00
      expect(
        Money.convertMinor(originalMinor: 1000, rate: 90),
        90000,
      );
    });
  });
}
