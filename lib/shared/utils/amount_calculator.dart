import 'package:valtero/shared/utils/money.dart';

/// Operations available in the amount calculator sheet.
enum AmountCalculatorOp {
  /// [base] + operand (operand as money).
  add,

  /// [base] − operand (operand as money).
  subtract,

  /// [base] × operand (operand as scalar, e.g. 1.1).
  multiply,

  /// [base] ÷ operand (operand as scalar).
  divide,

  /// [base] × (operand / 100) — percent of base, not “add percent”.
  percentOf,
}

/// Integer-minor-unit amount calculator used by the edit-operation sheet.
class AmountCalculator {
  AmountCalculator._();

  static final _numeric = RegExp(r'^-?\d+([.,]\d*)?$|^-?[.,]\d+$');

  /// Applies [op] to [baseMinor] with [operand] text.
  ///
  /// Returns `null` when the operand is empty/invalid, division by zero,
  /// or the result is ≤ 0 (same rule as the add/edit form `_canSave`).
  static int? apply({
    required int baseMinor,
    required AmountCalculatorOp op,
    required String operand,
  }) {
    final trimmed = operand.trim();
    if (trimmed.isEmpty || !_numeric.hasMatch(trimmed)) return null;

    final xMinor = Money.parseMajorToMinor(trimmed);
    if (op == AmountCalculatorOp.divide && xMinor == 0) return null;

    final int result;
    switch (op) {
      case AmountCalculatorOp.add:
        result = baseMinor + xMinor;
      case AmountCalculatorOp.subtract:
        result = baseMinor - xMinor;
      case AmountCalculatorOp.multiply:
        // B × (xMinor / 100), round to nearest minor.
        result = _roundDiv(baseMinor * xMinor, 100);
      case AmountCalculatorOp.divide:
        // B ÷ (xMinor / 100) = B * 100 / xMinor.
        result = _roundDiv(baseMinor * 100, xMinor);
      case AmountCalculatorOp.percentOf:
        // B × (xMinor / 100) / 100 = B * xMinor / 10000.
        result = _roundDiv(baseMinor * xMinor, 10000);
    }

    if (result <= 0) return null;
    return result;
  }

  /// Half-away-from-zero integer division (matches typical money rounding).
  static int _roundDiv(int numerator, int denominator) {
    if (denominator == 0) return 0;
    final neg = (numerator < 0) != (denominator < 0);
    final a = numerator.abs();
    final b = denominator.abs();
    final q = a ~/ b;
    final rem = a % b;
    final rounded = rem * 2 >= b ? q + 1 : q;
    return neg ? -rounded : rounded;
  }
}
