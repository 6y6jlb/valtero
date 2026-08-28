import 'package:flutter/material.dart';

/// One donut segment with stable [key] for hide/show and drill-down.
class DonutChartSlice {
  final String key;
  final String label;
  final int amountMinor;
  final Color color;

  const DonutChartSlice({
    required this.key,
    required this.label,
    required this.amountMinor,
    required this.color,
  });
}
