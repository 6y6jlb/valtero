import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/features/expenses_list/model/chart_overlay_layout.dart';

void main() {
  group('chunkChartOverlayIconRows', () {
    test('empty count yields empty rows', () {
      expect(chunkChartOverlayIconRows(0, 4), isEmpty);
      expect(chunkChartOverlayIconRows(-1, 4), isEmpty);
    });

    test('null or non-positive maxPerRow keeps a single row', () {
      expect(chunkChartOverlayIconRows(8, null), [8]);
      expect(chunkChartOverlayIconRows(8, 0), [8]);
      expect(chunkChartOverlayIconRows(8, -2), [8]);
    });

    test('maxPerRow >= count keeps a single row', () {
      expect(chunkChartOverlayIconRows(4, 4), [4]);
      expect(chunkChartOverlayIconRows(3, 4), [3]);
      expect(chunkChartOverlayIconRows(8, 8), [8]);
    });

    test('splits eight icons into 4+4 on narrow max', () {
      expect(
        chunkChartOverlayIconRows(8, kChartOverlayNarrowMaxIconsPerRow),
        [4, 4],
      );
    });

    test('splits uneven remainders into full then remainder rows', () {
      expect(chunkChartOverlayIconRows(5, 4), [4, 1]);
      expect(chunkChartOverlayIconRows(9, 4), [4, 4, 1]);
      expect(chunkChartOverlayIconRows(7, 3), [3, 3, 1]);
    });
  });

  group('isChartOverlayNarrow', () {
    test('true below 600, false at or above', () {
      expect(isChartOverlayNarrow(599), isTrue);
      expect(isChartOverlayNarrow(kChartOverlayNarrowWidth), isFalse);
      expect(isChartOverlayNarrow(800), isFalse);
    });
  });
}
