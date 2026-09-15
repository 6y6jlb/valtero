import 'package:drift/drift.dart';

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get colorValue => integer().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  /// `normal` (category). Legacy `country` / `trip` kinds are unused.
  TextColumn get kind => text().withDefault(const Constant('normal'))();
  TextColumn get countryCode => text().nullable()();
  /// Stable id for localized defaults/suggestions, e.g. `groceries`.
  TextColumn get stableKey => text().nullable()();
  /// Curated icon key from [tag_icons.dart], e.g. `groceries`, `salary`.
  TextColumn get iconKey => text().nullable()();
  /// Parent category tag id when this tag is a subcategory. Null = top-level
  /// category. Exactly one level deep (a subcategory's parent must itself be
  /// top-level) — enforced in app code, not the schema.
  IntColumn get parentTagId =>
      integer().nullable().references(Tags, #id, onDelete: KeyAction.setNull)();
}
