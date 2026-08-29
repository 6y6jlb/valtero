import 'dart:convert';

import 'package:valtero/features/data_sync/model/backup_crypto.dart';
import 'package:valtero/shared/database/schema_version.dart';

/// Outer encrypted file + inner clear envelope format versions.
const int kBackupFormatVersion = 1;

const String kBackupFileExtension = 'valterobackup';
const String kBackupKdfArgon2id = 'argon2id';

/// Outer JSON wrapper written to `.valterobackup` files.
class BackupOuterFile {
  final int formatVersion;
  final String kdf;
  final String saltBase64;
  final String nonceBase64;
  final String ciphertextBase64;

  const BackupOuterFile({
    required this.formatVersion,
    required this.kdf,
    required this.saltBase64,
    required this.nonceBase64,
    required this.ciphertextBase64,
  });

  factory BackupOuterFile.fromEncrypted(EncryptedBackupBytes encrypted) {
    return BackupOuterFile(
      formatVersion: kBackupFormatVersion,
      kdf: kBackupKdfArgon2id,
      saltBase64: encodeBase64(encrypted.salt),
      nonceBase64: encodeBase64(encrypted.nonce),
      ciphertextBase64: encodeBase64(encrypted.ciphertext),
    );
  }

  Map<String, dynamic> toJson() => {
        'formatVersion': formatVersion,
        'kdf': kdf,
        'salt': saltBase64,
        'nonce': nonceBase64,
        'ciphertext': ciphertextBase64,
      };

  factory BackupOuterFile.fromJson(Map<String, dynamic> json) {
    return BackupOuterFile(
      formatVersion: (json['formatVersion'] as num?)?.toInt() ?? -1,
      kdf: json['kdf'] as String? ?? '',
      saltBase64: json['salt'] as String? ?? '',
      nonceBase64: json['nonce'] as String? ?? '',
      ciphertextBase64: json['ciphertext'] as String? ?? '',
    );
  }

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  static BackupOuterFile parse(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const BackupUnsupportedFormatException();
    }
    return BackupOuterFile.fromJson(Map<String, dynamic>.from(decoded));
  }
}

/// Settings subset included in backups (no secrets / integration tokens).
class BackupSettingsData {
  final List<String> reportingCurrencies;
  final String primaryCurrency;
  final List<String> customCurrencyCodes;
  final String themeMode;
  final String locale;
  final String moneyDisplayFormat;
  final String dateDisplayFormat;
  final String timeZoneId;
  final List<String> dismissedTagSuggestions;

  const BackupSettingsData({
    required this.reportingCurrencies,
    required this.primaryCurrency,
    required this.customCurrencyCodes,
    required this.themeMode,
    required this.locale,
    required this.moneyDisplayFormat,
    required this.dateDisplayFormat,
    required this.timeZoneId,
    required this.dismissedTagSuggestions,
  });

  Map<String, dynamic> toJson() => {
        'reportingCurrencies': reportingCurrencies,
        'primaryCurrency': primaryCurrency,
        'customCurrencyCodes': customCurrencyCodes,
        'themeMode': themeMode,
        'locale': locale,
        'moneyDisplayFormat': moneyDisplayFormat,
        'dateDisplayFormat': dateDisplayFormat,
        'timeZoneId': timeZoneId,
        'dismissedTagSuggestions': dismissedTagSuggestions,
      };

  factory BackupSettingsData.fromJson(Map<String, dynamic> json) {
    return BackupSettingsData(
      reportingCurrencies: _stringList(json['reportingCurrencies']),
      primaryCurrency: json['primaryCurrency'] as String? ?? 'RUB',
      customCurrencyCodes: _stringList(json['customCurrencyCodes']),
      themeMode: json['themeMode'] as String? ?? 'system',
      locale: json['locale'] as String? ?? 'system',
      moneyDisplayFormat: json['moneyDisplayFormat'] as String? ?? 'localeCode',
      dateDisplayFormat: json['dateDisplayFormat'] as String? ?? 'isoYmd',
      timeZoneId: json['timeZoneId'] as String? ?? 'system',
      dismissedTagSuggestions: _stringList(json['dismissedTagSuggestions']),
    );
  }
}

class BackupTagData {
  final String? stableKey;
  final String name;
  final String kind;
  final int? colorValue;
  final bool isDefault;
  final int sortOrder;
  final String? countryCode;

  const BackupTagData({
    required this.stableKey,
    required this.name,
    required this.kind,
    required this.colorValue,
    required this.isDefault,
    required this.sortOrder,
    required this.countryCode,
  });

  Map<String, dynamic> toJson() => {
        'stableKey': stableKey,
        'name': name,
        'kind': kind,
        'colorValue': colorValue,
        'isDefault': isDefault,
        'sortOrder': sortOrder,
        'countryCode': countryCode,
      };

  factory BackupTagData.fromJson(Map<String, dynamic> json) {
    return BackupTagData(
      stableKey: json['stableKey'] as String?,
      name: json['name'] as String? ?? '',
      kind: json['kind'] as String? ?? 'normal',
      colorValue: (json['colorValue'] as num?)?.toInt(),
      isDefault: json['isDefault'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      countryCode: json['countryCode'] as String?,
    );
  }
}

class BackupPaymentMethodData {
  final String? stableKey;
  final String name;
  final int? colorValue;
  final bool isDefault;
  final int sortOrder;

  const BackupPaymentMethodData({
    required this.stableKey,
    required this.name,
    required this.colorValue,
    required this.isDefault,
    required this.sortOrder,
  });

  Map<String, dynamic> toJson() => {
        'stableKey': stableKey,
        'name': name,
        'colorValue': colorValue,
        'isDefault': isDefault,
        'sortOrder': sortOrder,
      };

  factory BackupPaymentMethodData.fromJson(Map<String, dynamic> json) {
    return BackupPaymentMethodData(
      stableKey: json['stableKey'] as String?,
      name: json['name'] as String? ?? '',
      colorValue: (json['colorValue'] as num?)?.toInt(),
      isDefault: json['isDefault'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}

class BackupExpenseData {
  /// Export-local id referenced by [BackupExpenseTagData.expenseClientId].
  final String clientId;
  final DateTime occurredAt;
  final int originalAmountMinor;
  final String originalCurrencyCode;
  final int storedAmountMinor;
  final String storedCurrencyCode;
  final double? rateUsed;
  final DateTime? rateTimestamp;
  final String? paymentStableKey;
  final String? paymentName;
  final String? countryCode;
  final String? note;
  final DateTime createdAt;

  const BackupExpenseData({
    required this.clientId,
    required this.occurredAt,
    required this.originalAmountMinor,
    required this.originalCurrencyCode,
    required this.storedAmountMinor,
    required this.storedCurrencyCode,
    required this.rateUsed,
    required this.rateTimestamp,
    required this.paymentStableKey,
    required this.paymentName,
    required this.countryCode,
    required this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'clientId': clientId,
        'occurredAt': occurredAt.toIso8601String(),
        'originalAmountMinor': originalAmountMinor,
        'originalCurrencyCode': originalCurrencyCode,
        'storedAmountMinor': storedAmountMinor,
        'storedCurrencyCode': storedCurrencyCode,
        'rateUsed': rateUsed,
        'rateTimestamp': rateTimestamp?.toIso8601String(),
        'paymentStableKey': paymentStableKey,
        'paymentName': paymentName,
        'countryCode': countryCode,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory BackupExpenseData.fromJson(Map<String, dynamic> json) {
    final occurredAt = DateTime.tryParse(json['occurredAt'] as String? ?? '');
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '');
    if (occurredAt == null || createdAt == null) {
      throw const BackupUnsupportedFormatException();
    }
    return BackupExpenseData(
      clientId: json['clientId'] as String? ?? '',
      occurredAt: occurredAt,
      originalAmountMinor: (json['originalAmountMinor'] as num?)?.toInt() ?? 0,
      originalCurrencyCode: json['originalCurrencyCode'] as String? ?? 'XXX',
      storedAmountMinor: (json['storedAmountMinor'] as num?)?.toInt() ?? 0,
      storedCurrencyCode: json['storedCurrencyCode'] as String? ?? 'XXX',
      rateUsed: (json['rateUsed'] as num?)?.toDouble(),
      rateTimestamp: json['rateTimestamp'] != null
          ? DateTime.tryParse(json['rateTimestamp'] as String)
          : null,
      paymentStableKey: json['paymentStableKey'] as String?,
      paymentName: json['paymentName'] as String?,
      countryCode: json['countryCode'] as String?,
      note: json['note'] as String?,
      createdAt: createdAt,
    );
  }
}

class BackupExpenseTagData {
  final String expenseClientId;
  final String? tagStableKey;
  final String? tagName;
  final String? tagKind;

  const BackupExpenseTagData({
    required this.expenseClientId,
    required this.tagStableKey,
    required this.tagName,
    required this.tagKind,
  });

  Map<String, dynamic> toJson() => {
        'expenseClientId': expenseClientId,
        'tagStableKey': tagStableKey,
        'tagName': tagName,
        'tagKind': tagKind,
      };

  factory BackupExpenseTagData.fromJson(Map<String, dynamic> json) {
    return BackupExpenseTagData(
      expenseClientId: json['expenseClientId'] as String? ?? '',
      tagStableKey: json['tagStableKey'] as String?,
      tagName: json['tagName'] as String?,
      tagKind: json['tagKind'] as String?,
    );
  }
}

class BackupExchangeRateOverrideData {
  final String baseCurrencyCode;
  final String targetCurrencyCode;
  final double rate;
  final DateTime fetchedAt;

  const BackupExchangeRateOverrideData({
    required this.baseCurrencyCode,
    required this.targetCurrencyCode,
    required this.rate,
    required this.fetchedAt,
  });

  Map<String, dynamic> toJson() => {
        'baseCurrencyCode': baseCurrencyCode,
        'targetCurrencyCode': targetCurrencyCode,
        'rate': rate,
        'fetchedAt': fetchedAt.toIso8601String(),
        'source': 'manual',
      };

  factory BackupExchangeRateOverrideData.fromJson(Map<String, dynamic> json) {
    final fetchedAt = DateTime.tryParse(json['fetchedAt'] as String? ?? '');
    if (fetchedAt == null) {
      throw const BackupUnsupportedFormatException();
    }
    return BackupExchangeRateOverrideData(
      baseCurrencyCode: json['baseCurrencyCode'] as String? ?? '',
      targetCurrencyCode: json['targetCurrencyCode'] as String? ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 0,
      fetchedAt: fetchedAt,
    );
  }
}

class BackupPayloadData {
  final List<BackupTagData> tags;
  final List<BackupPaymentMethodData> paymentMethods;
  final List<BackupExpenseData> expenses;
  final List<BackupExpenseTagData> expenseTags;
  final List<BackupExchangeRateOverrideData> exchangeRateOverrides;
  final BackupSettingsData settings;

  const BackupPayloadData({
    required this.tags,
    required this.paymentMethods,
    required this.expenses,
    required this.expenseTags,
    required this.exchangeRateOverrides,
    required this.settings,
  });

  Map<String, dynamic> toJson() => {
        'tags': tags.map((e) => e.toJson()).toList(),
        'paymentMethods': paymentMethods.map((e) => e.toJson()).toList(),
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'expenseTags': expenseTags.map((e) => e.toJson()).toList(),
        'exchangeRateOverrides':
            exchangeRateOverrides.map((e) => e.toJson()).toList(),
        'settings': settings.toJson(),
      };

  factory BackupPayloadData.fromJson(Map<String, dynamic> json) {
    final settingsRaw = json['settings'];
    if (settingsRaw is! Map) {
      throw const BackupUnsupportedFormatException();
    }
    return BackupPayloadData(
      tags: _mapList(json['tags'], BackupTagData.fromJson),
      paymentMethods:
          _mapList(json['paymentMethods'], BackupPaymentMethodData.fromJson),
      expenses: _mapList(json['expenses'], BackupExpenseData.fromJson),
      expenseTags:
          _mapList(json['expenseTags'], BackupExpenseTagData.fromJson),
      exchangeRateOverrides: _mapList(
        json['exchangeRateOverrides'],
        BackupExchangeRateOverrideData.fromJson,
      ),
      settings: BackupSettingsData.fromJson(
        Map<String, dynamic>.from(settingsRaw),
      ),
    );
  }
}

/// Inner clear JSON envelope (before encryption).
class BackupEnvelope {
  final int formatVersion;
  final int schemaVersion;
  final DateTime exportedAt;
  final String? appVersion;
  final BackupPayloadData data;

  const BackupEnvelope({
    required this.formatVersion,
    required this.schemaVersion,
    required this.exportedAt,
    required this.appVersion,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
        'formatVersion': formatVersion,
        'schemaVersion': schemaVersion,
        'exportedAt': exportedAt.toIso8601String(),
        if (appVersion != null) 'appVersion': appVersion,
        'data': data.toJson(),
      };

  factory BackupEnvelope.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    if (dataRaw is! Map) {
      throw const BackupUnsupportedFormatException();
    }
    final exportedAt = DateTime.tryParse(json['exportedAt'] as String? ?? '');
    if (exportedAt == null) {
      throw const BackupUnsupportedFormatException();
    }
    return BackupEnvelope(
      formatVersion: (json['formatVersion'] as num?)?.toInt() ?? -1,
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? -1,
      exportedAt: exportedAt,
      appVersion: json['appVersion'] as String?,
      data: BackupPayloadData.fromJson(Map<String, dynamic>.from(dataRaw)),
    );
  }

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  static BackupEnvelope parse(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const BackupUnsupportedFormatException();
    }
    return BackupEnvelope.fromJson(Map<String, dynamic>.from(decoded));
  }

  /// Refuses unknown/newer outer or inner formatVersion, and future schemas.
  void validateForImport({int localSchemaVersion = kAppSchemaVersion}) {
    if (formatVersion != kBackupFormatVersion || formatVersion < 1) {
      throw const BackupUnsupportedFormatException();
    }
    if (schemaVersion < 1) {
      throw const BackupUnsupportedFormatException();
    }
    if (schemaVersion > localSchemaVersion) {
      throw BackupNewerSchemaException(schemaVersion);
    }
  }
}

void validateOuterForImport(BackupOuterFile outer) {
  if (outer.formatVersion != kBackupFormatVersion ||
      outer.formatVersion < 1 ||
      outer.kdf != kBackupKdfArgon2id ||
      outer.saltBase64.isEmpty ||
      outer.nonceBase64.isEmpty ||
      outer.ciphertextBase64.isEmpty) {
    throw const BackupUnsupportedFormatException();
  }
}

class BackupUnsupportedFormatException implements Exception {
  const BackupUnsupportedFormatException();

  @override
  String toString() => 'BackupUnsupportedFormatException';
}

class BackupNewerSchemaException implements Exception {
  final int schemaVersion;
  const BackupNewerSchemaException(this.schemaVersion);

  @override
  String toString() => 'BackupNewerSchemaException($schemaVersion)';
}

List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  return value.map((e) => e.toString()).toList();
}

List<T> _mapList<T>(
  dynamic value,
  T Function(Map<String, dynamic> json) map,
) {
  if (value is! List) return const [];
  return value.map((e) {
    if (e is! Map) throw const BackupUnsupportedFormatException();
    return map(Map<String, dynamic>.from(e));
  }).toList();
}
