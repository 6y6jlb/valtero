import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/consts/palette.dart';
import 'package:valtero/shared/consts/tag_suggestions.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

class ManageTagsController {
  final Ref ref;

  ManageTagsController(this.ref);

  AppDatabase get _db => ref.read(appDatabaseProvider);

  /// Seeds category tags on first launch.
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
            isDefault: const Value(true),
            sortOrder: Value(order++),
          ),
        );
      }
    } else {
      for (final tag in existing) {
        final key = tag.stableKey;
        if (key == null || tag.colorValue != null) continue;
        final color = defaultTagColorValues[key];
        if (color != null) {
          await _db.updateTagRow(tag.copyWith(colorValue: Value(color)));
        }
      }
    }
  }

  Future<int> addTag(
    String name, {
    bool isDefault = false,
    String? stableKey,
    String kind = 'normal',
    int? colorValue,
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
        isDefault: Value(isDefault),
        sortOrder: Value(nextOrder),
      ),
    );
  }

  Future<void> renameTag(Tag tag, String name, {int? colorValue, bool clearColor = false}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await (_db.update(_db.tags)..where((t) => t.id.equals(tag.id))).write(
      TagsCompanion(
        name: Value(trimmed),
        stableKey: const Value(null),
        colorValue: clearColor
            ? const Value(null)
            : (colorValue != null ? Value(colorValue) : const Value.absent()),
      ),
    );
  }

  Future<void> setTagColor(Tag tag, int? colorValue) async {
    await (_db.update(_db.tags)..where((t) => t.id.equals(tag.id))).write(
      TagsCompanion(colorValue: Value(colorValue)),
    );
  }

  Future<void> deleteTag(int id) async {
    await _db.deleteTagById(id);
    final settings = ref.read(appSettingsProvider).value;
    if (settings?.defaultTagId == id) {
      await ref.read(appSettingsProvider.notifier).setDefaultTagId(null);
    }
  }
}

final manageTagsControllerProvider = Provider<ManageTagsController>((ref) {
  return ManageTagsController(ref);
});
