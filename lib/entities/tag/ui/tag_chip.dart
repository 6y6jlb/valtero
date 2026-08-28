import 'package:flutter/material.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/tag_label.dart';

class TagChip extends StatelessWidget {
  final Tag tag;
  final bool selected;
  final VoidCallback? onTap;
  final String? labelOverride;

  const TagChip({
    super.key,
    required this.tag,
    this.selected = false,
    this.onTap,
    this.labelOverride,
  });

  Widget? _avatar() {
    final resourceIcon = switch (tag.stableKey) {
      'cash' => Icons.payments_outlined,
      'card' => Icons.credit_card,
      'crypto' => Icons.currency_bitcoin,
      'transfer' => Icons.account_balance_outlined,
      'ewallet' => Icons.account_balance_wallet_outlined,
      _ => null,
    };
    if (resourceIcon != null) {
      return Icon(resourceIcon, size: 18);
    }
    if (tag.colorValue != null) {
      return CircleAvatar(backgroundColor: Color(tag.colorValue!), radius: 8);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final color = tag.colorValue != null ? Color(tag.colorValue!) : null;
    final label = labelOverride ?? localizedTagLabel(context, tag);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
      selectedColor: color?.withValues(alpha: 0.35),
      avatar: _avatar(),
    );
  }
}
