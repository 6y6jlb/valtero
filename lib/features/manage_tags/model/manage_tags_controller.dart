import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/shared/consts/palette.dart';
import 'package:valtero/shared/consts/tag_icons.dart';
import 'package:valtero/shared/consts/tag_suggestions.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

class ManageTagsController {
  final Ref ref;

  ManageTagsController(this.ref);

  AppDatabase get _db => ref.read(appDatabaseProvider);

  /// Seeds category tags on first launch; also backfills icons/income seeds
  /// and default subcategories for upgrades.
  Future<void> seedDefaultsIfEmpty() async {
    final existing = await _db.watchTagsList();
    if (existing.isEmpty) {
      var order = 0;
      for (final key in defaultSeedTagKeys) {
        await _db.insertTag(
          TagsCompanion.insert(
            name: key,
            stableKey: Value(key),
            colorValue: Value(defaultTagColorValues[key]),
            iconKey: Value(defaultIconKeyForStableKey(key)),
            isDefault: const Value(true),
            sortOrder: Value(order++),
          ),
        );
      }
    } else {
      for (final tag in existing) {
        final key = tag.stableKey;
        if (key == null) continue;
        var updated = tag;
        if (tag.colorValue == null) {
          final color = defaultTagColorValues[key];
          if (color != null) {
            updated = updated.copyWith(colorValue: Value(color));
          }
        }
        if (tag.iconKey == null) {
          final iconKey = defaultIconKeyForStableKey(key);
          if (iconKey != null) {
            updated = updated.copyWith(iconKey: Value(iconKey));
          }
        }
        if (updated != tag) {
          await _db.updateTagRow(updated);
        }
      }
    }

    // Income seeds are ensured independently so upgrades from an
    // expense-only install still get default income categories.
    final afterExpense = await _db.watchTagsList();
    final hasIncomeTags =
        afterExpense.any((t) => tagKindOf(t) == TagKind.income);
    if (!hasIncomeTags) {
      for (final key in defaultSeedIncomeTagKeys) {
        await _db.ensureTagByStableKey(
          stableKey: key,
          fallbackName: key,
          isDefault: true,
          kind: tagKindDbValue(TagKind.income),
          colorValue: defaultTagColorValues[key],
          iconKey: defaultIconKeyForStableKey(key),
        );
      }
    }

    await _seedDefaultSubtags();
  }

  /// Ensures default subcategories exist under seeded parent categories.
  Future<void> _seedDefaultSubtags() async {
    final tags = await _db.watchTagsList();
    final byStableKey = <String, Tag>{
      for (final t in tags)
        if (t.stableKey != null) t.stableKey!: t,
    };

    Future<void> seedMap(
      Map<String, List<String>> map,
      String kind,
    ) async {
      for (final entry in map.entries) {
        final parent = byStableKey[entry.key];
        if (parent == null || parent.parentTagId != null) continue;
        for (final childKey in entry.value) {
          final id = await _db.ensureTagByStableKey(
            stableKey: childKey,
            fallbackName: childKey,
            isDefault: true,
            kind: kind,
            colorValue: parent.colorValue ?? defaultTagColorValues[entry.key],
            iconKey: defaultIconKeyForStableKey(childKey),
            parentTagId: parent.id,
          );
          // Refresh local cache for subsequent lookups in this pass.
          final child = await _db.findByStableKey(childKey);
          if (child != null) byStableKey[childKey] = child;
          if (id <= 0) continue;
        }
      }
    }

    await seedMap(
      defaultSeedSubtagKeysByCategory,
      tagKindDbValue(TagKind.custom),
    );
    await seedMap(
      defaultSeedIncomeSubtagKeysByCategory,
      tagKindDbValue(TagKind.income),
    );
  }

  Future<int> addTag(
    String name, {
    bool isDefault = false,
    String? stableKey,
    String kind = 'normal',
    int? colorValue,
    String? iconKey,
    int? parentTagId,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty && stableKey == null) return -1;
    if (stableKey != null) {
      return _db.ensureTagByStableKey(
        stableKey: stableKey,
        fallbackName: trimmed.isEmpty ? stableKey : trimmed,
        isDefault: isDefault,
        kind: kind,
        colorValue: colorValue ?? defaultTagColorValues[stableKey],
        iconKey: iconKey ?? defaultIconKeyForStableKey(stableKey),
        parentTagId: parentTagId,
      );
    }
    final tags = await _db.watchTagsList();
    final nextOrder =
        tags.isEmpty ? 0 : tags.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    return _db.insertTag(
      TagsCompanion.insert(
        name: trimmed,
        kind: Value(kind),
        colorValue: Value(colorValue),
        iconKey: Value(iconKey),
        isDefault: Value(isDefault),
        sortOrder: Value(nextOrder),
        parentTagId: Value(parentTagId),
      ),
    );
  }

  Future<void> renameTag(
    Tag tag,
    String name, {
    int? colorValue,
    bool clearColor = false,
    String? iconKey,
    int? parentTagId,
    bool clearParent = false,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await (_db.update(_db.tags)..where((t) => t.id.equals(tag.id))).write(
      TagsCompanion(
        name: Value(trimmed),
        stableKey: const Value(null),
        colorValue: clearColor
            ? const Value(null)
            : (colorValue != null ? Value(colorValue) : const Value.absent()),
        iconKey: iconKey != null ? Value(iconKey) : const Value.absent(),
        parentTagId: clearParent
            ? const Value(null)
            : (parentTagId != null ? Value(parentTagId) : const Value.absent()),
      ),
    );
  }

  Future<void> setTagColor(Tag tag, int? colorValue) async {
    await (_db.update(_db.tags)..where((t) => t.id.equals(tag.id))).write(
      TagsCompanion(colorValue: Value(colorValue)),
    );
  }

  Future<void> setTagIcon(Tag tag, String? iconKey) async {
    await (_db.update(_db.tags)..where((t) => t.id.equals(tag.id))).write(
      TagsCompanion(iconKey: Value(iconKey)),
    );
  }

  Future<void> deleteTag(int id) async {
    await _db.deleteTagById(id);
    final settings = ref.read(appSettingsProvider).value;
    final notifier = ref.read(appSettingsProvider.notifier);
    if (settings?.defaultTagId == id) {
      await notifier.setDefaultTagId(null);
    }
    if (settings?.lastIncomeTagId == id) {
      await notifier.setLastIncomeTagId(null);
    }
    if (settings?.defaultSubtagId == id) {
      await notifier.setDefaultSubtagId(null);
    }
    if (settings?.lastIncomeSubtagId == id) {
      await notifier.setLastIncomeSubtagId(null);
    }
  }
}

final manageTagsControllerProvider = Provider<ManageTagsController>((ref) {
  return ManageTagsController(ref);
});
