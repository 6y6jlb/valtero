import 'package:flutter/material.dart';
import 'package:valtero/shared/consts/tag_icons.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/flag_icon.dart';

typedef BreakdownLegendItem = ({
  String key,
  String label,
  Color color,
  String? iconKey,
  String? flagCode,
  bool flagIsCurrency,
});

/// Shared legend chips for donut / column / time-series breakdown charts.
///
/// When [showSubcategories] / [onShowSubcategoriesChanged] are set, a compact
/// subcategory switch is shown as the first legend chip.
class BreakdownChartLegend extends StatelessWidget {
  final List<BreakdownLegendItem> items;
  final Set<String> hiddenKeys;
  final ValueChanged<String> onToggle;
  final bool? showSubcategories;
  final ValueChanged<bool>? onShowSubcategoriesChanged;

  const BreakdownChartLegend({
    super.key,
    required this.items,
    required this.hiddenKeys,
    required this.onToggle,
    this.showSubcategories,
    this.onShowSubcategoriesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showSubToggle =
        showSubcategories != null && onShowSubcategoriesChanged != null;
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (showSubToggle)
          _SubcategoryLegendToggle(
            label: l10n.chartShowSubcategories,
            value: showSubcategories!,
            onChanged: onShowSubcategoriesChanged!,
          ),
        for (final item in items)
          _LegendChip(
            label: item.label,
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
  }
}

class _SubcategoryLegendToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SubcategoryLegendToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  /// Fixed footprint matching legend glyph height; scale Material Switch into it
  /// (FittedBox reflows during the thumb animation and looks like a size jump).
  static const _trackWidth = 28.0;
  static const _trackHeight = 16.0;
  static const _switchScale = 0.55;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // No ClipRect: scaled Material Switch is ~17.6px tall in a 16px
            // box; clipping cut the track. Overflow paints outside the
            // footprint without changing layout size.
            SizedBox(
              width: _trackWidth,
              height: _trackHeight,
              child: OverflowBox(
                alignment: Alignment.center,
                maxWidth: _trackWidth / _switchScale,
                maxHeight: _trackHeight / _switchScale,
                child: Transform.scale(
                  scale: _switchScale,
                  child: IgnorePointer(
                    child: Switch(
                      value: value,
                      onChanged: (_) {},
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool visible;
  final String seriesKey;
  final String? iconKey;
  final String? flagCode;
  final bool flagIsCurrency;
  final VoidCallback onTap;

  const _LegendChip({
    required this.label,
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
      decoration: BoxDecoration(
        color: tint,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: _glyphSize,
              height: _glyphSize,
              child: Center(child: _glyph(theme)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: visible ? null : muted,
                decoration: visible ? null : TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
