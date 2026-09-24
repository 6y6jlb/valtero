import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/features/expenses_list/model/cycle_index.dart';
import 'package:valtero/features/expenses_list/model/drag_cycle_settle.dart';

void main() {
  group('shouldCommitDragCycle', () {
    test('rejects zero offset', () {
      expect(
        shouldCommitDragCycle(offset: 0, width: 300),
        isFalse,
      );
    });

    test('commits at 30% of width', () {
      expect(
        shouldCommitDragCycle(offset: -90, width: 300),
        isTrue,
      );
      expect(
        shouldCommitDragCycle(offset: -89, width: 300),
        isFalse,
      );
      expect(
        shouldCommitDragCycle(offset: 90, width: 300),
        isTrue,
      );
    });

    test('commits on strong velocity in drag direction', () {
      expect(
        shouldCommitDragCycle(
          offset: -20,
          width: 300,
          velocity: -800,
        ),
        isTrue,
      );
      expect(
        shouldCommitDragCycle(
          offset: 20,
          width: 300,
          velocity: 800,
        ),
        isTrue,
      );
      expect(
        shouldCommitDragCycle(
          offset: -20,
          width: 300,
          velocity: 800,
        ),
        isFalse,
      );
    });

    test('trackpad burst commits at shorter threshold', () {
      expect(
        shouldCommitDragCycle(
          offset: -kChartHorizontalCycleThreshold,
          width: 800,
          fromTrackpadBurst: true,
        ),
        isTrue,
      );
      expect(
        shouldCommitDragCycle(
          offset: -kChartHorizontalCycleThreshold,
          width: 800,
          fromTrackpadBurst: false,
        ),
        isFalse,
      );
    });

    test('rejects empty width without distance commit', () {
      expect(
        shouldCommitDragCycle(offset: -100, width: 0),
        isFalse,
      );
    });
  });

  group('dragCycleForwardFromOffset', () {
    test('negative is forward', () {
      expect(dragCycleForwardFromOffset(-10), isTrue);
      expect(dragCycleForwardFromOffset(10), isFalse);
    });
  });

  group('clampDragCycleOffset', () {
    test('clamps to plus/minus width', () {
      expect(clampDragCycleOffset(-500, 300), -300);
      expect(clampDragCycleOffset(500, 300), 300);
      expect(clampDragCycleOffset(-50, 300), -50);
    });

    test('leaves offset unchanged when width is empty', () {
      expect(clampDragCycleOffset(-50, 0), -50);
    });
  });

  group('dragCycleCommitTarget', () {
    test('full page in drag direction', () {
      expect(dragCycleCommitTarget(-10, 300), -300);
      expect(dragCycleCommitTarget(10, 300), 300);
    });

    test('returns zero when width is empty', () {
      expect(dragCycleCommitTarget(-10, 0), 0);
    });
  });
}
