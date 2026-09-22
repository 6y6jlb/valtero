/// Max chart-type / breakdown icons per row on narrow chart chrome.
const kChartOverlayNarrowMaxIconsPerRow = 4;

/// Parent width below which overlay actions wrap to [kChartOverlayNarrowMaxIconsPerRow].
const kChartOverlayNarrowWidth = 600.0;

/// Vertical gap between wrapped overlay icon rows, and between chart-type
/// icons / divider / breakdown icons.
const kChartOverlayIconRowGap = 4.0;

/// Whether [parentWidth] should use the narrow overlay icon layout.
bool isChartOverlayNarrow(double parentWidth) =>
    parentWidth < kChartOverlayNarrowWidth;

/// Splits [count] icons into row lengths of at most [maxPerRow].
///
/// When [maxPerRow] is null or ≥ [count], returns a single row of [count].
/// Empty [count] yields an empty list.
List<int> chunkChartOverlayIconRows(int count, int? maxPerRow) {
  if (count <= 0) return const [];
  if (maxPerRow == null || maxPerRow <= 0 || maxPerRow >= count) {
    return [count];
  }
  final rows = <int>[];
  var remaining = count;
  while (remaining > 0) {
    final take = remaining > maxPerRow ? maxPerRow : remaining;
    rows.add(take);
    remaining -= take;
  }
  return rows;
}
