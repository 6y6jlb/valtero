import 'package:flutter/material.dart';
import 'package:valtero/shared/database/app_database.dart';

class TagChip extends StatelessWidget {
  final Tag tag;
  final bool selected;
  final VoidCallback? onTap;

  const TagChip({
    super.key,
    required this.tag,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = tag.colorValue != null ? Color(tag.colorValue!) : null;
    return FilterChip(
      label: Text(tag.name),
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
      selectedColor: color?.withValues(alpha: 0.35),
      avatar: color == null
          ? null
          : CircleAvatar(backgroundColor: color, radius: 8),
    );
  }
}
