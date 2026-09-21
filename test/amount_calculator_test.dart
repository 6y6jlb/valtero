import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/shared/utils/amount_calculator.dart';

void main() {
  group('AmountCalculator.apply', () {
    test('add sums money minors', () {
      // 12.34 + 1.50 = 13.84
      expect(
        AmountCalculator.apply(
          baseMinor: 1234,
          op: AmountCalculatorOp.add,
          operand: '1.50',
        ),
        1384,
      );
    });

    test('subtract subtracts money minors', () {
      // 12.34 - 1.50 = 10.84
      expect(
        AmountCalculator.apply(
          baseMinor: 1234,
          op: AmountCalculatorOp.subtract,
          operand: '1.50',
        ),
        1084,
      );
    });

    test('multiply scales by scalar', () {
      // 10.00 × 1.1 = 11.00
      expect(
        AmountCalculator.apply(
          baseMinor: 1000,
          op: AmountCalculatorOp.multiply,
          operand: '1.1',
        ),
        1100,
      );
    });

    test('divide divides by scalar', () {
      // 10.00 ÷ 2 = 5.00
      expect(
        AmountCalculator.apply(
          baseMinor: 1000,
          op: AmountCalculatorOp.divide,
          operand: '2',
        ),
        500,
      );
    });

    test('percentOf takes percent of base', () {
      // 10% of 100.00 = 10.00
      expect(
        AmountCalculator.apply(
          baseMinor: 10000,
          op: AmountCalculatorOp.percentOf,
          operand: '10',
        ),
        1000,
      );
    });

    test('percentOf rounds to nearest minor', () {
      // 50% of 99.99 = 49.995 → 50.00
      expect(
        AmountCalculator.apply(
          baseMinor: 9999,
          op: AmountCalculatorOp.percentOf,
          operand: '50',
        ),
        5000,
      );
    });

    test('empty operand returns null', () {
      expect(
        AmountCalculator.apply(
          baseMinor: 1000,
          op: AmountCalculatorOp.add,
          operand: '',
        ),
        isNull,
      );
      expect(
        AmountCalculator.apply(
          baseMinor: 1000,
          op: AmountCalculatorOp.add,
          operand: '   ',
        ),
        isNull,
      );
    });

    test('non-numeric operand returns null', () {
      expect(
        AmountCalculator.apply(
          baseMinor: 1000,
          op: AmountCalculatorOp.add,
          operand: 'abc',
        ),
        isNull,
      );
    });

    test('divide by zero returns null', () {
      expect(
        AmountCalculator.apply(
          baseMinor: 1000,
          op: AmountCalculatorOp.divide,
          operand: '0',
        ),
        isNull,
      );
      expect(
        AmountCalculator.apply(
          baseMinor: 1000,
          op: AmountCalculatorOp.divide,
          operand: '0.00',
        ),
        isNull,
      );
    });

    test('negative or zero result returns null', () {
      expect(
        AmountCalculator.apply(
          baseMinor: 100,
          op: AmountCalculatorOp.subtract,
          operand: '2.00',
        ),
        isNull,
      );
      expect(
        AmountCalculator.apply(
          baseMinor: 100,
          op: AmountCalculatorOp.subtract,
          operand: '1.00',
        ),
        isNull,
      );
      expect(
        AmountCalculator.apply(
          baseMinor: 1000,
          op: AmountCalculatorOp.multiply,
          operand: '0',
        ),
        isNull,
      );
    });

    test('accepts comma as decimal separator', () {
      expect(
        AmountCalculator.apply(
          baseMinor: 1000,
          op: AmountCalculatorOp.add,
          operand: '1,50',
        ),
        1150,
      );
    });
  });
}
