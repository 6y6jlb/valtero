import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/features/data_sync/model/backup_crypto.dart';
import 'package:valtero/features/data_sync/model/backup_format.dart';
import 'package:valtero/features/data_sync/model/backup_importer.dart';
import 'package:valtero/features/data_sync/model/backup_snapshot.dart';
import 'package:valtero/features/data_sync/model/data_sync_controller.dart';
import 'package:valtero/features/data_sync/model/passphrase_generator.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/database/database_provider.dart';
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

    test('imports incomes with tags and reports counts', () async {
      await db.ensureTagByStableKey(
        stableKey: 'salary',
        fallbackName: 'Salary',
        kind: 'income',
      );

      final envelope = BackupEnvelope(
        formatVersion: kBackupFormatVersion,
        schemaVersion: kAppSchemaVersion,
        exportedAt: DateTime.utc(2026, 4, 1),
        appVersion: '1.0.0',
        data: BackupPayloadData(
          tags: const [],
          paymentMethods: const [],
          expenses: const [],
          expenseTags: const [],
          incomes: [
            BackupIncomeData(
              clientId: 'i1',
              occurredAt: DateTime.utc(2026, 4, 2),
              originalAmountMinor: 500000,
              originalCurrencyCode: 'USD',
              storedAmountMinor: 500000,
              storedCurrencyCode: 'USD',
              rateUsed: null,
              rateTimestamp: null,
              paymentStableKey: null,
              paymentName: null,
              countryCode: 'US',
              note: 'paycheck',
              createdAt: DateTime.utc(2026, 4, 2),
            ),
          ],
          incomeTags: const [
            BackupIncomeTagData(
              incomeClientId: 'i1',
              tagStableKey: 'salary',
              tagName: 'Salary',
              tagKind: 'income',
            ),
          ],
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
      );

      expect(report.incomesAdded, 1);
      expect(report.incomesSkippedDuplicate, 0);
      final incomes = await db.getAllIncome();
      expect(incomes, hasLength(1));
      final tagIds = await db.getTagIdsForIncome(incomes.first.id);
      expect(tagIds, hasLength(1));
    });

    test(
      'skipClientIds/forceUniqueClientIds apply independently to income ids',
      () async {
        final occurred = DateTime.utc(2026, 4, 10);
        final envelope = BackupEnvelope(
          formatVersion: kBackupFormatVersion,
          schemaVersion: kAppSchemaVersion,
          exportedAt: occurred,
          appVersion: '1.0.0',
          data: BackupPayloadData(
            tags: const [],
            paymentMethods: const [],
            expenses: const [],
            expenseTags: const [],
            incomes: [
              BackupIncomeData(
                clientId: 'i-skip',
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
              BackupIncomeData(
                clientId: 'i-unique',
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
            ],
            incomeTags: const [],
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
          skipClientIds: {'i-skip'},
          forceUniqueClientIds: {'i-unique'},
        );

        expect(report.incomesAdded, 1);
        expect(report.incomesSkippedDuplicate, 1);
        final incomes = await db.getAllIncome();
        expect(incomes, hasLength(1));
        expect(incomes.first.duplicateDismissed, isTrue);
      },
    );

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
        OperationsCompanion.insert(
        kind: 'expense',
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

    test('exports incomes with i-prefixed clientId, tags, and iconKey',
        () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final tagId = await db.insertTag(
        TagsCompanion.insert(
          name: 'Salary',
          kind: const Value('income'),
          stableKey: const Value('salary'),
          iconKey: const Value('salary'),
        ),
      );
      final incomeId = await db.insertIncome(
        OperationsCompanion.insert(
        kind: 'income',
          occurredAt: DateTime.utc(2026, 5, 1),
          originalAmountMinor: 400000,
          originalCurrencyCode: 'USD',
          storedAmountMinor: 400000,
          storedCurrencyCode: 'USD',
          createdAt: DateTime.utc(2026, 5, 1),
        ),
      );
      await db.setIncomeTags(incomeId, [tagId]);

      final envelope = await BackupSnapshotBuilder().build(
        db: db,
        settings: AppSettings.initial(),
      );

      expect(envelope.data.incomes, hasLength(1));
      expect(envelope.data.incomes.first.clientId, 'i$incomeId');
      expect(envelope.data.incomeTags, hasLength(1));
      expect(envelope.data.incomeTags.first.incomeClientId, 'i$incomeId');
      expect(envelope.data.incomeTags.first.tagStableKey, 'salary');
      final salaryTag =
          envelope.data.tags.firstWhere((t) => t.stableKey == 'salary');
      expect(salaryTag.iconKey, 'salary');
    });

    test('round-trips subcategory hierarchy on tags and expenseTag links',
        () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final healthId = await db.ensureTagByStableKey(
        stableKey: 'health',
        fallbackName: 'Health',
        kind: 'normal',
      );
      final doctorId = await db.ensureTagByStableKey(
        stableKey: 'doctor',
        fallbackName: 'Doctor',
        kind: 'normal',
        parentTagId: healthId,
      );
      final customParentId = await db.insertTag(
        TagsCompanion.insert(
          name: 'Projects',
          kind: const Value('normal'),
        ),
      );
      final customChildId = await db.insertTag(
        TagsCompanion.insert(
          name: 'Alpha',
          kind: const Value('normal'),
          parentTagId: Value(customParentId),
        ),
      );

      final expenseId = await db.insertExpense(
        OperationsCompanion.insert(
          kind: 'expense',
          occurredAt: DateTime.utc(2026, 6, 1),
          originalAmountMinor: 2500,
          originalCurrencyCode: 'RUB',
          storedAmountMinor: 2500,
          storedCurrencyCode: 'RUB',
          createdAt: DateTime.utc(2026, 6, 1),
        ),
      );
      await db.setExpenseTags(
        expenseId,
        [healthId, doctorId, customParentId, customChildId],
      );

      final envelope = await BackupSnapshotBuilder().build(
        db: db,
        settings: AppSettings.initial(),
      );

      final doctorTag =
          envelope.data.tags.firstWhere((t) => t.stableKey == 'doctor');
      expect(doctorTag.parentStableKey, 'health');
      final alphaTag =
          envelope.data.tags.firstWhere((t) => t.name == 'Alpha');
      expect(alphaTag.parentName, 'Projects');
      expect(alphaTag.parentKind, 'normal');
      expect(alphaTag.parentStableKey, equals(null));

      final doctorLink = envelope.data.expenseTags
          .firstWhere((l) => l.tagStableKey == 'doctor');
      expect(doctorLink.parentStableKey, 'health');
      final alphaLink =
          envelope.data.expenseTags.firstWhere((l) => l.tagName == 'Alpha');
      expect(alphaLink.parentName, 'Projects');
      expect(alphaLink.parentKind, 'normal');

      final importDb = AppDatabase(NativeDatabase.memory());
      addTearDown(importDb.close);
      final report = await BackupImporter().importEnvelope(
        db: importDb,
        envelope: envelope,
        currentSettings: AppSettings.initial(),
        saveSettings: (_) async {},
      );
      expect(report.expensesAdded, 1);

      final importedTags = await importDb.watchTagsList();
      final importedHealth =
          importedTags.firstWhere((t) => t.stableKey == 'health');
      final importedDoctor =
          importedTags.firstWhere((t) => t.stableKey == 'doctor');
      expect(importedDoctor.parentTagId, importedHealth.id);
      final importedProjects =
          importedTags.firstWhere((t) => t.name == 'Projects');
      final importedAlpha =
          importedTags.firstWhere((t) => t.name == 'Alpha');
      expect(importedAlpha.parentTagId, importedProjects.id);

      final importedExpenses = await importDb.getAllExpenses();
      expect(importedExpenses, hasLength(1));
      final linked =
          await importDb.getTagIdsForExpense(importedExpenses.first.id);
      expect(
        linked.toSet(),
        {
          importedHealth.id,
          importedDoctor.id,
          importedProjects.id,
          importedAlpha.id,
        },
      );
    });
  });

  group('BackupPayloadData backward compatibility', () {
    test('fromJson defaults incomes/incomeTags to empty when keys missing',
        () {
      final legacyJson = {
        'tags': <dynamic>[],
        'paymentMethods': <dynamic>[],
        'expenses': <dynamic>[],
        'expenseTags': <dynamic>[],
        'exchangeRateOverrides': <dynamic>[],
        'settings': {
          'reportingCurrencies': ['USD'],
          'primaryCurrency': 'USD',
          'customCurrencyCodes': <dynamic>[],
          'themeMode': 'system',
          'locale': 'system',
          'moneyDisplayFormat': 'localeCode',
          'dateDisplayFormat': 'isoYmd',
          'timeZoneId': 'system',
          'dismissedTagSuggestions': <dynamic>[],
        },
      };

      final data = BackupPayloadData.fromJson(legacyJson);

      expect(data.incomes, isEmpty);
      expect(data.incomeTags, isEmpty);
    });
  });

  group('DataSyncController conflict detection', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('finds both expense and income duplicates', () async {
      final occurred = DateTime.utc(2026, 6, 1);
      await db.insertExpense(
        OperationsCompanion.insert(
        kind: 'expense',
          occurredAt: occurred,
          originalAmountMinor: 1000,
          originalCurrencyCode: 'USD',
          storedAmountMinor: 1000,
          storedCurrencyCode: 'USD',
          createdAt: occurred,
        ),
      );
      await db.insertIncome(
        OperationsCompanion.insert(
        kind: 'income',
          occurredAt: occurred,
          originalAmountMinor: 5000,
          originalCurrencyCode: 'USD',
          storedAmountMinor: 5000,
          storedCurrencyCode: 'USD',
          createdAt: occurred,
        ),
      );

      final envelope = BackupEnvelope(
        formatVersion: kBackupFormatVersion,
        schemaVersion: kAppSchemaVersion,
        exportedAt: occurred,
        appVersion: '1.0.0',
        data: BackupPayloadData(
          tags: const [],
          paymentMethods: const [],
          expenses: [
            BackupExpenseData(
              clientId: 'e1',
              occurredAt: occurred,
              originalAmountMinor: 1000,
              originalCurrencyCode: 'USD',
              storedAmountMinor: 1000,
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
          incomes: [
            BackupIncomeData(
              clientId: 'i1',
              occurredAt: occurred,
              originalAmountMinor: 5000,
              originalCurrencyCode: 'USD',
              storedAmountMinor: 5000,
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
          incomeTags: const [],
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

      final controller = container.read(dataSyncControllerProvider);
      final conflicts = await controller.findDuplicateConflicts(envelope);

      expect(conflicts, hasLength(2));
      final expenseConflict =
          conflicts.firstWhere((c) => !c.isIncome);
      final incomeConflict = conflicts.firstWhere((c) => c.isIncome);
      expect(expenseConflict.clientId, 'e1');
      expect(incomeConflict.clientId, 'i1');
      expect(incomeConflict.existingIncomeMatches, hasLength(1));
    });
  });

  group('payment method iconKey', () {
    test('BackupPaymentMethodData JSON round-trips iconKey', () {
      const method = BackupPaymentMethodData(
        stableKey: 'card',
        name: 'Card',
        colorValue: null,
        isDefault: true,
        sortOrder: 0,
        iconKey: 'nfc',
      );
      final again = BackupPaymentMethodData.fromJson(method.toJson());
      expect(again.iconKey, 'nfc');
      expect(again.stableKey, 'card');
    });

    test('import backfills iconKey when local is null', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await db.insertPaymentMethod(
        PaymentMethodsCompanion.insert(
          name: 'Cash',
          stableKey: const Value('cash'),
          isDefault: const Value(true),
        ),
      );
      expect((await db.findPaymentMethodByStableKey('cash'))!.iconKey, equals(null));

      final envelope = BackupEnvelope(
        formatVersion: kBackupFormatVersion,
        schemaVersion: kAppSchemaVersion,
        exportedAt: DateTime.utc(2026, 1, 1),
        appVersion: '1.1.7',
        data: BackupPayloadData(
          tags: const [],
          paymentMethods: const [
            BackupPaymentMethodData(
              stableKey: 'cash',
              name: 'Cash',
              colorValue: null,
              isDefault: true,
              sortOrder: 0,
              iconKey: 'cash',
            ),
          ],
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

      await BackupImporter().importEnvelope(
        db: db,
        envelope: envelope,
        currentSettings: AppSettings.initial(),
        saveSettings: (_) async {},
      );
      expect((await db.findPaymentMethodByStableKey('cash'))!.iconKey, 'cash');
    });

    test('import does not overwrite existing payment iconKey', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await db.insertPaymentMethod(
        PaymentMethodsCompanion.insert(
          name: 'Cash',
          stableKey: const Value('cash'),
          isDefault: const Value(true),
          iconKey: const Value('money'),
        ),
      );

      final envelope = BackupEnvelope(
        formatVersion: kBackupFormatVersion,
        schemaVersion: kAppSchemaVersion,
        exportedAt: DateTime.utc(2026, 1, 1),
        appVersion: '1.1.7',
        data: BackupPayloadData(
          tags: const [],
          paymentMethods: const [
            BackupPaymentMethodData(
              stableKey: 'cash',
              name: 'Cash',
              colorValue: null,
              isDefault: true,
              sortOrder: 0,
              iconKey: 'cash',
            ),
          ],
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

      await BackupImporter().importEnvelope(
        db: db,
        envelope: envelope,
        currentSettings: AppSettings.initial(),
        saveSettings: (_) async {},
      );
      expect((await db.findPaymentMethodByStableKey('cash'))!.iconKey, 'money');
    });
  });
}
