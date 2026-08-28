import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Category tags only. Country lives on [Expense.countryCode]; trip kind removed.
enum TagKind { custom }

/// Stored `tags.kind` value for [kind].
String tagKindDbValue(TagKind kind) {
  return switch (kind) {
    TagKind.custom => 'normal',
  };
}

TagKind tagKindOf(Tag tag) => TagKind.custom;

bool tagMatchesKind(Tag tag, TagKind kind) => tagKindOf(tag) == kind;

String tagKindSectionTitle(AppLocalizations l10n, TagKind kind) {
  return switch (kind) {
    TagKind.custom => l10n.tagKindSectionCustom,
  };
}

String tagKindUnspecifiedLabel(AppLocalizations l10n, TagKind kind) {
  return switch (kind) {
    TagKind.custom => l10n.tagKindUnspecifiedCustom,
  };
}

Map<TagKind, List<Tag>> groupTagsByKind(Iterable<Tag> tags) {
  final grouped = {
    for (final kind in TagKind.values) kind: <Tag>[],
  };
  for (final tag in tags) {
    grouped[tagKindOf(tag)]!.add(tag);
  }
  return grouped;
}

/// Adds or removes [tag.id]; when [singleSelectPerKind] is true, replaces any
/// other selected tag of the same kind.
void toggleTagSelection({
  required Set<int> selected,
  required Tag tag,
  required Map<int, Tag> tagById,
  required bool singleSelectPerKind,
}) {
  if (selected.contains(tag.id)) {
    selected.remove(tag.id);
    return;
  }
  if (singleSelectPerKind) {
    final kind = tagKindOf(tag);
    selected.removeWhere(
      (id) => tagById[id] != null && tagKindOf(tagById[id]!) == kind,
    );
  }
  selected.add(tag.id);
}

void replaceTagSelectionOfKind({
  required Set<int> selected,
  required int tagId,
  required TagKind kind,
  required Map<int, Tag> tagById,
}) {
  selected.removeWhere(
    (id) => tagById[id] != null && tagKindOf(tagById[id]!) == kind,
  );
  selected.add(tagId);
}

int? selectedTagIdForKind(
  Set<int> selected,
  Map<int, Tag> tagById,
  TagKind kind,
) {
  for (final id in selected) {
    final tag = tagById[id];
    if (tag != null && tagKindOf(tag) == kind) return id;
  }
  return null;
}
