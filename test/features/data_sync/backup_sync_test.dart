import 'dart:convert';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/features/data_sync/model/backup_crypto.dart';
import 'package:valtero/features/data_sync/model/backup_format.dart';
import 'package:valtero/features/data_sync/model/backup_importer.dart';
import 'package:valtero/features/data_sync/model/backup_snapshot.dart';
import 'package:valtero/features/data_sync/model/passphrase_generator.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/schema_version.dart';
import 'package:valtero/shared/settings/app_settings.dart';

void main() {
  group('generatePassphrase', () {
    test('returns four words and a numeric suffix', () {
      final phrase = generatePassphrase(Random(1));
      final parts = phrase.split('-');
      expect(parts.length, 5);
      expect(int.tryParse(parts.last), isNot(null));
    });
  });

  group('BackupCrypto', () {
    test('round-trips clear bytes', () async {
      final crypto = BackupCrypto();
      const passphrase = 'orange-river-lamp-stone-42';
      final clear = utf8.encode('{"hello":"world"}');
      final enc = await crypto.encryptBytes(
        clearBytes: clear,
        passphrase: passphrase,
      );
      final dec = await crypto.decryptBytes(
        salt: enc.salt,
        nonce: enc.nonce,
        ciphertext: enc.ciphertext,
        passphrase: passphrase,
      );
      expect(utf8.decode(dec), '{"hello":"world"}');
    });

    test('wrong passphrase throws BackupWrongPassphraseException', () async {
      final crypto = BackupCrypto();
      final enc = await crypto.encryptBytes(
        clearBytes: utf8.encode('secret'),
        passphrase: 'correct-horse-battery-staple-1',
      );
      expect(
        () => crypto.decryptBytes(
          salt: enc.salt,
          nonce: enc.nonce,
          ciphertext: enc.ciphertext,
          passphrase: 'wrong-passphrase-here-99',
        ),
        throwsA(isA<BackupWrongPassphraseException>()),
      );
    });
  });

  group('BackupEnvelope', () {
    test('refuses newer schemaVersion', () {
      final envelope = BackupEnvelope(
        formatVersion: kBackupFormatVersion,
        schemaVersion: kAppSchemaVersion + 1,
        exportedAt: DateTime.utc(2026, 1, 1),
        appVersion: null,
        data: BackupPayloadData(
          tags: const [],
          paymentMethods: const [],
          expenses: const [],
          expenseTags: const [],
          exchangeRateOverrides: const [],
          settings: BackupSettingsData(
            reportingCurrencies: const ['USD'],
            primaryCurrency: 'USD',
            customCurrencyCodes: const [],
            themeMode: 'system',
            locale: 'system',
            moneyDisplayFormat: 'localeCode',
            dateDisplayFormat: 'isoYmd',
            timeZoneId: 'system',
            dismissedTagSuggestions: const [],
          ),
        ),
      );
      expect(
        () => envelope.validateForImport(),
        throwsA(isA<BackupNewerSchemaException>()),
      );
    });

    test('refuses unknown formatVersion', () {
      final envelope = BackupEnvelope(
        formatVersion: 99,
        schemaVersion: kAppSchemaVersion,
        exportedAt: DateTime.utc(2026, 1, 1),
        appVersion: null,
        data: BackupPayloadData(
          tags: const [],
          paymentMethods: const [],
          expenses: const [],
          expenseTags: const [],
          exchangeRateOverrides: const [],
          settings: BackupSettingsData(
            reportingCurrencies: const ['USD'],
            primaryCurrency: 'USD',
            customCurrencyCodes: const [],
            themeMode: 'system',
            locale: 'system',
            moneyDisplayFormat: 'localeCode',
            dateDisplayFormat: 'isoYmd',
            timeZoneId: 'system',
            dismissedTagSuggestions: const [],
          ),
        ),
      );
      expect(
        () => envelope.validateForImport(),
        throwsA(isA<BackupUnsupportedFormatException>()),
      );
    });
  });

  group('BackupImporter', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('merges tags by stableKey and always inserts expenses', () async {
      await db.ensureTagByStableKey(
        stableKey: 'groceries',
        fallbackName: 'Groceries',
      );
      await db.ensurePaymentMethodByStableKey(
        stableKey: 'cash',
        fallbackName: 'Cash',
      );

      final envelope = BackupEnvelope(
        formatVersion: kBackupFormatVersion,
        schemaVersion: kAppSchemaVersion,
        exportedAt: DateTime.utc(2026, 1, 1),
        appVersion: '1.0.0',
        data: BackupPayloadData(
          tags: const [
            BackupTagData(
              stableKey: 'groceries',
              name: 'Food',
              kind: 'normal',
              colorValue: null,
              isDefault: false,
              sortOrder: 0,
              countryCode: null,
            ),
            BackupTagData(
              stableKey: 'transport',
              name: 'Transport',
              kind: 'normal',
              colorValue: null,
              isDefault: false,
              sortOrder: 1,
              countryCode: null,
            ),
          ],
          paymentMethods: const [
            BackupPaymentMethodData(
              stableKey: 'cash',
              name: 'Cash',
              colorValue: null,
              isDefault: true,
              sortOrder: 0,
            ),
          ],
          expenses: [
            BackupExpenseData(
              clientId: 'e1',
              occurredAt: DateTime.utc(2026, 1, 2),
              originalAmountMinor: 1000,
              originalCurrencyCode: 'USD',
              storedAmountMinor: 1000,
              storedCurrencyCode: 'USD',
              rateUsed: null,
              rateTimestamp: null,
              paymentStableKey: 'cash',
              paymentName: 'Cash',
              countryCode: 'US',
              note: 'coffee',
              createdAt: DateTime.utc(2026, 1, 2),
            ),
          ],
          expenseTags: const [
            BackupExpenseTagData(
              expenseClientId: 'e1',
              tagStableKey: 'groceries',
              tagName: 'Food',
              tagKind: 'normal',
            ),
            BackupExpenseTagData(
              expenseClientId: 'e1',
              tagStableKey: 'transport',
              tagName: 'Transport',
              tagKind: 'normal',
            ),
          ],
          exchangeRateOverrides: const [],
          settings: BackupSettingsData(
            reportingCurrencies: const ['EUR'],
            primaryCurrency: 'EUR',
            customCurrencyCodes: const [],
            themeMode: 'dark',
            locale: 'en',
            moneyDisplayFormat: 'localeSymbol',
            dateDisplayFormat: 'dmy',
            timeZoneId: 'UTC',
            dismissedTagSuggestions: const [],
          ),
        ),
      );

      AppSettings? saved;
      final report = await BackupImporter().importEnvelope(
        db: db,
        envelope: envelope,
        currentSettings: AppSettings.initial(),
        applySettings: true,
        saveSettings: (s) async {
          saved = s;
        },
      );

      expect(report.expensesAdded, 1);
      expect(report.tagsAdded, 1);
      expect(report.paymentsAdded, 0);
      expect(report.settingsApplied, isTrue);
      expect(saved?.primaryCurrency, 'EUR');
      expect(saved?.themeMode, 'dark');

      final tags = await db.watchTagsList();
      expect(tags.length, 2);
      final expenses = await db.getAllExpenses();
      expect(expenses.length, 1);
      final tagIds = await db.getTagIdsForExpense(expenses.first.id);
      expect(tagIds.length, 2);
    });
  });

  group('BackupSnapshotBuilder', () {
    test('omits secrets from settings payload', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await db.insertExpense(
        ExpensesCompanion.insert(
          occurredAt: DateTime.utc(2026, 1, 1),
          originalAmountMinor: 500,
          originalCurrencyCode: 'USD',
          storedAmountMinor: 500,
          storedCurrencyCode: 'USD',
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      );

      final settings = AppSettings.initial().copyWith(
        exchangeRateApiKey: 'secret-key',
        telegramBotToken: 'bot-token',
        telegramChatId: 'chat-id',
      );
      final envelope = await BackupSnapshotBuilder().build(
        db: db,
        settings: settings,
        appVersion: '1.1.0',
      );
      final json = envelope.toJson();
      final encoded = jsonEncode(json);
      expect(encoded.contains('secret-key'), isFalse);
      expect(encoded.contains('bot-token'), isFalse);
      expect(encoded.contains('chat-id'), isFalse);
      expect(envelope.data.expenses, hasLength(1));
      expect(envelope.data.expenses.first.clientId, 'e1');
    });
  });
}
