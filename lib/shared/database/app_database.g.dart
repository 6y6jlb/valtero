// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('normal'),
  );
  static const VerificationMeta _countryCodeMeta = const VerificationMeta(
    'countryCode',
  );
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
    'country_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stableKeyMeta = const VerificationMeta(
    'stableKey',
  );
  @override
  late final GeneratedColumn<String> stableKey = GeneratedColumn<String>(
    'stable_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentTagIdMeta = const VerificationMeta(
    'parentTagId',
  );
  @override
  late final GeneratedColumn<int> parentTagId = GeneratedColumn<int>(
    'parent_tag_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    colorValue,
    isDefault,
    sortOrder,
    kind,
    countryCode,
    stableKey,
    iconKey,
    parentTagId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('country_code')) {
      context.handle(
        _countryCodeMeta,
        countryCode.isAcceptableOrUnknown(
          data['country_code']!,
          _countryCodeMeta,
        ),
      );
    }
    if (data.containsKey('stable_key')) {
      context.handle(
        _stableKeyMeta,
        stableKey.isAcceptableOrUnknown(data['stable_key']!, _stableKeyMeta),
      );
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    }
    if (data.containsKey('parent_tag_id')) {
      context.handle(
        _parentTagIdMeta,
        parentTagId.isAcceptableOrUnknown(
          data['parent_tag_id']!,
          _parentTagIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      countryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_code'],
      ),
      stableKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stable_key'],
      ),
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      ),
      parentTagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_tag_id'],
      ),
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  final int? colorValue;
  final bool isDefault;
  final int sortOrder;

  /// `normal` (category). Legacy `country` / `trip` kinds are unused.
  final String kind;
  final String? countryCode;

  /// Stable id for localized defaults/suggestions, e.g. `groceries`.
  final String? stableKey;

  /// Curated icon key from [tag_icons.dart], e.g. `groceries`, `salary`.
  final String? iconKey;

  /// Parent category tag id when this tag is a subcategory. Null = top-level
  /// category. Exactly one level deep (a subcategory's parent must itself be
  /// top-level) — enforced in app code, not the schema.
  final int? parentTagId;
  const Tag({
    required this.id,
    required this.name,
    this.colorValue,
    required this.isDefault,
    required this.sortOrder,
    required this.kind,
    this.countryCode,
    this.stableKey,
    this.iconKey,
    this.parentTagId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || colorValue != null) {
      map['color_value'] = Variable<int>(colorValue);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['sort_order'] = Variable<int>(sortOrder);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || countryCode != null) {
      map['country_code'] = Variable<String>(countryCode);
    }
    if (!nullToAbsent || stableKey != null) {
      map['stable_key'] = Variable<String>(stableKey);
    }
    if (!nullToAbsent || iconKey != null) {
      map['icon_key'] = Variable<String>(iconKey);
    }
    if (!nullToAbsent || parentTagId != null) {
      map['parent_tag_id'] = Variable<int>(parentTagId);
    }
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      colorValue: colorValue == null && nullToAbsent
          ? const Value.absent()
          : Value(colorValue),
      isDefault: Value(isDefault),
      sortOrder: Value(sortOrder),
      kind: Value(kind),
      countryCode: countryCode == null && nullToAbsent
          ? const Value.absent()
          : Value(countryCode),
      stableKey: stableKey == null && nullToAbsent
          ? const Value.absent()
          : Value(stableKey),
      iconKey: iconKey == null && nullToAbsent
          ? const Value.absent()
          : Value(iconKey),
      parentTagId: parentTagId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentTagId),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorValue: serializer.fromJson<int?>(json['colorValue']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      kind: serializer.fromJson<String>(json['kind']),
      countryCode: serializer.fromJson<String?>(json['countryCode']),
      stableKey: serializer.fromJson<String?>(json['stableKey']),
      iconKey: serializer.fromJson<String?>(json['iconKey']),
      parentTagId: serializer.fromJson<int?>(json['parentTagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'colorValue': serializer.toJson<int?>(colorValue),
      'isDefault': serializer.toJson<bool>(isDefault),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'kind': serializer.toJson<String>(kind),
      'countryCode': serializer.toJson<String?>(countryCode),
      'stableKey': serializer.toJson<String?>(stableKey),
      'iconKey': serializer.toJson<String?>(iconKey),
      'parentTagId': serializer.toJson<int?>(parentTagId),
    };
  }

  Tag copyWith({
    int? id,
    String? name,
    Value<int?> colorValue = const Value.absent(),
    bool? isDefault,
    int? sortOrder,
    String? kind,
    Value<String?> countryCode = const Value.absent(),
    Value<String?> stableKey = const Value.absent(),
    Value<String?> iconKey = const Value.absent(),
    Value<int?> parentTagId = const Value.absent(),
  }) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    colorValue: colorValue.present ? colorValue.value : this.colorValue,
    isDefault: isDefault ?? this.isDefault,
    sortOrder: sortOrder ?? this.sortOrder,
    kind: kind ?? this.kind,
    countryCode: countryCode.present ? countryCode.value : this.countryCode,
    stableKey: stableKey.present ? stableKey.value : this.stableKey,
    iconKey: iconKey.present ? iconKey.value : this.iconKey,
    parentTagId: parentTagId.present ? parentTagId.value : this.parentTagId,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      kind: data.kind.present ? data.kind.value : this.kind,
      countryCode: data.countryCode.present
          ? data.countryCode.value
          : this.countryCode,
      stableKey: data.stableKey.present ? data.stableKey.value : this.stableKey,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      parentTagId: data.parentTagId.present
          ? data.parentTagId.value
          : this.parentTagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('isDefault: $isDefault, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('kind: $kind, ')
          ..write('countryCode: $countryCode, ')
          ..write('stableKey: $stableKey, ')
          ..write('iconKey: $iconKey, ')
          ..write('parentTagId: $parentTagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    colorValue,
    isDefault,
    sortOrder,
    kind,
    countryCode,
    stableKey,
    iconKey,
    parentTagId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorValue == this.colorValue &&
          other.isDefault == this.isDefault &&
          other.sortOrder == this.sortOrder &&
          other.kind == this.kind &&
          other.countryCode == this.countryCode &&
          other.stableKey == this.stableKey &&
          other.iconKey == this.iconKey &&
          other.parentTagId == this.parentTagId);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> colorValue;
  final Value<bool> isDefault;
  final Value<int> sortOrder;
  final Value<String> kind;
  final Value<String?> countryCode;
  final Value<String?> stableKey;
  final Value<String?> iconKey;
  final Value<int?> parentTagId;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.kind = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.stableKey = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.parentTagId = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.colorValue = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.kind = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.stableKey = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.parentTagId = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? colorValue,
    Expression<bool>? isDefault,
    Expression<int>? sortOrder,
    Expression<String>? kind,
    Expression<String>? countryCode,
    Expression<String>? stableKey,
    Expression<String>? iconKey,
    Expression<int>? parentTagId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorValue != null) 'color_value': colorValue,
      if (isDefault != null) 'is_default': isDefault,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (kind != null) 'kind': kind,
      if (countryCode != null) 'country_code': countryCode,
      if (stableKey != null) 'stable_key': stableKey,
      if (iconKey != null) 'icon_key': iconKey,
      if (parentTagId != null) 'parent_tag_id': parentTagId,
    });
  }

  TagsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? colorValue,
    Value<bool>? isDefault,
    Value<int>? sortOrder,
    Value<String>? kind,
    Value<String?>? countryCode,
    Value<String?>? stableKey,
    Value<String?>? iconKey,
    Value<int?>? parentTagId,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      kind: kind ?? this.kind,
      countryCode: countryCode ?? this.countryCode,
      stableKey: stableKey ?? this.stableKey,
      iconKey: iconKey ?? this.iconKey,
      parentTagId: parentTagId ?? this.parentTagId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (stableKey.present) {
      map['stable_key'] = Variable<String>(stableKey.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (parentTagId.present) {
      map['parent_tag_id'] = Variable<int>(parentTagId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('isDefault: $isDefault, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('kind: $kind, ')
          ..write('countryCode: $countryCode, ')
          ..write('stableKey: $stableKey, ')
          ..write('iconKey: $iconKey, ')
          ..write('parentTagId: $parentTagId')
          ..write(')'))
        .toString();
  }
}

class $PaymentMethodsTable extends PaymentMethods
    with TableInfo<$PaymentMethodsTable, PaymentMethod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentMethodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stableKeyMeta = const VerificationMeta(
    'stableKey',
  );
  @override
  late final GeneratedColumn<String> stableKey = GeneratedColumn<String>(
    'stable_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    colorValue,
    isDefault,
    sortOrder,
    stableKey,
    iconKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_methods';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentMethod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('stable_key')) {
      context.handle(
        _stableKeyMeta,
        stableKey.isAcceptableOrUnknown(data['stable_key']!, _stableKeyMeta),
      );
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentMethod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentMethod(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      stableKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stable_key'],
      ),
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      ),
    );
  }

  @override
  $PaymentMethodsTable createAlias(String alias) {
    return $PaymentMethodsTable(attachedDatabase, alias);
  }
}

class PaymentMethod extends DataClass implements Insertable<PaymentMethod> {
  final int id;
  final String name;
  final int? colorValue;
  final bool isDefault;
  final int sortOrder;

  /// Stable id for seeded methods, e.g. `cash`, `card`, `crypto`.
  final String? stableKey;

  /// Optional curated icon key (same catalog as tags).
  final String? iconKey;
  const PaymentMethod({
    required this.id,
    required this.name,
    this.colorValue,
    required this.isDefault,
    required this.sortOrder,
    this.stableKey,
    this.iconKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || colorValue != null) {
      map['color_value'] = Variable<int>(colorValue);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || stableKey != null) {
      map['stable_key'] = Variable<String>(stableKey);
    }
    if (!nullToAbsent || iconKey != null) {
      map['icon_key'] = Variable<String>(iconKey);
    }
    return map;
  }

  PaymentMethodsCompanion toCompanion(bool nullToAbsent) {
    return PaymentMethodsCompanion(
      id: Value(id),
      name: Value(name),
      colorValue: colorValue == null && nullToAbsent
          ? const Value.absent()
          : Value(colorValue),
      isDefault: Value(isDefault),
      sortOrder: Value(sortOrder),
      stableKey: stableKey == null && nullToAbsent
          ? const Value.absent()
          : Value(stableKey),
      iconKey: iconKey == null && nullToAbsent
          ? const Value.absent()
          : Value(iconKey),
    );
  }

  factory PaymentMethod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentMethod(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorValue: serializer.fromJson<int?>(json['colorValue']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      stableKey: serializer.fromJson<String?>(json['stableKey']),
      iconKey: serializer.fromJson<String?>(json['iconKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'colorValue': serializer.toJson<int?>(colorValue),
      'isDefault': serializer.toJson<bool>(isDefault),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'stableKey': serializer.toJson<String?>(stableKey),
      'iconKey': serializer.toJson<String?>(iconKey),
    };
  }

  PaymentMethod copyWith({
    int? id,
    String? name,
    Value<int?> colorValue = const Value.absent(),
    bool? isDefault,
    int? sortOrder,
    Value<String?> stableKey = const Value.absent(),
    Value<String?> iconKey = const Value.absent(),
  }) => PaymentMethod(
    id: id ?? this.id,
    name: name ?? this.name,
    colorValue: colorValue.present ? colorValue.value : this.colorValue,
    isDefault: isDefault ?? this.isDefault,
    sortOrder: sortOrder ?? this.sortOrder,
    stableKey: stableKey.present ? stableKey.value : this.stableKey,
    iconKey: iconKey.present ? iconKey.value : this.iconKey,
  );
  PaymentMethod copyWithCompanion(PaymentMethodsCompanion data) {
    return PaymentMethod(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      stableKey: data.stableKey.present ? data.stableKey.value : this.stableKey,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentMethod(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('isDefault: $isDefault, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('stableKey: $stableKey, ')
          ..write('iconKey: $iconKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    colorValue,
    isDefault,
    sortOrder,
    stableKey,
    iconKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentMethod &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorValue == this.colorValue &&
          other.isDefault == this.isDefault &&
          other.sortOrder == this.sortOrder &&
          other.stableKey == this.stableKey &&
          other.iconKey == this.iconKey);
}

class PaymentMethodsCompanion extends UpdateCompanion<PaymentMethod> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> colorValue;
  final Value<bool> isDefault;
  final Value<int> sortOrder;
  final Value<String?> stableKey;
  final Value<String?> iconKey;
  const PaymentMethodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.stableKey = const Value.absent(),
    this.iconKey = const Value.absent(),
  });
  PaymentMethodsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.colorValue = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.stableKey = const Value.absent(),
    this.iconKey = const Value.absent(),
  }) : name = Value(name);
  static Insertable<PaymentMethod> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? colorValue,
    Expression<bool>? isDefault,
    Expression<int>? sortOrder,
    Expression<String>? stableKey,
    Expression<String>? iconKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorValue != null) 'color_value': colorValue,
      if (isDefault != null) 'is_default': isDefault,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (stableKey != null) 'stable_key': stableKey,
      if (iconKey != null) 'icon_key': iconKey,
    });
  }

  PaymentMethodsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? colorValue,
    Value<bool>? isDefault,
    Value<int>? sortOrder,
    Value<String?>? stableKey,
    Value<String?>? iconKey,
  }) {
    return PaymentMethodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      stableKey: stableKey ?? this.stableKey,
      iconKey: iconKey ?? this.iconKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (stableKey.present) {
      map['stable_key'] = Variable<String>(stableKey.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentMethodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('isDefault: $isDefault, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('stableKey: $stableKey, ')
          ..write('iconKey: $iconKey')
          ..write(')'))
        .toString();
  }
}

class $OperationsTable extends Operations
    with TableInfo<$OperationsTable, Operation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newSyncId,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalAmountMinorMeta =
      const VerificationMeta('originalAmountMinor');
  @override
  late final GeneratedColumn<int> originalAmountMinor = GeneratedColumn<int>(
    'original_amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalCurrencyCodeMeta =
      const VerificationMeta('originalCurrencyCode');
  @override
  late final GeneratedColumn<String> originalCurrencyCode =
      GeneratedColumn<String>(
        'original_currency_code',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 3,
          maxTextLength: 3,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _storedAmountMinorMeta = const VerificationMeta(
    'storedAmountMinor',
  );
  @override
  late final GeneratedColumn<int> storedAmountMinor = GeneratedColumn<int>(
    'stored_amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storedCurrencyCodeMeta =
      const VerificationMeta('storedCurrencyCode');
  @override
  late final GeneratedColumn<String> storedCurrencyCode =
      GeneratedColumn<String>(
        'stored_currency_code',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 3,
          maxTextLength: 3,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _rateUsedMeta = const VerificationMeta(
    'rateUsed',
  );
  @override
  late final GeneratedColumn<double> rateUsed = GeneratedColumn<double>(
    'rate_used',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rateTimestampMeta = const VerificationMeta(
    'rateTimestamp',
  );
  @override
  late final GeneratedColumn<DateTime> rateTimestamp =
      GeneratedColumn<DateTime>(
        'rate_timestamp',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _paymentMethodIdMeta = const VerificationMeta(
    'paymentMethodId',
  );
  @override
  late final GeneratedColumn<int> paymentMethodId = GeneratedColumn<int>(
    'payment_method_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES payment_methods (id)',
    ),
  );
  static const VerificationMeta _countryCodeMeta = const VerificationMeta(
    'countryCode',
  );
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
    'country_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _duplicateDismissedMeta =
      const VerificationMeta('duplicateDismissed');
  @override
  late final GeneratedColumn<bool> duplicateDismissed = GeneratedColumn<bool>(
    'duplicate_dismissed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("duplicate_dismissed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    kind,
    occurredAt,
    originalAmountMinor,
    originalCurrencyCode,
    storedAmountMinor,
    storedCurrencyCode,
    rateUsed,
    rateTimestamp,
    paymentMethodId,
    countryCode,
    note,
    createdAt,
    updatedAt,
    deletedAt,
    duplicateDismissed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Operation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('original_amount_minor')) {
      context.handle(
        _originalAmountMinorMeta,
        originalAmountMinor.isAcceptableOrUnknown(
          data['original_amount_minor']!,
          _originalAmountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalAmountMinorMeta);
    }
    if (data.containsKey('original_currency_code')) {
      context.handle(
        _originalCurrencyCodeMeta,
        originalCurrencyCode.isAcceptableOrUnknown(
          data['original_currency_code']!,
          _originalCurrencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalCurrencyCodeMeta);
    }
    if (data.containsKey('stored_amount_minor')) {
      context.handle(
        _storedAmountMinorMeta,
        storedAmountMinor.isAcceptableOrUnknown(
          data['stored_amount_minor']!,
          _storedAmountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storedAmountMinorMeta);
    }
    if (data.containsKey('stored_currency_code')) {
      context.handle(
        _storedCurrencyCodeMeta,
        storedCurrencyCode.isAcceptableOrUnknown(
          data['stored_currency_code']!,
          _storedCurrencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storedCurrencyCodeMeta);
    }
    if (data.containsKey('rate_used')) {
      context.handle(
        _rateUsedMeta,
        rateUsed.isAcceptableOrUnknown(data['rate_used']!, _rateUsedMeta),
      );
    }
    if (data.containsKey('rate_timestamp')) {
      context.handle(
        _rateTimestampMeta,
        rateTimestamp.isAcceptableOrUnknown(
          data['rate_timestamp']!,
          _rateTimestampMeta,
        ),
      );
    }
    if (data.containsKey('payment_method_id')) {
      context.handle(
        _paymentMethodIdMeta,
        paymentMethodId.isAcceptableOrUnknown(
          data['payment_method_id']!,
          _paymentMethodIdMeta,
        ),
      );
    }
    if (data.containsKey('country_code')) {
      context.handle(
        _countryCodeMeta,
        countryCode.isAcceptableOrUnknown(
          data['country_code']!,
          _countryCodeMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('duplicate_dismissed')) {
      context.handle(
        _duplicateDismissedMeta,
        duplicateDismissed.isAcceptableOrUnknown(
          data['duplicate_dismissed']!,
          _duplicateDismissedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Operation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Operation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      originalAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_amount_minor'],
      )!,
      originalCurrencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_currency_code'],
      )!,
      storedAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stored_amount_minor'],
      )!,
      storedCurrencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stored_currency_code'],
      )!,
      rateUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate_used'],
      ),
      rateTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}rate_timestamp'],
      ),
      paymentMethodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_method_id'],
      ),
      countryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_code'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      duplicateDismissed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}duplicate_dismissed'],
      )!,
    );
  }

  @override
  $OperationsTable createAlias(String alias) {
    return $OperationsTable(attachedDatabase, alias);
  }
}

class Operation extends DataClass implements Insertable<Operation> {
  final int id;

  /// Cross-device identity for sync / backup merge (UUID v4).
  final String syncId;

  /// `'expense'` or `'income'`.
  final String kind;
  final DateTime occurredAt;
  final int originalAmountMinor;
  final String originalCurrencyCode;
  final int storedAmountMinor;
  final String storedCurrencyCode;
  final double? rateUsed;
  final DateTime? rateTimestamp;
  final int? paymentMethodId;

  /// ISO 3166-1 alpha-2 country code (e.g. `RU`), not a tag.
  final String? countryCode;
  final String? note;
  final DateTime createdAt;

  /// Last local create/edit/delete clock — used for last-write-wins sync.
  final DateTime updatedAt;

  /// Soft-delete tombstone; live rows have `null`.
  final DateTime? deletedAt;

  /// User confirmed this row is not a duplicate of others sharing
  /// the same day + original amount + currency fingerprint.
  final bool duplicateDismissed;
  const Operation({
    required this.id,
    required this.syncId,
    required this.kind,
    required this.occurredAt,
    required this.originalAmountMinor,
    required this.originalCurrencyCode,
    required this.storedAmountMinor,
    required this.storedCurrencyCode,
    this.rateUsed,
    this.rateTimestamp,
    this.paymentMethodId,
    this.countryCode,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.duplicateDismissed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_id'] = Variable<String>(syncId);
    map['kind'] = Variable<String>(kind);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['original_amount_minor'] = Variable<int>(originalAmountMinor);
    map['original_currency_code'] = Variable<String>(originalCurrencyCode);
    map['stored_amount_minor'] = Variable<int>(storedAmountMinor);
    map['stored_currency_code'] = Variable<String>(storedCurrencyCode);
    if (!nullToAbsent || rateUsed != null) {
      map['rate_used'] = Variable<double>(rateUsed);
    }
    if (!nullToAbsent || rateTimestamp != null) {
      map['rate_timestamp'] = Variable<DateTime>(rateTimestamp);
    }
    if (!nullToAbsent || paymentMethodId != null) {
      map['payment_method_id'] = Variable<int>(paymentMethodId);
    }
    if (!nullToAbsent || countryCode != null) {
      map['country_code'] = Variable<String>(countryCode);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['duplicate_dismissed'] = Variable<bool>(duplicateDismissed);
    return map;
  }

  OperationsCompanion toCompanion(bool nullToAbsent) {
    return OperationsCompanion(
      id: Value(id),
      syncId: Value(syncId),
      kind: Value(kind),
      occurredAt: Value(occurredAt),
      originalAmountMinor: Value(originalAmountMinor),
      originalCurrencyCode: Value(originalCurrencyCode),
      storedAmountMinor: Value(storedAmountMinor),
      storedCurrencyCode: Value(storedCurrencyCode),
      rateUsed: rateUsed == null && nullToAbsent
          ? const Value.absent()
          : Value(rateUsed),
      rateTimestamp: rateTimestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(rateTimestamp),
      paymentMethodId: paymentMethodId == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethodId),
      countryCode: countryCode == null && nullToAbsent
          ? const Value.absent()
          : Value(countryCode),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      duplicateDismissed: Value(duplicateDismissed),
    );
  }

  factory Operation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Operation(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String>(json['syncId']),
      kind: serializer.fromJson<String>(json['kind']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      originalAmountMinor: serializer.fromJson<int>(
        json['originalAmountMinor'],
      ),
      originalCurrencyCode: serializer.fromJson<String>(
        json['originalCurrencyCode'],
      ),
      storedAmountMinor: serializer.fromJson<int>(json['storedAmountMinor']),
      storedCurrencyCode: serializer.fromJson<String>(
        json['storedCurrencyCode'],
      ),
      rateUsed: serializer.fromJson<double?>(json['rateUsed']),
      rateTimestamp: serializer.fromJson<DateTime?>(json['rateTimestamp']),
      paymentMethodId: serializer.fromJson<int?>(json['paymentMethodId']),
      countryCode: serializer.fromJson<String?>(json['countryCode']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      duplicateDismissed: serializer.fromJson<bool>(json['duplicateDismissed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String>(syncId),
      'kind': serializer.toJson<String>(kind),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'originalAmountMinor': serializer.toJson<int>(originalAmountMinor),
      'originalCurrencyCode': serializer.toJson<String>(originalCurrencyCode),
      'storedAmountMinor': serializer.toJson<int>(storedAmountMinor),
      'storedCurrencyCode': serializer.toJson<String>(storedCurrencyCode),
      'rateUsed': serializer.toJson<double?>(rateUsed),
      'rateTimestamp': serializer.toJson<DateTime?>(rateTimestamp),
      'paymentMethodId': serializer.toJson<int?>(paymentMethodId),
      'countryCode': serializer.toJson<String?>(countryCode),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'duplicateDismissed': serializer.toJson<bool>(duplicateDismissed),
    };
  }

  Operation copyWith({
    int? id,
    String? syncId,
    String? kind,
    DateTime? occurredAt,
    int? originalAmountMinor,
    String? originalCurrencyCode,
    int? storedAmountMinor,
    String? storedCurrencyCode,
    Value<double?> rateUsed = const Value.absent(),
    Value<DateTime?> rateTimestamp = const Value.absent(),
    Value<int?> paymentMethodId = const Value.absent(),
    Value<String?> countryCode = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? duplicateDismissed,
  }) => Operation(
    id: id ?? this.id,
    syncId: syncId ?? this.syncId,
    kind: kind ?? this.kind,
    occurredAt: occurredAt ?? this.occurredAt,
    originalAmountMinor: originalAmountMinor ?? this.originalAmountMinor,
    originalCurrencyCode: originalCurrencyCode ?? this.originalCurrencyCode,
    storedAmountMinor: storedAmountMinor ?? this.storedAmountMinor,
    storedCurrencyCode: storedCurrencyCode ?? this.storedCurrencyCode,
    rateUsed: rateUsed.present ? rateUsed.value : this.rateUsed,
    rateTimestamp: rateTimestamp.present
        ? rateTimestamp.value
        : this.rateTimestamp,
    paymentMethodId: paymentMethodId.present
        ? paymentMethodId.value
        : this.paymentMethodId,
    countryCode: countryCode.present ? countryCode.value : this.countryCode,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    duplicateDismissed: duplicateDismissed ?? this.duplicateDismissed,
  );
  Operation copyWithCompanion(OperationsCompanion data) {
    return Operation(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      kind: data.kind.present ? data.kind.value : this.kind,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      originalAmountMinor: data.originalAmountMinor.present
          ? data.originalAmountMinor.value
          : this.originalAmountMinor,
      originalCurrencyCode: data.originalCurrencyCode.present
          ? data.originalCurrencyCode.value
          : this.originalCurrencyCode,
      storedAmountMinor: data.storedAmountMinor.present
          ? data.storedAmountMinor.value
          : this.storedAmountMinor,
      storedCurrencyCode: data.storedCurrencyCode.present
          ? data.storedCurrencyCode.value
          : this.storedCurrencyCode,
      rateUsed: data.rateUsed.present ? data.rateUsed.value : this.rateUsed,
      rateTimestamp: data.rateTimestamp.present
          ? data.rateTimestamp.value
          : this.rateTimestamp,
      paymentMethodId: data.paymentMethodId.present
          ? data.paymentMethodId.value
          : this.paymentMethodId,
      countryCode: data.countryCode.present
          ? data.countryCode.value
          : this.countryCode,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      duplicateDismissed: data.duplicateDismissed.present
          ? data.duplicateDismissed.value
          : this.duplicateDismissed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Operation(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('kind: $kind, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('originalAmountMinor: $originalAmountMinor, ')
          ..write('originalCurrencyCode: $originalCurrencyCode, ')
          ..write('storedAmountMinor: $storedAmountMinor, ')
          ..write('storedCurrencyCode: $storedCurrencyCode, ')
          ..write('rateUsed: $rateUsed, ')
          ..write('rateTimestamp: $rateTimestamp, ')
          ..write('paymentMethodId: $paymentMethodId, ')
          ..write('countryCode: $countryCode, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('duplicateDismissed: $duplicateDismissed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    kind,
    occurredAt,
    originalAmountMinor,
    originalCurrencyCode,
    storedAmountMinor,
    storedCurrencyCode,
    rateUsed,
    rateTimestamp,
    paymentMethodId,
    countryCode,
    note,
    createdAt,
    updatedAt,
    deletedAt,
    duplicateDismissed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Operation &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.kind == this.kind &&
          other.occurredAt == this.occurredAt &&
          other.originalAmountMinor == this.originalAmountMinor &&
          other.originalCurrencyCode == this.originalCurrencyCode &&
          other.storedAmountMinor == this.storedAmountMinor &&
          other.storedCurrencyCode == this.storedCurrencyCode &&
          other.rateUsed == this.rateUsed &&
          other.rateTimestamp == this.rateTimestamp &&
          other.paymentMethodId == this.paymentMethodId &&
          other.countryCode == this.countryCode &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.duplicateDismissed == this.duplicateDismissed);
}

class OperationsCompanion extends UpdateCompanion<Operation> {
  final Value<int> id;
  final Value<String> syncId;
  final Value<String> kind;
  final Value<DateTime> occurredAt;
  final Value<int> originalAmountMinor;
  final Value<String> originalCurrencyCode;
  final Value<int> storedAmountMinor;
  final Value<String> storedCurrencyCode;
  final Value<double?> rateUsed;
  final Value<DateTime?> rateTimestamp;
  final Value<int?> paymentMethodId;
  final Value<String?> countryCode;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> duplicateDismissed;
  const OperationsCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.kind = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.originalAmountMinor = const Value.absent(),
    this.originalCurrencyCode = const Value.absent(),
    this.storedAmountMinor = const Value.absent(),
    this.storedCurrencyCode = const Value.absent(),
    this.rateUsed = const Value.absent(),
    this.rateTimestamp = const Value.absent(),
    this.paymentMethodId = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.duplicateDismissed = const Value.absent(),
  });
  OperationsCompanion.insert({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    required String kind,
    required DateTime occurredAt,
    required int originalAmountMinor,
    required String originalCurrencyCode,
    required int storedAmountMinor,
    required String storedCurrencyCode,
    this.rateUsed = const Value.absent(),
    this.rateTimestamp = const Value.absent(),
    this.paymentMethodId = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.duplicateDismissed = const Value.absent(),
  }) : kind = Value(kind),
       occurredAt = Value(occurredAt),
       originalAmountMinor = Value(originalAmountMinor),
       originalCurrencyCode = Value(originalCurrencyCode),
       storedAmountMinor = Value(storedAmountMinor),
       storedCurrencyCode = Value(storedCurrencyCode),
       createdAt = Value(createdAt);
  static Insertable<Operation> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<String>? kind,
    Expression<DateTime>? occurredAt,
    Expression<int>? originalAmountMinor,
    Expression<String>? originalCurrencyCode,
    Expression<int>? storedAmountMinor,
    Expression<String>? storedCurrencyCode,
    Expression<double>? rateUsed,
    Expression<DateTime>? rateTimestamp,
    Expression<int>? paymentMethodId,
    Expression<String>? countryCode,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? duplicateDismissed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (kind != null) 'kind': kind,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (originalAmountMinor != null)
        'original_amount_minor': originalAmountMinor,
      if (originalCurrencyCode != null)
        'original_currency_code': originalCurrencyCode,
      if (storedAmountMinor != null) 'stored_amount_minor': storedAmountMinor,
      if (storedCurrencyCode != null)
        'stored_currency_code': storedCurrencyCode,
      if (rateUsed != null) 'rate_used': rateUsed,
      if (rateTimestamp != null) 'rate_timestamp': rateTimestamp,
      if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      if (countryCode != null) 'country_code': countryCode,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (duplicateDismissed != null) 'duplicate_dismissed': duplicateDismissed,
    });
  }

  OperationsCompanion copyWith({
    Value<int>? id,
    Value<String>? syncId,
    Value<String>? kind,
    Value<DateTime>? occurredAt,
    Value<int>? originalAmountMinor,
    Value<String>? originalCurrencyCode,
    Value<int>? storedAmountMinor,
    Value<String>? storedCurrencyCode,
    Value<double?>? rateUsed,
    Value<DateTime?>? rateTimestamp,
    Value<int?>? paymentMethodId,
    Value<String?>? countryCode,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? duplicateDismissed,
  }) {
    return OperationsCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      kind: kind ?? this.kind,
      occurredAt: occurredAt ?? this.occurredAt,
      originalAmountMinor: originalAmountMinor ?? this.originalAmountMinor,
      originalCurrencyCode: originalCurrencyCode ?? this.originalCurrencyCode,
      storedAmountMinor: storedAmountMinor ?? this.storedAmountMinor,
      storedCurrencyCode: storedCurrencyCode ?? this.storedCurrencyCode,
      rateUsed: rateUsed ?? this.rateUsed,
      rateTimestamp: rateTimestamp ?? this.rateTimestamp,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      countryCode: countryCode ?? this.countryCode,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      duplicateDismissed: duplicateDismissed ?? this.duplicateDismissed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (originalAmountMinor.present) {
      map['original_amount_minor'] = Variable<int>(originalAmountMinor.value);
    }
    if (originalCurrencyCode.present) {
      map['original_currency_code'] = Variable<String>(
        originalCurrencyCode.value,
      );
    }
    if (storedAmountMinor.present) {
      map['stored_amount_minor'] = Variable<int>(storedAmountMinor.value);
    }
    if (storedCurrencyCode.present) {
      map['stored_currency_code'] = Variable<String>(storedCurrencyCode.value);
    }
    if (rateUsed.present) {
      map['rate_used'] = Variable<double>(rateUsed.value);
    }
    if (rateTimestamp.present) {
      map['rate_timestamp'] = Variable<DateTime>(rateTimestamp.value);
    }
    if (paymentMethodId.present) {
      map['payment_method_id'] = Variable<int>(paymentMethodId.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (duplicateDismissed.present) {
      map['duplicate_dismissed'] = Variable<bool>(duplicateDismissed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OperationsCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('kind: $kind, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('originalAmountMinor: $originalAmountMinor, ')
          ..write('originalCurrencyCode: $originalCurrencyCode, ')
          ..write('storedAmountMinor: $storedAmountMinor, ')
          ..write('storedCurrencyCode: $storedCurrencyCode, ')
          ..write('rateUsed: $rateUsed, ')
          ..write('rateTimestamp: $rateTimestamp, ')
          ..write('paymentMethodId: $paymentMethodId, ')
          ..write('countryCode: $countryCode, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('duplicateDismissed: $duplicateDismissed')
          ..write(')'))
        .toString();
  }
}

class $OperationTagsTable extends OperationTags
    with TableInfo<$OperationTagsTable, OperationTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OperationTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<int> operationId = GeneratedColumn<int>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES operations (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [operationId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'operation_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<OperationTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId, tagId};
  @override
  OperationTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OperationTag(
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}operation_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $OperationTagsTable createAlias(String alias) {
    return $OperationTagsTable(attachedDatabase, alias);
  }
}

class OperationTag extends DataClass implements Insertable<OperationTag> {
  final int operationId;
  final int tagId;
  const OperationTag({required this.operationId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<int>(operationId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  OperationTagsCompanion toCompanion(bool nullToAbsent) {
    return OperationTagsCompanion(
      operationId: Value(operationId),
      tagId: Value(tagId),
    );
  }

  factory OperationTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OperationTag(
      operationId: serializer.fromJson<int>(json['operationId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<int>(operationId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  OperationTag copyWith({int? operationId, int? tagId}) => OperationTag(
    operationId: operationId ?? this.operationId,
    tagId: tagId ?? this.tagId,
  );
  OperationTag copyWithCompanion(OperationTagsCompanion data) {
    return OperationTag(
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OperationTag(')
          ..write('operationId: $operationId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(operationId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OperationTag &&
          other.operationId == this.operationId &&
          other.tagId == this.tagId);
}

class OperationTagsCompanion extends UpdateCompanion<OperationTag> {
  final Value<int> operationId;
  final Value<int> tagId;
  final Value<int> rowid;
  const OperationTagsCompanion({
    this.operationId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OperationTagsCompanion.insert({
    required int operationId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : operationId = Value(operationId),
       tagId = Value(tagId);
  static Insertable<OperationTag> custom({
    Expression<int>? operationId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OperationTagsCompanion copyWith({
    Value<int>? operationId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return OperationTagsCompanion(
      operationId: operationId ?? this.operationId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<int>(operationId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OperationTagsCompanion(')
          ..write('operationId: $operationId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExchangeRatesTable extends ExchangeRates
    with TableInfo<$ExchangeRatesTable, ExchangeRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExchangeRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _baseCurrencyCodeMeta = const VerificationMeta(
    'baseCurrencyCode',
  );
  @override
  late final GeneratedColumn<String> baseCurrencyCode = GeneratedColumn<String>(
    'base_currency_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCurrencyCodeMeta =
      const VerificationMeta('targetCurrencyCode');
  @override
  late final GeneratedColumn<String> targetCurrencyCode =
      GeneratedColumn<String>(
        'target_currency_code',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 3,
          maxTextLength: 3,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    baseCurrencyCode,
    targetCurrencyCode,
    source,
    rate,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exchange_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExchangeRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('base_currency_code')) {
      context.handle(
        _baseCurrencyCodeMeta,
        baseCurrencyCode.isAcceptableOrUnknown(
          data['base_currency_code']!,
          _baseCurrencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseCurrencyCodeMeta);
    }
    if (data.containsKey('target_currency_code')) {
      context.handle(
        _targetCurrencyCodeMeta,
        targetCurrencyCode.isAcceptableOrUnknown(
          data['target_currency_code']!,
          _targetCurrencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCurrencyCodeMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {baseCurrencyCode, targetCurrencyCode, source},
  ];
  @override
  ExchangeRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeRate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      baseCurrencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency_code'],
      )!,
      targetCurrencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_currency_code'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $ExchangeRatesTable createAlias(String alias) {
    return $ExchangeRatesTable(attachedDatabase, alias);
  }
}

class ExchangeRate extends DataClass implements Insertable<ExchangeRate> {
  final int id;
  final String baseCurrencyCode;
  final String targetCurrencyCode;
  final String source;
  final double rate;
  final DateTime fetchedAt;
  const ExchangeRate({
    required this.id,
    required this.baseCurrencyCode,
    required this.targetCurrencyCode,
    required this.source,
    required this.rate,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['base_currency_code'] = Variable<String>(baseCurrencyCode);
    map['target_currency_code'] = Variable<String>(targetCurrencyCode);
    map['source'] = Variable<String>(source);
    map['rate'] = Variable<double>(rate);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  ExchangeRatesCompanion toCompanion(bool nullToAbsent) {
    return ExchangeRatesCompanion(
      id: Value(id),
      baseCurrencyCode: Value(baseCurrencyCode),
      targetCurrencyCode: Value(targetCurrencyCode),
      source: Value(source),
      rate: Value(rate),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory ExchangeRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeRate(
      id: serializer.fromJson<int>(json['id']),
      baseCurrencyCode: serializer.fromJson<String>(json['baseCurrencyCode']),
      targetCurrencyCode: serializer.fromJson<String>(
        json['targetCurrencyCode'],
      ),
      source: serializer.fromJson<String>(json['source']),
      rate: serializer.fromJson<double>(json['rate']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'baseCurrencyCode': serializer.toJson<String>(baseCurrencyCode),
      'targetCurrencyCode': serializer.toJson<String>(targetCurrencyCode),
      'source': serializer.toJson<String>(source),
      'rate': serializer.toJson<double>(rate),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  ExchangeRate copyWith({
    int? id,
    String? baseCurrencyCode,
    String? targetCurrencyCode,
    String? source,
    double? rate,
    DateTime? fetchedAt,
  }) => ExchangeRate(
    id: id ?? this.id,
    baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
    targetCurrencyCode: targetCurrencyCode ?? this.targetCurrencyCode,
    source: source ?? this.source,
    rate: rate ?? this.rate,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  ExchangeRate copyWithCompanion(ExchangeRatesCompanion data) {
    return ExchangeRate(
      id: data.id.present ? data.id.value : this.id,
      baseCurrencyCode: data.baseCurrencyCode.present
          ? data.baseCurrencyCode.value
          : this.baseCurrencyCode,
      targetCurrencyCode: data.targetCurrencyCode.present
          ? data.targetCurrencyCode.value
          : this.targetCurrencyCode,
      source: data.source.present ? data.source.value : this.source,
      rate: data.rate.present ? data.rate.value : this.rate,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRate(')
          ..write('id: $id, ')
          ..write('baseCurrencyCode: $baseCurrencyCode, ')
          ..write('targetCurrencyCode: $targetCurrencyCode, ')
          ..write('source: $source, ')
          ..write('rate: $rate, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    baseCurrencyCode,
    targetCurrencyCode,
    source,
    rate,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExchangeRate &&
          other.id == this.id &&
          other.baseCurrencyCode == this.baseCurrencyCode &&
          other.targetCurrencyCode == this.targetCurrencyCode &&
          other.source == this.source &&
          other.rate == this.rate &&
          other.fetchedAt == this.fetchedAt);
}

class ExchangeRatesCompanion extends UpdateCompanion<ExchangeRate> {
  final Value<int> id;
  final Value<String> baseCurrencyCode;
  final Value<String> targetCurrencyCode;
  final Value<String> source;
  final Value<double> rate;
  final Value<DateTime> fetchedAt;
  const ExchangeRatesCompanion({
    this.id = const Value.absent(),
    this.baseCurrencyCode = const Value.absent(),
    this.targetCurrencyCode = const Value.absent(),
    this.source = const Value.absent(),
    this.rate = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  ExchangeRatesCompanion.insert({
    this.id = const Value.absent(),
    required String baseCurrencyCode,
    required String targetCurrencyCode,
    required String source,
    required double rate,
    required DateTime fetchedAt,
  }) : baseCurrencyCode = Value(baseCurrencyCode),
       targetCurrencyCode = Value(targetCurrencyCode),
       source = Value(source),
       rate = Value(rate),
       fetchedAt = Value(fetchedAt);
  static Insertable<ExchangeRate> custom({
    Expression<int>? id,
    Expression<String>? baseCurrencyCode,
    Expression<String>? targetCurrencyCode,
    Expression<String>? source,
    Expression<double>? rate,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (baseCurrencyCode != null) 'base_currency_code': baseCurrencyCode,
      if (targetCurrencyCode != null)
        'target_currency_code': targetCurrencyCode,
      if (source != null) 'source': source,
      if (rate != null) 'rate': rate,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  ExchangeRatesCompanion copyWith({
    Value<int>? id,
    Value<String>? baseCurrencyCode,
    Value<String>? targetCurrencyCode,
    Value<String>? source,
    Value<double>? rate,
    Value<DateTime>? fetchedAt,
  }) {
    return ExchangeRatesCompanion(
      id: id ?? this.id,
      baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
      targetCurrencyCode: targetCurrencyCode ?? this.targetCurrencyCode,
      source: source ?? this.source,
      rate: rate ?? this.rate,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (baseCurrencyCode.present) {
      map['base_currency_code'] = Variable<String>(baseCurrencyCode.value);
    }
    if (targetCurrencyCode.present) {
      map['target_currency_code'] = Variable<String>(targetCurrencyCode.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRatesCompanion(')
          ..write('id: $id, ')
          ..write('baseCurrencyCode: $baseCurrencyCode, ')
          ..write('targetCurrencyCode: $targetCurrencyCode, ')
          ..write('source: $source, ')
          ..write('rate: $rate, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $PaymentMethodsTable paymentMethods = $PaymentMethodsTable(this);
  late final $OperationsTable operations = $OperationsTable(this);
  late final $OperationTagsTable operationTags = $OperationTagsTable(this);
  late final $ExchangeRatesTable exchangeRates = $ExchangeRatesTable(this);
  late final Index operationsKindOccurredAt = Index(
    'operations_kind_occurred_at',
    'CREATE INDEX operations_kind_occurred_at ON operations (kind, occurred_at)',
  );
  late final Index operationsSyncId = Index(
    'operations_sync_id',
    'CREATE UNIQUE INDEX operations_sync_id ON operations (sync_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tags,
    paymentMethods,
    operations,
    operationTags,
    exchangeRates,
    operationsKindOccurredAt,
    operationsSyncId,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tags', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'operations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('operation_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('operation_tags', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> colorValue,
      Value<bool> isDefault,
      Value<int> sortOrder,
      Value<String> kind,
      Value<String?> countryCode,
      Value<String?> stableKey,
      Value<String?> iconKey,
      Value<int?> parentTagId,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> colorValue,
      Value<bool> isDefault,
      Value<int> sortOrder,
      Value<String> kind,
      Value<String?> countryCode,
      Value<String?> stableKey,
      Value<String?> iconKey,
      Value<int?> parentTagId,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TagsTable _parentTagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('tags__parent_tag_id__tags__id');

  $$TagsTableProcessedTableManager? get parentTagId {
    final $_column = $_itemColumn<int>('parent_tag_id');
    if ($_column == null) return null;
    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentTagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$OperationTagsTable, List<OperationTag>>
  _operationTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.operationTags,
    aliasName: 'tags__id__operation_tags__tag_id',
  );

  $$OperationTagsTableProcessedTableManager get operationTagsRefs {
    final manager = $$OperationTagsTableTableManager(
      $_db,
      $_db.operationTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_operationTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stableKey => $composableBuilder(
    column: $table.stableKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  $$TagsTableFilterComposer get parentTagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentTagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> operationTagsRefs(
    Expression<bool> Function($$OperationTagsTableFilterComposer f) f,
  ) {
    final $$OperationTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operationTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationTagsTableFilterComposer(
            $db: $db,
            $table: $db.operationTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stableKey => $composableBuilder(
    column: $table.stableKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$TagsTableOrderingComposer get parentTagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentTagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stableKey =>
      $composableBuilder(column: $table.stableKey, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  $$TagsTableAnnotationComposer get parentTagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentTagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> operationTagsRefs<T extends Object>(
    Expression<T> Function($$OperationTagsTableAnnotationComposer a) f,
  ) {
    final $$OperationTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operationTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.operationTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool parentTagId, bool operationTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> colorValue = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> countryCode = const Value.absent(),
                Value<String?> stableKey = const Value.absent(),
                Value<String?> iconKey = const Value.absent(),
                Value<int?> parentTagId = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                colorValue: colorValue,
                isDefault: isDefault,
                sortOrder: sortOrder,
                kind: kind,
                countryCode: countryCode,
                stableKey: stableKey,
                iconKey: iconKey,
                parentTagId: parentTagId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> colorValue = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> countryCode = const Value.absent(),
                Value<String?> stableKey = const Value.absent(),
                Value<String?> iconKey = const Value.absent(),
                Value<int?> parentTagId = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                colorValue: colorValue,
                isDefault: isDefault,
                sortOrder: sortOrder,
                kind: kind,
                countryCode: countryCode,
                stableKey: stableKey,
                iconKey: iconKey,
                parentTagId: parentTagId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({parentTagId = false, operationTagsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (operationTagsRefs) db.operationTags,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (parentTagId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentTagId,
                                    referencedTable: $$TagsTableReferences
                                        ._parentTagIdTable(db),
                                    referencedColumn: $$TagsTableReferences
                                        ._parentTagIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (operationTagsRefs)
                        await $_getPrefetchedData<
                          Tag,
                          $TagsTable,
                          OperationTag
                        >(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._operationTagsRefsTable(db),
                          managerFromTypedResult: (p0) => $$TagsTableReferences(
                            db,
                            table,
                            p0,
                          ).operationTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tagId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool parentTagId, bool operationTagsRefs})
    >;
typedef $$PaymentMethodsTableCreateCompanionBuilder =
    PaymentMethodsCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> colorValue,
      Value<bool> isDefault,
      Value<int> sortOrder,
      Value<String?> stableKey,
      Value<String?> iconKey,
    });
typedef $$PaymentMethodsTableUpdateCompanionBuilder =
    PaymentMethodsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> colorValue,
      Value<bool> isDefault,
      Value<int> sortOrder,
      Value<String?> stableKey,
      Value<String?> iconKey,
    });

final class $$PaymentMethodsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentMethodsTable, PaymentMethod> {
  $$PaymentMethodsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$OperationsTable, List<Operation>>
  _operationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.operations,
    aliasName: 'payment_methods__id__operations__payment_method_id',
  );

  $$OperationsTableProcessedTableManager get operationsRefs {
    final manager = $$OperationsTableTableManager(
      $_db,
      $_db.operations,
    ).filter((f) => f.paymentMethodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_operationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PaymentMethodsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stableKey => $composableBuilder(
    column: $table.stableKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> operationsRefs(
    Expression<bool> Function($$OperationsTableFilterComposer f) f,
  ) {
    final $$OperationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operations,
      getReferencedColumn: (t) => t.paymentMethodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableFilterComposer(
            $db: $db,
            $table: $db.operations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentMethodsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stableKey => $composableBuilder(
    column: $table.stableKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentMethodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get stableKey =>
      $composableBuilder(column: $table.stableKey, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  Expression<T> operationsRefs<T extends Object>(
    Expression<T> Function($$OperationsTableAnnotationComposer a) f,
  ) {
    final $$OperationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operations,
      getReferencedColumn: (t) => t.paymentMethodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableAnnotationComposer(
            $db: $db,
            $table: $db.operations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentMethodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentMethodsTable,
          PaymentMethod,
          $$PaymentMethodsTableFilterComposer,
          $$PaymentMethodsTableOrderingComposer,
          $$PaymentMethodsTableAnnotationComposer,
          $$PaymentMethodsTableCreateCompanionBuilder,
          $$PaymentMethodsTableUpdateCompanionBuilder,
          (PaymentMethod, $$PaymentMethodsTableReferences),
          PaymentMethod,
          PrefetchHooks Function({bool operationsRefs})
        > {
  $$PaymentMethodsTableTableManager(
    _$AppDatabase db,
    $PaymentMethodsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentMethodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentMethodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentMethodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> colorValue = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> stableKey = const Value.absent(),
                Value<String?> iconKey = const Value.absent(),
              }) => PaymentMethodsCompanion(
                id: id,
                name: name,
                colorValue: colorValue,
                isDefault: isDefault,
                sortOrder: sortOrder,
                stableKey: stableKey,
                iconKey: iconKey,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> colorValue = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> stableKey = const Value.absent(),
                Value<String?> iconKey = const Value.absent(),
              }) => PaymentMethodsCompanion.insert(
                id: id,
                name: name,
                colorValue: colorValue,
                isDefault: isDefault,
                sortOrder: sortOrder,
                stableKey: stableKey,
                iconKey: iconKey,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentMethodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({operationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (operationsRefs) db.operations],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (operationsRefs)
                    await $_getPrefetchedData<
                      PaymentMethod,
                      $PaymentMethodsTable,
                      Operation
                    >(
                      currentTable: table,
                      referencedTable: $$PaymentMethodsTableReferences
                          ._operationsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PaymentMethodsTableReferences(
                            db,
                            table,
                            p0,
                          ).operationsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.paymentMethodId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PaymentMethodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentMethodsTable,
      PaymentMethod,
      $$PaymentMethodsTableFilterComposer,
      $$PaymentMethodsTableOrderingComposer,
      $$PaymentMethodsTableAnnotationComposer,
      $$PaymentMethodsTableCreateCompanionBuilder,
      $$PaymentMethodsTableUpdateCompanionBuilder,
      (PaymentMethod, $$PaymentMethodsTableReferences),
      PaymentMethod,
      PrefetchHooks Function({bool operationsRefs})
    >;
typedef $$OperationsTableCreateCompanionBuilder =
    OperationsCompanion Function({
      Value<int> id,
      Value<String> syncId,
      required String kind,
      required DateTime occurredAt,
      required int originalAmountMinor,
      required String originalCurrencyCode,
      required int storedAmountMinor,
      required String storedCurrencyCode,
      Value<double?> rateUsed,
      Value<DateTime?> rateTimestamp,
      Value<int?> paymentMethodId,
      Value<String?> countryCode,
      Value<String?> note,
      required DateTime createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> duplicateDismissed,
    });
typedef $$OperationsTableUpdateCompanionBuilder =
    OperationsCompanion Function({
      Value<int> id,
      Value<String> syncId,
      Value<String> kind,
      Value<DateTime> occurredAt,
      Value<int> originalAmountMinor,
      Value<String> originalCurrencyCode,
      Value<int> storedAmountMinor,
      Value<String> storedCurrencyCode,
      Value<double?> rateUsed,
      Value<DateTime?> rateTimestamp,
      Value<int?> paymentMethodId,
      Value<String?> countryCode,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> duplicateDismissed,
    });

final class $$OperationsTableReferences
    extends BaseReferences<_$AppDatabase, $OperationsTable, Operation> {
  $$OperationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PaymentMethodsTable _paymentMethodIdTable(_$AppDatabase db) => db
      .paymentMethods
      .createAlias('operations__payment_method_id__payment_methods__id');

  $$PaymentMethodsTableProcessedTableManager? get paymentMethodId {
    final $_column = $_itemColumn<int>('payment_method_id');
    if ($_column == null) return null;
    final manager = $$PaymentMethodsTableTableManager(
      $_db,
      $_db.paymentMethods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentMethodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$OperationTagsTable, List<OperationTag>>
  _operationTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.operationTags,
    aliasName: 'operations__id__operation_tags__operation_id',
  );

  $$OperationTagsTableProcessedTableManager get operationTagsRefs {
    final manager = $$OperationTagsTableTableManager(
      $_db,
      $_db.operationTags,
    ).filter((f) => f.operationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_operationTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OperationsTableFilterComposer
    extends Composer<_$AppDatabase, $OperationsTable> {
  $$OperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalAmountMinor => $composableBuilder(
    column: $table.originalAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalCurrencyCode => $composableBuilder(
    column: $table.originalCurrencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get storedAmountMinor => $composableBuilder(
    column: $table.storedAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storedCurrencyCode => $composableBuilder(
    column: $table.storedCurrencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rateUsed => $composableBuilder(
    column: $table.rateUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get rateTimestamp => $composableBuilder(
    column: $table.rateTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get duplicateDismissed => $composableBuilder(
    column: $table.duplicateDismissed,
    builder: (column) => ColumnFilters(column),
  );

  $$PaymentMethodsTableFilterComposer get paymentMethodId {
    final $$PaymentMethodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMethodId,
      referencedTable: $db.paymentMethods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentMethodsTableFilterComposer(
            $db: $db,
            $table: $db.paymentMethods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> operationTagsRefs(
    Expression<bool> Function($$OperationTagsTableFilterComposer f) f,
  ) {
    final $$OperationTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operationTags,
      getReferencedColumn: (t) => t.operationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationTagsTableFilterComposer(
            $db: $db,
            $table: $db.operationTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $OperationsTable> {
  $$OperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalAmountMinor => $composableBuilder(
    column: $table.originalAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalCurrencyCode => $composableBuilder(
    column: $table.originalCurrencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get storedAmountMinor => $composableBuilder(
    column: $table.storedAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storedCurrencyCode => $composableBuilder(
    column: $table.storedCurrencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rateUsed => $composableBuilder(
    column: $table.rateUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get rateTimestamp => $composableBuilder(
    column: $table.rateTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get duplicateDismissed => $composableBuilder(
    column: $table.duplicateDismissed,
    builder: (column) => ColumnOrderings(column),
  );

  $$PaymentMethodsTableOrderingComposer get paymentMethodId {
    final $$PaymentMethodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMethodId,
      referencedTable: $db.paymentMethods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentMethodsTableOrderingComposer(
            $db: $db,
            $table: $db.paymentMethods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OperationsTable> {
  $$OperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originalAmountMinor => $composableBuilder(
    column: $table.originalAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalCurrencyCode => $composableBuilder(
    column: $table.originalCurrencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get storedAmountMinor => $composableBuilder(
    column: $table.storedAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storedCurrencyCode => $composableBuilder(
    column: $table.storedCurrencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rateUsed =>
      $composableBuilder(column: $table.rateUsed, builder: (column) => column);

  GeneratedColumn<DateTime> get rateTimestamp => $composableBuilder(
    column: $table.rateTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get duplicateDismissed => $composableBuilder(
    column: $table.duplicateDismissed,
    builder: (column) => column,
  );

  $$PaymentMethodsTableAnnotationComposer get paymentMethodId {
    final $$PaymentMethodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMethodId,
      referencedTable: $db.paymentMethods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentMethodsTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentMethods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> operationTagsRefs<T extends Object>(
    Expression<T> Function($$OperationTagsTableAnnotationComposer a) f,
  ) {
    final $$OperationTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operationTags,
      getReferencedColumn: (t) => t.operationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.operationTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OperationsTable,
          Operation,
          $$OperationsTableFilterComposer,
          $$OperationsTableOrderingComposer,
          $$OperationsTableAnnotationComposer,
          $$OperationsTableCreateCompanionBuilder,
          $$OperationsTableUpdateCompanionBuilder,
          (Operation, $$OperationsTableReferences),
          Operation,
          PrefetchHooks Function({bool paymentMethodId, bool operationTagsRefs})
        > {
  $$OperationsTableTableManager(_$AppDatabase db, $OperationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OperationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int> originalAmountMinor = const Value.absent(),
                Value<String> originalCurrencyCode = const Value.absent(),
                Value<int> storedAmountMinor = const Value.absent(),
                Value<String> storedCurrencyCode = const Value.absent(),
                Value<double?> rateUsed = const Value.absent(),
                Value<DateTime?> rateTimestamp = const Value.absent(),
                Value<int?> paymentMethodId = const Value.absent(),
                Value<String?> countryCode = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> duplicateDismissed = const Value.absent(),
              }) => OperationsCompanion(
                id: id,
                syncId: syncId,
                kind: kind,
                occurredAt: occurredAt,
                originalAmountMinor: originalAmountMinor,
                originalCurrencyCode: originalCurrencyCode,
                storedAmountMinor: storedAmountMinor,
                storedCurrencyCode: storedCurrencyCode,
                rateUsed: rateUsed,
                rateTimestamp: rateTimestamp,
                paymentMethodId: paymentMethodId,
                countryCode: countryCode,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                duplicateDismissed: duplicateDismissed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                required String kind,
                required DateTime occurredAt,
                required int originalAmountMinor,
                required String originalCurrencyCode,
                required int storedAmountMinor,
                required String storedCurrencyCode,
                Value<double?> rateUsed = const Value.absent(),
                Value<DateTime?> rateTimestamp = const Value.absent(),
                Value<int?> paymentMethodId = const Value.absent(),
                Value<String?> countryCode = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> duplicateDismissed = const Value.absent(),
              }) => OperationsCompanion.insert(
                id: id,
                syncId: syncId,
                kind: kind,
                occurredAt: occurredAt,
                originalAmountMinor: originalAmountMinor,
                originalCurrencyCode: originalCurrencyCode,
                storedAmountMinor: storedAmountMinor,
                storedCurrencyCode: storedCurrencyCode,
                rateUsed: rateUsed,
                rateTimestamp: rateTimestamp,
                paymentMethodId: paymentMethodId,
                countryCode: countryCode,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                duplicateDismissed: duplicateDismissed,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OperationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({paymentMethodId = false, operationTagsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (operationTagsRefs) db.operationTags,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (paymentMethodId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.paymentMethodId,
                                    referencedTable: $$OperationsTableReferences
                                        ._paymentMethodIdTable(db),
                                    referencedColumn:
                                        $$OperationsTableReferences
                                            ._paymentMethodIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (operationTagsRefs)
                        await $_getPrefetchedData<
                          Operation,
                          $OperationsTable,
                          OperationTag
                        >(
                          currentTable: table,
                          referencedTable: $$OperationsTableReferences
                              ._operationTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OperationsTableReferences(
                                db,
                                table,
                                p0,
                              ).operationTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.operationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OperationsTable,
      Operation,
      $$OperationsTableFilterComposer,
      $$OperationsTableOrderingComposer,
      $$OperationsTableAnnotationComposer,
      $$OperationsTableCreateCompanionBuilder,
      $$OperationsTableUpdateCompanionBuilder,
      (Operation, $$OperationsTableReferences),
      Operation,
      PrefetchHooks Function({bool paymentMethodId, bool operationTagsRefs})
    >;
typedef $$OperationTagsTableCreateCompanionBuilder =
    OperationTagsCompanion Function({
      required int operationId,
      required int tagId,
      Value<int> rowid,
    });
typedef $$OperationTagsTableUpdateCompanionBuilder =
    OperationTagsCompanion Function({
      Value<int> operationId,
      Value<int> tagId,
      Value<int> rowid,
    });

final class $$OperationTagsTableReferences
    extends BaseReferences<_$AppDatabase, $OperationTagsTable, OperationTag> {
  $$OperationTagsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $OperationsTable _operationIdTable(_$AppDatabase db) =>
      db.operations.createAlias('operation_tags__operation_id__operations__id');

  $$OperationsTableProcessedTableManager get operationId {
    final $_column = $_itemColumn<int>('operation_id')!;

    final manager = $$OperationsTableTableManager(
      $_db,
      $_db.operations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_operationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('operation_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OperationTagsTableFilterComposer
    extends Composer<_$AppDatabase, $OperationTagsTable> {
  $$OperationTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$OperationsTableFilterComposer get operationId {
    final $$OperationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.operationId,
      referencedTable: $db.operations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableFilterComposer(
            $db: $db,
            $table: $db.operations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OperationTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $OperationTagsTable> {
  $$OperationTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$OperationsTableOrderingComposer get operationId {
    final $$OperationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.operationId,
      referencedTable: $db.operations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableOrderingComposer(
            $db: $db,
            $table: $db.operations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OperationTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OperationTagsTable> {
  $$OperationTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$OperationsTableAnnotationComposer get operationId {
    final $$OperationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.operationId,
      referencedTable: $db.operations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableAnnotationComposer(
            $db: $db,
            $table: $db.operations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OperationTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OperationTagsTable,
          OperationTag,
          $$OperationTagsTableFilterComposer,
          $$OperationTagsTableOrderingComposer,
          $$OperationTagsTableAnnotationComposer,
          $$OperationTagsTableCreateCompanionBuilder,
          $$OperationTagsTableUpdateCompanionBuilder,
          (OperationTag, $$OperationTagsTableReferences),
          OperationTag,
          PrefetchHooks Function({bool operationId, bool tagId})
        > {
  $$OperationTagsTableTableManager(_$AppDatabase db, $OperationTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OperationTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OperationTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OperationTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> operationId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperationTagsCompanion(
                operationId: operationId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int operationId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => OperationTagsCompanion.insert(
                operationId: operationId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OperationTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({operationId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (operationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.operationId,
                                referencedTable: $$OperationTagsTableReferences
                                    ._operationIdTable(db),
                                referencedColumn: $$OperationTagsTableReferences
                                    ._operationIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$OperationTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$OperationTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OperationTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OperationTagsTable,
      OperationTag,
      $$OperationTagsTableFilterComposer,
      $$OperationTagsTableOrderingComposer,
      $$OperationTagsTableAnnotationComposer,
      $$OperationTagsTableCreateCompanionBuilder,
      $$OperationTagsTableUpdateCompanionBuilder,
      (OperationTag, $$OperationTagsTableReferences),
      OperationTag,
      PrefetchHooks Function({bool operationId, bool tagId})
    >;
typedef $$ExchangeRatesTableCreateCompanionBuilder =
    ExchangeRatesCompanion Function({
      Value<int> id,
      required String baseCurrencyCode,
      required String targetCurrencyCode,
      required String source,
      required double rate,
      required DateTime fetchedAt,
    });
typedef $$ExchangeRatesTableUpdateCompanionBuilder =
    ExchangeRatesCompanion Function({
      Value<int> id,
      Value<String> baseCurrencyCode,
      Value<String> targetCurrencyCode,
      Value<String> source,
      Value<double> rate,
      Value<DateTime> fetchedAt,
    });

class $$ExchangeRatesTableFilterComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseCurrencyCode => $composableBuilder(
    column: $table.baseCurrencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetCurrencyCode => $composableBuilder(
    column: $table.targetCurrencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExchangeRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseCurrencyCode => $composableBuilder(
    column: $table.baseCurrencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetCurrencyCode => $composableBuilder(
    column: $table.targetCurrencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExchangeRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get baseCurrencyCode => $composableBuilder(
    column: $table.baseCurrencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetCurrencyCode => $composableBuilder(
    column: $table.targetCurrencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ExchangeRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExchangeRatesTable,
          ExchangeRate,
          $$ExchangeRatesTableFilterComposer,
          $$ExchangeRatesTableOrderingComposer,
          $$ExchangeRatesTableAnnotationComposer,
          $$ExchangeRatesTableCreateCompanionBuilder,
          $$ExchangeRatesTableUpdateCompanionBuilder,
          (
            ExchangeRate,
            BaseReferences<_$AppDatabase, $ExchangeRatesTable, ExchangeRate>,
          ),
          ExchangeRate,
          PrefetchHooks Function()
        > {
  $$ExchangeRatesTableTableManager(_$AppDatabase db, $ExchangeRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExchangeRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExchangeRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExchangeRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> baseCurrencyCode = const Value.absent(),
                Value<String> targetCurrencyCode = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<double> rate = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
              }) => ExchangeRatesCompanion(
                id: id,
                baseCurrencyCode: baseCurrencyCode,
                targetCurrencyCode: targetCurrencyCode,
                source: source,
                rate: rate,
                fetchedAt: fetchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String baseCurrencyCode,
                required String targetCurrencyCode,
                required String source,
                required double rate,
                required DateTime fetchedAt,
              }) => ExchangeRatesCompanion.insert(
                id: id,
                baseCurrencyCode: baseCurrencyCode,
                targetCurrencyCode: targetCurrencyCode,
                source: source,
                rate: rate,
                fetchedAt: fetchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExchangeRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExchangeRatesTable,
      ExchangeRate,
      $$ExchangeRatesTableFilterComposer,
      $$ExchangeRatesTableOrderingComposer,
      $$ExchangeRatesTableAnnotationComposer,
      $$ExchangeRatesTableCreateCompanionBuilder,
      $$ExchangeRatesTableUpdateCompanionBuilder,
      (
        ExchangeRate,
        BaseReferences<_$AppDatabase, $ExchangeRatesTable, ExchangeRate>,
      ),
      ExchangeRate,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$PaymentMethodsTableTableManager get paymentMethods =>
      $$PaymentMethodsTableTableManager(_db, _db.paymentMethods);
  $$OperationsTableTableManager get operations =>
      $$OperationsTableTableManager(_db, _db.operations);
  $$OperationTagsTableTableManager get operationTags =>
      $$OperationTagsTableTableManager(_db, _db.operationTags);
  $$ExchangeRatesTableTableManager get exchangeRates =>
      $$ExchangeRatesTableTableManager(_db, _db.exchangeRates);
}
