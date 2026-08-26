import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

const List<String> defaultSeedTagNames = [
  'Groceries',
  'Transport',
  'Housing',
  'Dining',
  'Health',
  'Entertainment',
  'Shopping',
  'Travel',
];

class ManageTagsController {
  final Ref ref;

  ManageTagsController(this.ref);

  AppDatabase get _db => ref.read(appDatabaseProvider);

  Future<void> seedDefaultsIfEmpty() async {
    final existing = await _db.watchTagsList();
    if (existing.isNotEmpty) return;
    var order = 0;
    for (final name in defaultSeedTagNames) {
      await _db.insertTag(
        TagsCompanion.insert(
          name: name,
          isDefault: const Value(true),
          sortOrder: Value(order++),
        ),
      );
    }
  }

  Future<int> addTag(String name, {bool isDefault = false}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return -1;
    final tags = await _db.watchTagsList();
    final nextOrder =
        tags.isEmpty ? 0 : tags.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    return _db.insertTag(
      TagsCompanion.insert(
        name: trimmed,
        isDefault: Value(isDefault),
        sortOrder: Value(nextOrder),
      ),
    );
  }

  Future<void> renameTag(Tag tag, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _db.updateTagRow(tag.copyWith(name: trimmed));
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
