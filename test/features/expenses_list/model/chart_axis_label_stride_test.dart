import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/features/expenses_list/model/chart_axis_label_stride.dart';

void main() {
  group('planChartAxisLabels', () {
    test('single label always shows', () {
      final plan = planChartAxisLabels(
        labelCount: 1,
        plotWidth: 100,
        maxLabelWidth: 80,
      );
      expect(plan.stride, 1);
      expect(plan.includeLast, isTrue);
      expect(
        shouldShowChartAxisLabel(index: 0, labelCount: 1, plan: plan),
        isTrue,
      );
    });

    test('wide plot keeps stride 1', () {
      final plan = planChartAxisLabels(
        labelCount: 5,
        plotWidth: 500,
        maxLabelWidth: 40,
        minGap: 8,
      );
      expect(plan.stride, 1);
      expect(plan.includeLast, isTrue);
    });

    test('narrow plot increases stride', () {
      final plan = planChartAxisLabels(
        labelCount: 12,
        plotWidth: 200,
        maxLabelWidth: 70,
        minGap: 8,
      );
      expect(plan.stride, greaterThan(1));
      var shown = 0;
      for (var i = 0; i < 12; i++) {
        if (shouldShowChartAxisLabel(index: i, labelCount: 12, plan: plan)) {
          shown++;
        }
      }
      // At most floor(200 / 78) = 2 slots with this slot size.
      expect(shown, lessThanOrEqualTo(3));
    });

    test('drops forced last when it would collide', () {
      // Five labels, room for two slots: stride 3 shows 0 and 3; forcing
      // index 4 would exceed the slot budget.
      final plan = planChartAxisLabels(
        labelCount: 5,
        plotWidth: 160,
        maxLabelWidth: 70,
        minGap: 8,
      );
      expect(plan.stride, greaterThan(1));
      expect(plan.includeLast, isFalse);
      expect(
        shouldShowChartAxisLabel(index: 0, labelCount: 5, plan: plan),
        isTrue,
      );
      expect(
        shouldShowChartAxisLabel(index: 4, labelCount: 5, plan: plan),
        isFalse,
      );
    });

    test('falls back when width unknown', () {
      final plan = planChartAxisLabels(
        labelCount: 20,
        plotWidth: 0,
        maxLabelWidth: 50,
      );
      expect(plan.stride, 4);
    });
  });

  group('shouldShowChartAxisLabel', () {
    test('shows stride ticks and optional last', () {
      const plan = (stride: 2, includeLast: true);
      expect(
        shouldShowChartAxisLabel(index: 0, labelCount: 5, plan: plan),
        isTrue,
      );
      expect(
        shouldShowChartAxisLabel(index: 1, labelCount: 5, plan: plan),
        isFalse,
      );
      expect(
        shouldShowChartAxisLabel(index: 2, labelCount: 5, plan: plan),
        isTrue,
      );
      expect(
        shouldShowChartAxisLabel(index: 4, labelCount: 5, plan: plan),
        isTrue,
      );
    });

    test('hides last when includeLast is false', () {
      const plan = (stride: 2, includeLast: false);
      // Last index 5 is not a stride tick (0, 2, 4).
      expect(
        shouldShowChartAxisLabel(index: 5, labelCount: 6, plan: plan),
        isFalse,
      );
      expect(
        shouldShowChartAxisLabel(index: 4, labelCount: 6, plan: plan),
        isTrue,
      );
    });
  });
}
