import 'package:flutter/material.dart';
import 'package:valtero/shared/consts/tag_icons.dart';

/// Resolves a payment-method icon: custom [iconKey] first, then seeded
/// [stableKey] defaults.
IconData? iconDataForPaymentMethod({
  String? iconKey,
  String? stableKey,
}) {
  final fromKey = iconDataForTagKey(iconKey);
  if (fromKey != null) return fromKey;
  return iconDataForPaymentStableKey(stableKey);
}

/// Material icon for a seeded payment-method [stableKey], if known.
IconData? iconDataForPaymentStableKey(String? stableKey) {
  if (stableKey == null || stableKey.isEmpty) return null;
  final key = defaultIconKeyForPaymentStableKey(stableKey);
  return iconDataForTagKey(key);
}
