import 'package:flutter/material.dart';
import 'package:valtero/entities/tag/model/tag_hierarchy.dart';
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
  /// When set, only these kinds are shown (and empty sections still appear).
  final Iterable<TagKind>? kinds;
  /// When true, only top-level tags are listed (subcategories omitted).
  final bool topLevelOnly;
  /// When true (and not [topLevelOnly]), nest subcategory chips under each parent.
  final bool nestSubcategories;

  const GroupedTagPicker({
    super.key,
    required this.tags,
    required this.selectedIds,
    required this.onTagTap,
    this.singleSelectPerKind = false,
    this.sectionTrailing,
    this.kinds,
    this.topLevelOnly = false,
    this.nestSubcategories = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final grouped = groupTagsByKind(tags);
    final shownKinds = kinds?.toList() ?? TagKind.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final kind in shownKinds) ...[
          TagKindSectionHeader(kind: kind),
          if (sectionTrailing?[kind] != null) ...[
            sectionTrailing![kind]!,
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in _chipsForKind(grouped[kind] ?? const <Tag>[]))
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

  List<Tag> _chipsForKind(List<Tag> kindTags) {
    if (topLevelOnly) {
      return topLevelTags(kindTags);
    }
    if (!nestSubcategories) {
      return kindTags;
    }
    final tops = topLevelTags(kindTags);
    final result = <Tag>[];
    for (final parent in tops) {
      result.add(parent);
      result.addAll(childrenOf(kindTags, parent.id));
    }
    // Orphan subcategories (parent missing from list) still shown.
    for (final t in kindTags) {
      if (t.parentTagId != null && !result.any((x) => x.id == t.id)) {
        result.add(t);
      }
    }
    return result;
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
