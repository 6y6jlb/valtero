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
      // pitch = 500/5 = 100; slot = 40+12 = 52 → adjacent gaps fit.
      final plan = planChartAxisLabels(
        labelCount: 5,
        plotWidth: 500,
        maxLabelWidth: 40,
        minGap: 12,
      );
      expect(plan.stride, 1);
      expect(plan.includeLast, isTrue);
    });

    test('narrow plot increases stride', () {
      // pitch = 200/12 ≈ 16.7; slot = 82 → need stride ≥ 5.
      final plan = planChartAxisLabels(
        labelCount: 12,
        plotWidth: 200,
        maxLabelWidth: 70,
        minGap: 12,
      );
      expect(plan.stride, greaterThan(1));
      var shown = 0;
      for (var i = 0; i < 12; i++) {
        if (shouldShowChartAxisLabel(index: i, labelCount: 12, plan: plan)) {
          shown++;
        }
      }
      expect(shown, lessThanOrEqualTo(3));
    });

    test('two labels need enough gap or drop the last', () {
      // pitch = 100/2 = 50; slot = 70+12 = 82 → gap 50 < 82 → only first.
      final plan = planChartAxisLabels(
        labelCount: 2,
        plotWidth: 100,
        maxLabelWidth: 70,
        minGap: 12,
      );
      expect(
        shouldShowChartAxisLabel(index: 0, labelCount: 2, plan: plan),
        isTrue,
      );
      expect(
        shouldShowChartAxisLabel(index: 1, labelCount: 2, plan: plan),
        isFalse,
      );
    });

    test('two labels show when track is wide enough', () {
      // pitch = 200/2 = 100; slot = 82 → both fit.
      final plan = planChartAxisLabels(
        labelCount: 2,
        plotWidth: 200,
        maxLabelWidth: 70,
        minGap: 12,
      );
      expect(plan.stride, 1);
      expect(plan.includeLast, isTrue);
      expect(
        shouldShowChartAxisLabel(index: 1, labelCount: 2, plan: plan),
        isTrue,
      );
    });

    test('drops forced last when it would collide', () {
      // pitch = 32; slot = 82. stride 3 fits 0+3 without last; adding 4
      // leaves only 32px to the previous tick.
      final plan = planChartAxisLabels(
        labelCount: 5,
        plotWidth: 160,
        maxLabelWidth: 70,
        minGap: 12,
      );
      expect(plan.stride, 3);
      expect(plan.includeLast, isFalse);
      expect(
        shouldShowChartAxisLabel(index: 0, labelCount: 5, plan: plan),
        isTrue,
      );
      expect(
        shouldShowChartAxisLabel(index: 3, labelCount: 5, plan: plan),
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

  group('chartAxisTrackWidth', () {
    test('empty axis has no width', () {
      expect(chartAxisTrackWidth(0), 0);
      expect(chartAxisTrackWidth(0, points: true), 0);
    });

    test('columns use one slot each plus the edge insets', () {
      expect(
        chartAxisTrackWidth(4),
        4 * kChartColumnSlot + kChartAngledLeading + 2 * kChartAngledEdgeInset,
      );
    });

    test('line points space by the gaps between them', () {
      expect(
        chartAxisTrackWidth(1, points: true),
        kChartColumnSlot + kChartAngledLeading + 2 * kChartAngledEdgeInset,
      );
      expect(
        chartAxisTrackWidth(5, points: true),
        4 * kChartColumnSlot + kChartAngledLeading + 2 * kChartAngledEdgeInset,
      );
    });
  });

  group('chartGroupsSpace', () {
    test('keeps column centers one slot apart', () {
      expect(
        chartGroupsSpace(kChartBarWidth),
        kChartColumnSlot - kChartBarWidth,
      );
    });

    test('does not use a negative gap', () {
      expect(chartGroupsSpace(kChartColumnSlot + 8), 0);
    });
  });

  group('chartLeadingGroupWidth', () {
    test('plus the group gap is one column slot', () {
      expect(
        chartLeadingGroupWidth(kChartBarWidth) +
            chartGroupsSpace(kChartBarWidth),
        kChartAngledLeading,
      );
    });
  });

  group('chartLineMaxX', () {
    test('keeps the last point inside a narrow plot', () {
      expect(chartLineMaxX(pointCount: 5, plotWidth: 40), 4);
    });

    test('extends past the last point when the plot is wider', () {
      expect(chartLineMaxX(pointCount: 3, plotWidth: kChartColumnSlot * 6), 5);
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
