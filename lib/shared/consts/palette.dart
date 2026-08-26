import 'package:flutter/material.dart';

/// Default palette for chart slices / new tags.
const List<Color> appColorPalette = [
  Color(0xFF2F6F5E),
  Color(0xFF4C8BF5),
  Color(0xFFE67E22),
  Color(0xFF9B59B6),
  Color(0xFFE74C3C),
  Color(0xFF16A085),
  Color(0xFFF1C40F),
  Color(0xFF3498DB),
  Color(0xFF1ABC9C),
  Color(0xFFE91E63),
  Color(0xFF795548),
  Color(0xFF607D8B),
];

/// Stable-key → default ARGB for seeded tags.
const Map<String, int> defaultTagColorValues = {
  'groceries': 0xFF4CAF50,
  'transport': 0xFF2196F3,
  'housing': 0xFF795548,
  'dining': 0xFFFF9800,
  'health': 0xFFE91E63,
  'entertainment': 0xFF9C27B0,
  'shopping': 0xFF00BCD4,
  'travel': 0xFF3F51B5,
  'utilities': 0xFF607D8B,
  'cash': 0xFF8BC34A,
  'card': 0xFF1976D2,
  'crypto': 0xFFF39C12,
  'transfer': 0xFF546E7A,
  'ewallet': 0xFF00897B,
};

Color chartColorAt(int index) => appColorPalette[index % appColorPalette.length];

Color? colorFromValue(int? value) => value == null ? null : Color(value);
