import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/shared/database/app_database.dart';

bool isSubcategory(Tag tag) => tag.parentTagId != null;

List<Tag> topLevelTags(Iterable<Tag> tags) => [
      for (final t in tags)
        if (t.parentTagId == null) t,
    ];

List<Tag> childrenOf(Iterable<Tag> tags, int parentId) => [
      for (final t in tags)
        if (t.parentTagId == parentId) t,
    ];

/// Resolves which tag ids are the "target" set for [kind] given the tags
/// attached to an operation.
///
/// Default (`includeSubcategories: false`) rolls subtag-only attachments up
/// to their parent category. When [includeSubcategories] is true, an attached
/// subtag is returned as its own target instead of its parent (and an attached
/// parent without a subtag stays as itself).
List<int> resolveCategoryTargets({
  required List<int> tagIds,
  required TagKind kind,
  required Map<int, Tag> tagById,
  bool includeSubcategories = false,
}) {
  if (includeSubcategories) {
    final result = <int>[];
    final seen = <int>{};
    for (final id in tagIds) {
      final tag = tagById[id];
      if (tag == null || tagKindOf(tag) != kind) continue;
      if (tag.parentTagId != null) {
        if (seen.add(tag.id)) result.add(tag.id);
        continue;
      }
      final hasSelectedChild = tagIds.any((otherId) {
        final other = tagById[otherId];
        return other != null &&
            other.parentTagId == tag.id &&
            tagKindOf(other) == kind;
      });
      if (!hasSelectedChild && seen.add(tag.id)) result.add(tag.id);
    }
    return result;
  }

  final matching = <int>[
    for (final id in tagIds)
      if (tagById[id] != null &&
          tagById[id]!.parentTagId == null &&
          tagKindOf(tagById[id]!) == kind)
        id,
  ];

  if (matching.isEmpty) {
    final rolled = <int>{};
    for (final id in tagIds) {
      final tag = tagById[id];
      if (tag == null || tag.parentTagId == null) continue;
      if (tagKindOf(tag) != kind) continue;
      final parent = tagById[tag.parentTagId!];
      if (parent != null &&
          parent.parentTagId == null &&
          tagKindOf(parent) == kind) {
        rolled.add(parent.id);
      }
    }
    matching.addAll(rolled);
  }
  return matching;
}

/// Display label for a resolved category/subcategory target.
String categoryTargetLabel({
  required int tagId,
  required Map<int, Tag> tagById,
  required Map<int, String> tagLabels,
  required String fallback,
}) {
  final tag = tagById[tagId];
  if (tag == null) return tagLabels[tagId] ?? fallback;
  final parentId = tag.parentTagId;
  if (parentId == null) return tagLabels[tagId] ?? fallback;
  final parentLabel = tagLabels[parentId] ?? tagById[parentId]?.name;
  final childLabel = tagLabels[tagId] ?? tag.name;
  if (parentLabel == null || parentLabel.isEmpty) return childLabel;
  return '$parentLabel · $childLabel';
}

/// Top-level category id of [kind] currently in [selected], if any.
int? selectedTopLevelTagId(
  Set<int> selected,
  Map<int, Tag> tagById,
  TagKind kind,
) {
  for (final id in selected) {
    final tag = tagById[id];
    if (tag != null &&
        tag.parentTagId == null &&
        tagKindOf(tag) == kind) {
      return id;
    }
  }
  return null;
}

/// Subcategory id under [parentId] currently in [selected], if any.
int? selectedSubtagId(
  Set<int> selected,
  Map<int, Tag> tagById,
  int parentId,
) {
  for (final id in selected) {
    final tag = tagById[id];
    if (tag != null && tag.parentTagId == parentId) return id;
  }
  return null;
}

/// Replaces any other top-level tag of the same kind and clears mismatched
/// subcategories (those whose parent is no longer selected).
void selectTopLevelTag({
  required Set<int> selected,
  required Tag tag,
  required Map<int, Tag> tagById,
}) {
  assert(tag.parentTagId == null);
  final kind = tagKindOf(tag);

  if (selected.contains(tag.id)) {
    selected.remove(tag.id);
    selected.removeWhere((id) {
      final t = tagById[id];
      return t != null && t.parentTagId == tag.id;
    });
    return;
  }

  selected.removeWhere((id) {
    final t = tagById[id];
    return t != null && tagKindOf(t) == kind;
  });
  selected.add(tag.id);
}

/// Toggles a subcategory under its parent. Replaces any other subtag of the
/// same parent. Does nothing if the parent category is not currently selected.
void selectSubtag({
  required Set<int> selected,
  required Tag tag,
  required Map<int, Tag> tagById,
}) {
  final parentId = tag.parentTagId;
  if (parentId == null) return;
  if (!selected.contains(parentId)) return;

  if (selected.contains(tag.id)) {
    selected.remove(tag.id);
    return;
  }

  selected.removeWhere((id) {
    final t = tagById[id];
    return t != null && t.parentTagId == parentId;
  });
  selected.add(tag.id);
}

/// Clears any selected subcategory under [parentId].
void clearSubtagSelection({
  required Set<int> selected,
  required Map<int, Tag> tagById,
  required int parentId,
}) {
  selected.removeWhere((id) {
    final t = tagById[id];
    return t != null && t.parentTagId == parentId;
  });
}
