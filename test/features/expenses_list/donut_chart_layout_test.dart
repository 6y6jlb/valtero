import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/features/expenses_list/model/donut_chart_layout.dart';

void main() {
  group('computeDonutSectionValues', () {
    test('returns empty list unchanged', () {
      expect(computeDonutSectionValues(const []), isEmpty);
    });

    test('returns non-positive totals unchanged', () {
      expect(computeDonutSectionValues(const [0, 0]), [0, 0]);
      expect(computeDonutSectionValues(const [-1, -2]), [-1, -2]);
    });

    test('leaves values above the floor untouched', () {
      // Equal halves: each is 180°, well above 14°.
      final values = computeDonutSectionValues(const [50, 50]);
      expect(values, [50, 50]);
    });

    test('floors tiny slices to minSweepDegrees of the total', () {
      // Total 100; 14° of 360 ≈ 3.888… so minValue ≈ 3.888
      final values = computeDonutSectionValues(
        const [96, 1, 1, 1, 1],
        minSweepDegrees: 14,
      );
      final minValue = 100 * 14 / 360;
      expect(values[0], 96);
      for (var i = 1; i < values.length; i++) {
        expect(values[i], closeTo(minValue, 1e-9));
      }
    });

    test('uses default kMinDonutSweepDegrees', () {
      expect(kMinDonutSweepDegrees, 14);
      final values = computeDonutSectionValues(const [99, 1]);
      final minValue = 100 * kMinDonutSweepDegrees / 360;
      expect(values[0], 99);
      expect(values[1], closeTo(minValue, 1e-9));
    });

    test('does not floor hidden near-zero slices (no blank arc)', () {
      final values = computeDonutSectionValues(
        const [96, 0.0001, 4],
        minSweepDegrees: 14,
        hidden: const [false, true, false],
      );
      expect(values[0], 96);
      expect(values[1], 0.0001);
      expect(values[2], 4);
    });

    test('min floor uses visible total only when some are hidden', () {
      // Visible total 100; hidden 50 must not inflate the floor base.
      final values = computeDonutSectionValues(
        const [99, 50, 1],
        minSweepDegrees: 14,
        hidden: const [false, true, false],
      );
      final minValue = 100 * 14 / 360;
      expect(values[0], 99);
      expect(values[1], 50);
      expect(values[2], closeTo(minValue, 1e-9));
    });
  });
}
