import 'package:flutter/material.dart';
import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/entities/tag/ui/tag_chip.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Category tag chips (country is a field on the expense, not a tag).
class GroupedTagPicker extends StatelessWidget {
  final List<Tag> tags;
  final Set<int> selectedIds;
  final ValueChanged<Tag> onTagTap;
  final bool singleSelectPerKind;
  final Map<TagKind, Widget>? sectionTrailing;

  const GroupedTagPicker({
    super.key,
    required this.tags,
    required this.selectedIds,
    required this.onTagTap,
    this.singleSelectPerKind = false,
    this.sectionTrailing,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final grouped = groupTagsByKind(tags);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final kind in TagKind.values) ...[
          TagKindSectionHeader(kind: kind),
          if (sectionTrailing?[kind] != null) ...[
            sectionTrailing![kind]!,
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in grouped[kind]!)
                TagChip(
                  tag: tag,
                  selected: selectedIds.contains(tag.id),
                  onTap: () => onTagTap(tag),
                ),
            ],
          ),
        ],
        if (singleSelectPerKind)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.tagKindSingleSelectHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

class TagKindSectionHeader extends StatelessWidget {
  final TagKind kind;

  const TagKindSectionHeader({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final accent = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.label_outline, size: 18, color: accent),
          const SizedBox(width: 6),
          Text(
            tagKindSectionTitle(l10n, kind),
            style: theme.textTheme.labelLarge?.copyWith(color: accent),
          ),
        ],
      ),
    );
  }
}
