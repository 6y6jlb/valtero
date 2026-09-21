import 'package:flutter/material.dart';

/// One donut segment with stable [key] for hide/show and drill-down.
class DonutChartSlice {
  final String key;
  final String label;
  final int amountMinor;
  final Color color;

  /// When set, segment amounts use this ISO code instead of chart [displayCurrency].
  final String? currencyCode;

  /// Catalog icon key for tag/payment glyphs in the legend.
  final String? iconKey;

  /// ISO country or currency code for a flag glyph in the legend.
  final String? flagCode;

  /// When true, [flagCode] is a currency ISO (currency flag); otherwise country.
  final bool flagIsCurrency;

  const DonutChartSlice({
    required this.key,
    required this.label,
    required this.amountMinor,
    required this.color,
    this.currencyCode,
    this.iconKey,
    this.flagCode,
    this.flagIsCurrency = false,
  });
}
