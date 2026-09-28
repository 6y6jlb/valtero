import 'package:flutter/material.dart';
import 'package:valtero/shared/consts/tag_icons.dart';
import 'package:valtero/widgets/flag_icon.dart';

typedef BreakdownLegendItem = ({
  String key,
  String label,
  Color color,
  String? iconKey,
  String? flagCode,
  bool flagIsCurrency,
  String? amountLabel,
});

/// Wider than this, the legend stays centered. Phones, medium windows, and
/// the default desktop size keep chips on the leading edge.
const _kLegendCenterMinWidth = 1200.0;

/// Shared legend chips for donut / column / time-series breakdown charts.
class BreakdownChartLegend extends StatelessWidget {
  final List<BreakdownLegendItem> items;
  final Set<String> hiddenKeys;
  final ValueChanged<String> onToggle;

  const BreakdownChartLegend({
    super.key,
    required this.items,
    required this.hiddenKeys,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final alignStart = constraints.maxWidth < _kLegendCenterMinWidth;
        return Wrap(
          spacing: 10,
          runSpacing: 6,
          alignment: alignStart ? WrapAlignment.start : WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final item in items)
              _LegendChip(
                label: item.label,
                amountLabel: item.amountLabel,
                color: item.color,
                visible: !hiddenKeys.contains(item.key),
                seriesKey: item.key,
                iconKey: item.iconKey,
                flagCode: item.flagCode,
                flagIsCurrency: item.flagIsCurrency,
                onTap: () => onToggle(item.key),
              ),
          ],
        );
      },
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final String? amountLabel;
  final Color color;
  final bool visible;
  final String seriesKey;
  final String? iconKey;
  final String? flagCode;
  final bool flagIsCurrency;
  final VoidCallback onTap;

  const _LegendChip({
    required this.label,
    required this.amountLabel,
    required this.color,
    required this.visible,
    required this.seriesKey,
    required this.iconKey,
    required this.flagCode,
    required this.flagIsCurrency,
    required this.onTap,
  });

  static const _glyphSize = 16.0;

  Widget _glyph(ThemeData theme) {
    final muted = theme.colorScheme.outlineVariant;
    final tint = visible ? color : muted;

    if (flagCode != null && flagCode!.isNotEmpty) {
      final flag = flagIsCurrency
          ? FlagIcon.currency(flagCode, size: _glyphSize)
          : FlagIcon.country(flagCode, size: _glyphSize);
      return Opacity(opacity: visible ? 1 : 0.45, child: flag);
    }

    final fromKey = iconDataForTagKey(iconKey);
    if (fromKey != null) {
      return Icon(fromKey, size: _glyphSize, color: tint);
    }

    // Cash-flow income / expense direction slices.
    if (seriesKey == 'income') {
      return Icon(Icons.south_west, size: _glyphSize, color: tint);
    }
    if (seriesKey == 'expense') {
      return Icon(Icons.north_east, size: _glyphSize, color: tint);
    }

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final labelStyle = theme.textTheme.labelMedium?.copyWith(
      color: visible ? null : muted,
      decoration: visible ? null : TextDecoration.lineThrough,
    );
    final amountStyle = theme.textTheme.labelSmall?.copyWith(
      color: visible ? muted : muted.withValues(alpha: 0.7),
      decoration: visible ? null : TextDecoration.lineThrough,
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: amountLabel != null ? 2 : 0),
              child: SizedBox(
                width: _glyphSize,
                height: _glyphSize,
                child: Center(child: _glyph(theme)),
              ),
            ),
            const SizedBox(width: 6),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                if (amountLabel != null) Text(amountLabel!, style: amountStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
