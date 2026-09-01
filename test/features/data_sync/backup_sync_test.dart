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
    test('refuses newer schemaVersion and keeps remote appVersion', () {
      final envelope = BackupEnvelope(
        formatVersion: kBackupFormatVersion,
        schemaVersion: kAppSchemaVersion + 1,
        exportedAt: DateTime.utc(2026, 1, 1),
        appVersion: '9.9.9',
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
        throwsA(
          isA<BackupNewerSchemaException>()
              .having((e) => e.schemaVersion, 'schema', kAppSchemaVersion + 1)
              .having((e) => e.appVersion, 'app', '9.9.9')
              .having(
                (e) => e.localSchemaVersion,
                'local',
                kAppSchemaVersion,
              ),
        ),
      );
    });

    test('accepts older schemaVersion for forward-compatible merge', () {
      final envelope = BackupEnvelope(
        formatVersion: kBackupFormatVersion,
        schemaVersion: kAppSchemaVersion - 1,
        exportedAt: DateTime.utc(2026, 1, 1),
        appVersion: '1.0.0',
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
      expect(() => envelope.validateForImport(), returnsNormally);
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

    test('skipClientIds skips insert; forceUnique sets duplicateDismissed',
        () async {
      final occurred = DateTime.utc(2026, 2, 1);
      final envelope = BackupEnvelope(
        formatVersion: kBackupFormatVersion,
        schemaVersion: kAppSchemaVersion,
        exportedAt: DateTime.utc(2026, 2, 1),
        appVersion: '1.0.0',
        data: BackupPayloadData(
          tags: const [],
          paymentMethods: const [],
          expenses: [
            BackupExpenseData(
              clientId: 'skip-me',
              occurredAt: occurred,
              originalAmountMinor: 100,
              originalCurrencyCode: 'USD',
              storedAmountMinor: 100,
              storedCurrencyCode: 'USD',
              rateUsed: null,
              rateTimestamp: null,
              paymentStableKey: null,
              paymentName: null,
              countryCode: null,
              note: null,
              createdAt: occurred,
            ),
            BackupExpenseData(
              clientId: 'unique-me',
              occurredAt: occurred,
              originalAmountMinor: 200,
              originalCurrencyCode: 'USD',
              storedAmountMinor: 200,
              storedCurrencyCode: 'USD',
              rateUsed: null,
              rateTimestamp: null,
              paymentStableKey: null,
              paymentName: null,
              countryCode: null,
              note: null,
              createdAt: occurred,
            ),
            BackupExpenseData(
              clientId: 'normal-me',
              occurredAt: occurred,
              originalAmountMinor: 300,
              originalCurrencyCode: 'USD',
              storedAmountMinor: 300,
              storedCurrencyCode: 'USD',
              rateUsed: null,
              rateTimestamp: null,
              paymentStableKey: null,
              paymentName: null,
              countryCode: null,
              note: null,
              createdAt: occurred,
            ),
          ],
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

      final report = await BackupImporter().importEnvelope(
        db: db,
        envelope: envelope,
        currentSettings: AppSettings.initial(),
        saveSettings: (_) async {},
        skipClientIds: {'skip-me'},
        forceUniqueClientIds: {'unique-me'},
      );

      expect(report.expensesAdded, 2);
      expect(report.expensesSkippedDuplicate, 1);
      final expenses = await db.getAllExpenses();
      expect(expenses, hasLength(2));
      final byAmount = {
        for (final e in expenses) e.originalAmountMinor: e,
      };
      expect(byAmount[200]!.duplicateDismissed, isTrue);
      expect(byAmount[300]!.duplicateDismissed, isFalse);
      expect(byAmount.containsKey(100), isFalse);
    });

    test('rates merge LWW by fetchedAt and max lastRateRefreshAt', () async {
      final older = DateTime.utc(2026, 3, 1, 10);
      final newer = DateTime.utc(2026, 3, 1, 12);
      final localRefresh = DateTime.utc(2026, 3, 1, 11);
      final remoteRefresh = DateTime.utc(2026, 3, 1, 13);

      await db.upsertRate(
        base: 'USD',
        target: 'EUR',
        source: 'frankfurter',
        rate: 0.9,
        fetchedAt: newer,
      );
      await db.upsertRate(
        base: 'USD',
        target: 'GBP',
        source: 'frankfurter',
        rate: 0.7,
        fetchedAt: older,
      );

      final envelope = BackupEnvelope(
        formatVersion: kBackupFormatVersion,
        schemaVersion: kAppSchemaVersion,
        exportedAt: DateTime.utc(2026, 3, 1),
        appVersion: '1.0.0',
        data: BackupPayloadData(
          tags: const [],
          paymentMethods: const [],
          expenses: const [],
          expenseTags: const [],
          exchangeRateOverrides: [
            BackupExchangeRateOverrideData(
              baseCurrencyCode: 'USD',
              targetCurrencyCode: 'EUR',
              rate: 0.8,
              fetchedAt: older,
              source: 'frankfurter',
            ),
            BackupExchangeRateOverrideData(
              baseCurrencyCode: 'USD',
              targetCurrencyCode: 'GBP',
              rate: 0.75,
              fetchedAt: newer,
              source: 'frankfurter',
            ),
            BackupExchangeRateOverrideData(
              baseCurrencyCode: 'USD',
              targetCurrencyCode: 'JPY',
              rate: 150,
              fetchedAt: newer,
              source: 'frankfurter',
            ),
          ],
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
            lastRateRefreshAt: remoteRefresh,
          ),
        ),
      );

      AppSettings? saved;
      await BackupImporter().importEnvelope(
        db: db,
        envelope: envelope,
        currentSettings:
            AppSettings.initial().copyWith(lastRateRefreshAt: localRefresh),
        applySettings: false,
        saveSettings: (s) async {
          saved = s;
        },
      );

      final eur = await db.getRateRow(
        base: 'USD',
        target: 'EUR',
        source: 'frankfurter',
      );
      expect(eur?.rate, 0.9);
      expect(eur!.fetchedAt.isAtSameMomentAs(newer), isTrue);

      final gbp = await db.getRateRow(
        base: 'USD',
        target: 'GBP',
        source: 'frankfurter',
      );
      expect(gbp?.rate, 0.75);
      expect(gbp!.fetchedAt.isAtSameMomentAs(newer), isTrue);

      final jpy = await db.getRateRow(
        base: 'USD',
        target: 'JPY',
        source: 'frankfurter',
      );
      expect(jpy?.rate, 150);

      expect(saved!.lastRateRefreshAt!.isAtSameMomentAs(remoteRefresh), isTrue);
    });

    test('snapshot exports provider rates and lastRateRefreshAt', () async {
      final at = DateTime.utc(2026, 3, 2, 8);
      await db.upsertRate(
        base: 'EUR',
        target: 'USD',
        source: 'frankfurter',
        rate: 1.1,
        fetchedAt: at,
      );
      final envelope = await BackupSnapshotBuilder().build(
        db: db,
        settings: AppSettings.initial().copyWith(lastRateRefreshAt: at),
      );
      expect(envelope.data.exchangeRateOverrides, hasLength(1));
      expect(envelope.data.exchangeRateOverrides.first.source, 'frankfurter');
      expect(envelope.data.settings.lastRateRefreshAt, at);
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
        googleDriveRefreshToken: 'gdrive-refresh',
        googleDriveSyncPassphrase: 'gdrive-pass',
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
      expect(encoded.contains('gdrive-refresh'), isFalse);
      expect(encoded.contains('gdrive-pass'), isFalse);
      expect(envelope.data.expenses, hasLength(1));
      expect(envelope.data.expenses.first.clientId, 'e1');
    });

    test('includes Google Drive shared-sync metadata without secrets', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final settings = AppSettings.initial().copyWith(
        googleDriveSharedWithEmails: const ['collab@example.com'],
        googleDriveSharedFileId: 'shared-file-123',
        googleDriveRefreshToken: 'gdrive-refresh',
      );
      final envelope = await BackupSnapshotBuilder().build(
        db: db,
        settings: settings,
      );

      expect(
        envelope.data.settings.googleDriveSharedWithEmails,
        ['collab@example.com'],
      );
      expect(envelope.data.settings.googleDriveSharedFileId, 'shared-file-123');

      final encoded = jsonEncode(envelope.toJson());
      expect(encoded.contains('collab@example.com'), isTrue);
      expect(encoded.contains('shared-file-123'), isTrue);
      expect(encoded.contains('gdrive-refresh'), isFalse);
    });
  });
}
