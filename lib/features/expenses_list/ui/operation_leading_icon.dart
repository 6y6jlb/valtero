import 'package:flutter/material.dart';
import 'package:valtero/shared/consts/tag_icons.dart';
import 'package:valtero/shared/utils/payment_method_icon.dart';
import 'package:valtero/widgets/flag_icon.dart';

/// Leading icon for dashboard recent rows: tag → currency flag → payment.
///
/// Country stays in the subtitle; it is intentionally not used here.
/// Returns `null` when none of the three sources resolve (no empty gap).
class OperationLeadingIcon extends StatelessWidget {
  final String? tagIconKey;
  final String? currencyCode;
  final String? paymentStableKey;
  final double size;

  const OperationLeadingIcon({
    super.key,
    this.tagIconKey,
    this.currencyCode,
    this.paymentStableKey,
    this.size = 28,
  });

  /// Builds a leading widget, or `null` when nothing would render.
  static Widget? maybe({
    String? tagIconKey,
    String? currencyCode,
    String? paymentStableKey,
    double size = 28,
  }) {
    if (iconDataForTagKey(tagIconKey) == null &&
        !hasCurrencyFlag(currencyCode) &&
        iconDataForPaymentStableKey(paymentStableKey) == null) {
      return null;
    }
    return OperationLeadingIcon(
      tagIconKey: tagIconKey,
      currencyCode: currencyCode,
      paymentStableKey: paymentStableKey,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tagIcon = iconDataForTagKey(tagIconKey);
    if (tagIcon != null) {
      return SizedBox(
        width: size,
        height: size,
        child: Icon(
          tagIcon,
          size: size * 0.85,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (hasCurrencyFlag(currencyCode)) {
      return FlagIcon.currency(currencyCode, size: size);
    }

    final paymentIcon = iconDataForPaymentStableKey(paymentStableKey);
    if (paymentIcon != null) {
      return SizedBox(
        width: size,
        height: size,
        child: Icon(
          paymentIcon,
          size: size * 0.85,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return SizedBox(width: size, height: size);
  }
}

/// Picks the best tag [iconKey] for a recent row: prefer a subcategory that
/// has an icon, otherwise any linked tag with an icon.
String? resolveOperationTagIconKey({
  required List<int> tagIds,
  required Map<int, String?> iconKeyByTagId,
  required Map<int, int?> parentIdByTagId,
}) {
  String? subcategoryIcon;
  String? anyIcon;
  for (final id in tagIds) {
    final key = iconKeyByTagId[id];
    if (iconDataForTagKey(key) == null) continue;
    if (parentIdByTagId[id] != null) {
      subcategoryIcon ??= key;
    } else {
      anyIcon ??= key;
    }
  }
  return subcategoryIcon ?? anyIcon;
}
