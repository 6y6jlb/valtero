import 'package:flutter/material.dart';

/// Standard modal sheet header: title (+ optional trailing) and optional description.
class AppSheetHeader extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? trailing;
  final bool centered;

  const AppSheetHeader({
    super.key,
    required this.title,
    this.description,
    this.trailing,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final descriptionStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final align = centered ? TextAlign.center : TextAlign.start;

    final titleWidget = Text(title, textAlign: align, style: titleStyle);

    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
      children: [
        if (trailing != null)
          Row(
            children: [
              Expanded(child: titleWidget),
              trailing!,
            ],
          )
        else
          titleWidget,
        if (description != null && description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(description!, textAlign: align, style: descriptionStyle),
        ],
      ],
    );
  }
}
