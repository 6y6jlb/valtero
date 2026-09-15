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
    // Deselect category and any of its children still selected.
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
