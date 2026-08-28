import 'package:flutter/material.dart';

/// One donut segment with stable [key] for hide/show and drill-down.
class DonutChartSlice {
  final String key;
  final String label;
  final int amountMinor;
  final Color color;

  /// When set, segment amounts use this ISO code instead of chart [displayCurrency].
  final String? currencyCode;

  const DonutChartSlice({
    required this.key,
    required this.label,
    required this.amountMinor,
    required this.color,
    this.currencyCode,
  });
}
