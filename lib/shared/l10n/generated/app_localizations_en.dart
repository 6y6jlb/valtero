// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Valtero';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get recentOperations => 'Recent operations';

  @override
  String get navAdd => 'Add';

  @override
  String get navTags => 'Tags';

  @override
  String get navCurrency => 'Currency';

  @override
  String get navExport => 'Export';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsCurrency => 'Currency & rates';

  @override
  String get settingsExport => 'Export';

  @override
  String get settingsIntegrations => 'Integrations';

  @override
  String get settingsDebug => 'Debug & logs';

  @override
  String get integrationConnected => 'Connected';

  @override
  String get integrationNotConnected => 'Not connected';

  @override
  String get integrationTestConnection => 'Test connection';

  @override
  String get integrationSave => 'Save';

  @override
  String get integrationDisconnect => 'Disconnect';

  @override
  String get connectionOk => 'Connection successful';

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String get connectionNetwork =>
      'No network / DNS lookup failed. Check internet, VPN, or DNS and try again.';

  @override
  String get connectionMissingFields => 'Fill in all required fields';

  @override
  String get connectionInvalidToken => 'Bot token is invalid';

  @override
  String get connectionInvalidChat =>
      'Chat id is invalid or bot cannot access it';

  @override
  String get connectionInvalidKey => 'API key is invalid';

  @override
  String get showSecret => 'Show';

  @override
  String get hideSecret => 'Hide';

  @override
  String get integrationTelegramTitle => 'Telegram';

  @override
  String get integrationTelegramDescription =>
      'Send expense exports to a Telegram chat via bot.';

  @override
  String get integrationFrankfurterTitle => 'Frankfurter';

  @override
  String get integrationFrankfurterDescription =>
      'Free ECB exchange rates (no API key). Used automatically when ExchangeRate-API is not connected.';

  @override
  String get integrationFrankfurterHint =>
      'Built-in fallback. Probe api.frankfurter.dev — if this fails, rates cannot refresh until network/DNS works. Coverage is the ECB currency set only.';

  @override
  String get integrationExchangeRateApiTitle => 'ExchangeRate-API';

  @override
  String get integrationExchangeRateApiDescription =>
      'Fetch FX rates with a key from exchangerate-api.com (v6 API). Keys from exchangeratesapi.io will not work. Without a key, Frankfurter (ECB) is used.';

  @override
  String get exchangeRateApiEnabled => 'Use ExchangeRate-API for rates';

  @override
  String get integrationGoogleDriveSyncTitle => 'Google Drive Sync';

  @override
  String get integrationGoogleDriveSyncDescription =>
      'Encrypted automatic sync between your devices via Google Drive. Google never sees your expenses — only ciphertext.';

  @override
  String get googleDriveSignIn => 'Sign in with Google';

  @override
  String get googleDriveSyncNow => 'Sync now';

  @override
  String get googleDriveSyncOk => 'Sync completed';

  @override
  String get googleDriveSyncPassphrase => 'Sync passphrase';

  @override
  String get googleDriveSyncPassphraseHint =>
      'Used only on this device to encrypt data. Google never receives it. Use the same passphrase on every device.';

  @override
  String get googleDrivePassphraseTooShort =>
      'Passphrase must be at least 8 characters';

  @override
  String get googleDriveWrongPassphrase =>
      'Wrong sync passphrase for the remote backup';

  @override
  String get googleDriveMissingClientId =>
      'Google OAuth client id is not configured. Copy local.oauth.env.example to local.oauth.env and set GOOGLE_OAUTH_CLIENT_ID_DESKTOP / _ANDROID, then rebuild (make run-*).';

  @override
  String get googleDriveReauthRequired => 'Please sign in with Google again';

  @override
  String get googleDriveSignInFailed => 'Google sign-in failed';

  @override
  String get googleDriveAuthCanceled => 'Google sign-in was canceled';

  @override
  String get googleDriveAccessDenied =>
      'Google access was denied. Allow Drive permissions and try again.';

  @override
  String get googleDriveAndroidCustomUriHint =>
      'On Android, open Google Cloud Console → your Android OAuth client → Advanced settings and enable “Custom URI scheme”, then try again. Google blocks this redirect by default on new Android clients.';

  @override
  String get googleDriveMissingClientSecret =>
      'Desktop Google OAuth client secret is missing. In Google Cloud Console open your Desktop OAuth client, copy the Client secret into local.oauth.env as GOOGLE_OAUTH_CLIENT_SECRET_DESKTOP, then rebuild (make run-linux).';

  @override
  String googleDriveLastSynced(String when) {
    return 'Last synced: $when';
  }

  @override
  String get relativeTimeJustNow => 'Just now';

  @override
  String relativeTimeMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String relativeTimeHoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String relativeTimeDaysAgo(int count) {
    return '$count d ago';
  }

  @override
  String get googleDriveSyncStatusHint => 'Last sync time';

  @override
  String get actionSuccessStatusHint => 'Last action time';

  @override
  String get googleDriveSharedTitle => 'Shared sync (other Google accounts)';

  @override
  String get googleDriveSharedDescription =>
      'Share the encrypted sync file with another person. Requires an extra Google permission (drive.file) and may need OAuth verification for public release.';

  @override
  String get googleDriveShareEmail => 'Collaborator email';

  @override
  String get googleDriveShareAdd => 'Share with email';

  @override
  String get googleDriveShareOk => 'Shared successfully';

  @override
  String get googleDriveShareFailed => 'Could not share the sync file';

  @override
  String get googleDriveInvalidEmail => 'Enter a valid email address';

  @override
  String get googleDriveRemoteNewerSchemaTitle => 'Update required to sync';

  @override
  String googleDriveRemoteNewerSchema(
    int remoteSchema,
    int localSchema,
    String remoteApp,
  ) {
    return 'Cloud sync data was written by a newer app (schema $remoteSchema, app $remoteApp). This device is schema $localSchema. Sync was blocked so newer cloud data is not overwritten. Update the app, then try again.';
  }

  @override
  String get googleDriveUnsupportedFormat =>
      'Cloud sync file format is not supported by this app version';

  @override
  String get googleDriveHelpTitle => 'How Google Drive Sync works';

  @override
  String get googleDriveHelpSameAccountTitle =>
      'Same Google account on another device';

  @override
  String get googleDriveHelpSameAccountBody =>
      '1. On this device: set a sync passphrase, then Sign in with Google.\n2. On the other device: Sign in with the same Google account and enter the exact same passphrase.\n3. Sync runs automatically after login and when you tap Sync now. Nothing else to configure.';

  @override
  String get googleDriveHelpCrossAccountTitle => 'Different Google accounts';

  @override
  String get googleDriveHelpCrossAccountBody =>
      'Account 1 (owner):\n1. Set a sync passphrase and Sign in with Google.\n2. Under “Share with another account”, enter account 2’s email and share.\n\nAccount 2 (joiner):\n1. Tap “Join a sync someone shared with you”.\n2. Sign in with Google (broader Drive permission is requested so the app can find the shared file).\n3. Pick the shared sync file, then enter the exact same passphrase account 1 used.\n4. Sync now pulls and merges data both ways through that shared file.';

  @override
  String get googleDriveHelpPassphraseNote =>
      'The passphrase never leaves the device — Google only stores encrypted data. Everyone who syncs together must know and enter the same passphrase.';

  @override
  String get googleDriveHelpRegenNote =>
      'If you regenerate or change the passphrase after connecting, other devices and accounts stop decrypting until they enter the new passphrase too.';

  @override
  String get googleDriveJoinShared => 'Join a sync someone shared with you';

  @override
  String get googleDriveJoinPickTitle => 'Shared sync files';

  @override
  String get googleDriveJoinPickEmpty =>
      'No shared Valtero sync files found. Ask the owner to share with this Google account first.';

  @override
  String get googleDriveJoinConfirm => 'Join this sync';

  @override
  String get googleDriveJoinedAs => 'Joined shared sync';

  @override
  String get googleDriveLeaveShared => 'Leave shared sync';

  @override
  String get googleDrivePassphraseChangeTitle => 'Change sync passphrase?';

  @override
  String get googleDrivePassphraseChangeBody =>
      'Other devices and accounts will stop syncing until they enter this new passphrase. Continue?';

  @override
  String googleDriveSharedFrom(String email) {
    return 'Shared by $email';
  }

  @override
  String fetchAllRatesFrom(String service) {
    return 'Fetch all rates from $service';
  }

  @override
  String fetchAllRatesDone(int count, String service) {
    return 'Saved $count rates from $service to local cache';
  }

  @override
  String fetchRateFromService(String service) {
    return 'Fetch from $service';
  }

  @override
  String rateFetchedFromCache(String service) {
    return 'Using rate from local cache ($service). Tap refresh to update.';
  }

  @override
  String get rateRefreshPair => 'Refresh this rate';

  @override
  String ratesFetchCooldown(int minutes) {
    return 'Next network fetch in $minutes min (keeps free API quota)';
  }

  @override
  String flagUnavailableTooltip(String code) {
    return 'No flag for $code';
  }

  @override
  String get telegramNotConnectedHint =>
      'Connect Telegram in Settings → Integrations to send exports there.';

  @override
  String get openTelegramIntegration => 'Open Telegram settings';

  @override
  String get openExchangeRateApiIntegration => 'Configure ExchangeRate-API';

  @override
  String get rateSourceConnected => 'Rates: ExchangeRate-API (connected)';

  @override
  String get rateSourceFrankfurter => 'Frankfurter';

  @override
  String get debugLoggingEnabled => 'Debug logging';

  @override
  String get debugLoggingDescription =>
      'When enabled, detailed breadcrumbs are written to the log. Errors are always logged. Secrets (API keys, bot tokens, chat ids, passphrases) are never written.';

  @override
  String get debugViewLogs => 'Log contents';

  @override
  String get debugShareLogs => 'Share with developer';

  @override
  String get debugCopyLogs => 'Copy logs';

  @override
  String get debugClearLogs => 'Clear logs';

  @override
  String get debugLogsEmpty => 'No log entries yet.';

  @override
  String get debugLogsShared => 'Log file ready to share';

  @override
  String get debugLogsCopied => 'Logs copied to clipboard';

  @override
  String get debugLogsCleared => 'Logs cleared';

  @override
  String get settingsDataSync => 'Backup & sync';

  @override
  String get dataSyncTitle => 'Backup & sync';

  @override
  String get dataSyncExport => 'Export';

  @override
  String get dataSyncImport => 'Import';

  @override
  String get dataSyncChooseFile => 'Choose backup file';

  @override
  String get dataSyncFileSelected => 'Backup file selected';

  @override
  String get dataSyncImportFromFile => 'Import from file';

  @override
  String get dataSyncImportMergeHint =>
      'Import data from a file. Your existing expenses will not be overwritten — new data will be added.';

  @override
  String get dataSyncGuide =>
      'Export: create an encrypted backup with a passphrase, then save or share the file. Import: load that file on this or another device and enter the same passphrase to restore. Sync means exchanging this file between devices.';

  @override
  String get dataSyncShareManualTitle => 'How to send the backup';

  @override
  String get dataSyncShareManualGuide =>
      'Built-in sharing is not available on this platform. After you save the backup file, send it yourself, for example:\n• attach it to an email;\n• send it in Telegram (or another messenger) as a document;\n• upload it to cloud storage (Google Drive, Dropbox, …) or copy it to a USB drive.\nOn the other device open Backup & sync → Import → choose the file, and enter the same passphrase.';

  @override
  String get dataSyncCopyFilePath => 'Copy file path';

  @override
  String get dataSyncPassphrase => 'Passphrase';

  @override
  String get dataSyncGeneratePassphrase => 'Generate passphrase';

  @override
  String get dataSyncCopyPassphrase => 'Copy passphrase';

  @override
  String get dataSyncGenerateShort => 'Generate';

  @override
  String get dataSyncCopyShort => 'Copy';

  @override
  String get dataSyncShowPassphrase => 'Show passphrase';

  @override
  String get dataSyncHidePassphrase => 'Hide passphrase';

  @override
  String get dataSyncApplyAppearance => 'Apply appearance from backup';

  @override
  String get dataSyncApplyAppearanceHint =>
      'Restores theme, language, money and date formats, timezone, and reporting currencies from the backup. Leave off to keep this device’s current look.';

  @override
  String get dataSyncPassphraseWarning =>
      'Store this passphrase safely. Without it, the backup cannot be opened.';

  @override
  String get dataSyncExportDone => 'Backup saved';

  @override
  String get dataSyncExportFailed => 'Could not save the backup';

  @override
  String dataSyncImportDone(int expenses, int tags, int payments) {
    return 'Imported $expenses expenses, $tags tags, $payments payment methods';
  }

  @override
  String get dataSyncWrongPassphrase => 'Wrong passphrase or damaged file';

  @override
  String get dataSyncUnsupportedFormat => 'Unsupported or invalid backup file';

  @override
  String get dataSyncNewerSchema => 'This backup needs a newer app version';

  @override
  String get dataSyncIntegrationsNotTransferred =>
      'API keys and Telegram credentials are not included in backups.';

  @override
  String get dataSyncGoogleDriveHint =>
      'You can also enable automatic encrypted sync via Google Drive — backups update across devices without manual file exchange.';

  @override
  String get dataSyncGoogleDriveSetup => 'Connect Google Drive Sync';

  @override
  String get dataSyncGoogleDriveManage => 'Open Google Drive Sync settings';

  @override
  String dataSyncImportDoneWithDuplicates(
    int expenses,
    int tags,
    int payments,
    int skipped,
  ) {
    return 'Imported $expenses expenses, $tags tags, $payments payment methods ($skipped duplicates skipped)';
  }

  @override
  String get dataSyncDuplicatesFoundTitle => 'Possible duplicates found';

  @override
  String get dataSyncDuplicatesFoundHint =>
      'These incoming expenses look like ones you already have (same day, amount, and currency). Choose how to handle each.';

  @override
  String get dataSyncMarkAsDuplicate => 'Mark as duplicate';

  @override
  String get dataSyncMarkAsUnique => 'Mark as unique';

  @override
  String get dataSyncMarkSelectedAsDuplicate => 'Selected → duplicate';

  @override
  String get dataSyncMarkSelectedAsUnique => 'Selected → unique';

  @override
  String get dataSyncMarkAllAsDuplicate => 'All → duplicate';

  @override
  String get dataSyncMarkAllAsUnique => 'All → unique';

  @override
  String get dataSyncContinueImport => 'Continue import';

  @override
  String get dataSyncIncomingExpense => 'Incoming';

  @override
  String get dataSyncExistingExpense => 'Existing';

  @override
  String get possibleDuplicateTooltip => 'Possible duplicate';

  @override
  String possibleDuplicatesBannerTitle(int count) {
    return 'Possible duplicates ($count)';
  }

  @override
  String get duplicateReviewSheetTitle => 'Possible duplicates';

  @override
  String get duplicateMarkNotDuplicate => 'Not a duplicate';

  @override
  String get duplicateConflictDialogTitle => 'Similar expense found';

  @override
  String get duplicateConflictDialogHint =>
      'An expense with the same day, amount, and currency already exists.';

  @override
  String get duplicateSaveAsUnique => 'Save as unique';

  @override
  String get duplicateDeleteMatchAndSave => 'Delete match and save';

  @override
  String get duplicateYourExpense => 'Your expense';

  @override
  String get duplicateMatchingExpense => 'Matching expense';

  @override
  String get dashboardRestoreFromBackup => 'Restore from backup';

  @override
  String get selectCountry => 'Select country';

  @override
  String get addExpense => 'Add expense';

  @override
  String get editExpense => 'Edit expense';

  @override
  String get amount => 'Amount';

  @override
  String get amountRequired => 'Enter a valid amount';

  @override
  String get currency => 'Currency';

  @override
  String get saveAsIs => 'Save as-is';

  @override
  String get convertTo => 'Convert to';

  @override
  String exchangeRate(String rate) {
    return 'Rate: $rate';
  }

  @override
  String get rateUnavailable => 'No rate for this pair';

  @override
  String get setRateNow => 'Set rate';

  @override
  String get setManualRateTitle => 'Set exchange rate';

  @override
  String setManualRateHint(String base, String target) {
    return 'How many $target for 1 $base';
  }

  @override
  String get tag => 'Tag';

  @override
  String get note => 'Note';

  @override
  String get date => 'Date';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get confirmDeleteExpense => 'Delete this expense?';

  @override
  String get confirmDeleteExpenseDescription =>
      'This expense will be permanently deleted.';

  @override
  String get expenseDeleted => 'Expense deleted';

  @override
  String bulkSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String bulkAndMore(int count) {
    return '…and $count more';
  }

  @override
  String get bulkDeleteTitle => 'Delete expenses?';

  @override
  String bulkDeleteDescription(String list) {
    return 'These expenses will be permanently deleted:\n$list';
  }

  @override
  String get bulkChangeTags => 'Change tags';

  @override
  String get bulkChangeTagsTitle => 'Change tags';

  @override
  String bulkChangeTagsDescription(String list) {
    return 'New tags will replace existing tags on:\n$list';
  }

  @override
  String get bulkChangeCountry => 'Change country';

  @override
  String get bulkChangeCountryTitle => 'Change country';

  @override
  String bulkChangeCountryDescription(String list) {
    return 'Country will be updated for:\n$list';
  }

  @override
  String get bulkChangeCurrency => 'Change currency';

  @override
  String get bulkChangeCurrencyTitle => 'Change currency';

  @override
  String bulkChangeCurrencyDescription(String currency, String list) {
    return 'Amounts will be converted to $currency for:\n$list';
  }

  @override
  String bulkExpensesDeleted(int count) {
    return '$count expenses deleted';
  }

  @override
  String bulkExpensesUpdated(int count) {
    return '$count expenses updated';
  }

  @override
  String get bulkCurrencyRateUnavailable =>
      'Could not convert: exchange rate unavailable';

  @override
  String get add => 'Add';

  @override
  String get settings => 'Settings';

  @override
  String get reportingCurrencies => 'Reporting currencies';

  @override
  String get primaryCurrency => 'Primary currency';

  @override
  String get apiKey => 'ExchangeRate-API key';

  @override
  String get validateKey => 'Validate & bind';

  @override
  String get refreshRates => 'Refresh rates now';

  @override
  String get manualRates => 'Manual rates';

  @override
  String get baseCurrency => 'From';

  @override
  String get targetCurrency => 'To';

  @override
  String get rate => 'Rate';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get suggestedTags => 'Suggested tags';

  @override
  String get detectCountry => 'Detect country again';

  @override
  String get country => 'Country';

  @override
  String get defaultTags => 'Default tags';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get exportTitle => 'Export';

  @override
  String get exportCsv => 'CSV';

  @override
  String get exportJson => 'JSON';

  @override
  String get saveFile => 'Save file';

  @override
  String get share => 'Share';

  @override
  String get copyAs => 'Copy as';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get sendTelegram => 'Send to Telegram';

  @override
  String get telegramBotToken => 'Telegram bot token';

  @override
  String get telegramChatId => 'Telegram chat id';

  @override
  String get telegramEnabled => 'Enable Telegram';

  @override
  String get summaryTotal => 'Total';

  @override
  String get byTag => 'By tag';

  @override
  String get byPeriod => 'By period';

  @override
  String get displayCurrency => 'Display currency';

  @override
  String get noExpenses => 'No expenses yet';

  @override
  String get expensesEmptyTitle => 'No expenses yet';

  @override
  String get expensesEmptyBody =>
      'Add your first expense to see the list, summary, and charts.';

  @override
  String get filterTag => 'Tag filter';

  @override
  String get filterCurrency => 'Currency filter';

  @override
  String get all => 'All';

  @override
  String get theme => 'Theme';

  @override
  String get locale => 'Language';

  @override
  String get moneyFormat => 'Money display';

  @override
  String get moneyFormatPreview => 'Preview';

  @override
  String get moneyFormatLocaleSymbol => 'Locale with symbol';

  @override
  String get moneyFormatLocaleCode => 'Locale with currency code';

  @override
  String get moneyFormatPlain => 'Plain (1234.56 CODE)';

  @override
  String get dateFormat => 'Date display';

  @override
  String get timeZone => 'Time zone';

  @override
  String timeZoneSystem(String id) {
    return 'System ($id)';
  }

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get keyValid => 'API key is valid';

  @override
  String get keyInvalid => 'API key is invalid';

  @override
  String get ratesRefreshed => 'Rates refreshed';

  @override
  String get exportDone => 'Export ready';

  @override
  String get telegramSent => 'Sent to Telegram';

  @override
  String get telegramFailed => 'Telegram send failed';

  @override
  String get telegramSetupNeeded =>
      'Turn on Telegram and enter bot token and chat id to send exports.';

  @override
  String get shareUnsupported =>
      'Sharing files is not available on this platform.';

  @override
  String get shareFailed => 'Could not share the export file.';

  @override
  String get untagged => 'Untagged';

  @override
  String get periodDay => 'Day';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get newTag => 'New tag';

  @override
  String get addTag => 'Add tag';

  @override
  String get tagGroceries => 'Groceries';

  @override
  String get tagTransport => 'Transport';

  @override
  String get tagHousing => 'Housing';

  @override
  String get tagDining => 'Dining';

  @override
  String get tagHealth => 'Health';

  @override
  String get tagEntertainment => 'Entertainment';

  @override
  String get tagShopping => 'Shopping';

  @override
  String get tagTravel => 'Travel';

  @override
  String get tagUtilities => 'Utilities';

  @override
  String get tagCash => 'Cash';

  @override
  String get tagCard => 'Card';

  @override
  String get tagCrypto => 'Crypto';

  @override
  String get tagTransfer => 'Bank transfer';

  @override
  String get tagEwallet => 'E-wallet';

  @override
  String tripTag(String region) {
    return 'Trip: $region';
  }

  @override
  String get tagColor => 'Color';

  @override
  String get tagColorNone => 'None';

  @override
  String get chartBy => 'Chart by';

  @override
  String get chartByTags => 'Tags';

  @override
  String get chartByTagCountry => 'Country tags';

  @override
  String get chartByPayment => 'Payment method';

  @override
  String get chartByTagTrip => 'Trip tags';

  @override
  String get chartByTagCustom => 'Custom tags';

  @override
  String get chartTagKindHint =>
      'Each expense counts once within this tag kind; missing tags appear as not set';

  @override
  String chartMissingRatesAlert(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses shown without conversion rates',
      one: '1 expense shown without a conversion rate',
    );
    return '$_temp0';
  }

  @override
  String get chartHelpTitle => 'About the chart';

  @override
  String get chartHelpBody =>
      'The chart includes expenses in all currencies. When an exchange rate is missing, amounts are shown in their original currency. Totals may mix currencies until rates are set.';

  @override
  String get expensesSummaryHelpTitle => 'About expenses summary';

  @override
  String get expensesSummaryHelpBody =>
      'Totals are grouped by stored currency. Use the convert button to display list amounts in one currency; the converted total shows how many expenses could be converted.';

  @override
  String get displayCurrencyHelpBody =>
      'Pick a currency to convert list amounts. Original stored amounts are always kept. Missing rates can be set manually before conversion.';

  @override
  String get chartPaymentHint =>
      'Each expense has at most one payment method; unset appears as not set';

  @override
  String get tagKindSectionCountry => 'Country';

  @override
  String get tagKindSectionTrip => 'Trip';

  @override
  String get tagKindSectionCustom => 'Category';

  @override
  String get tagKindUnspecifiedCountry => 'Country not set';

  @override
  String get tagKindUnspecifiedTrip => 'Trip not set';

  @override
  String get tagKindUnspecifiedCustom => 'Category not set';

  @override
  String get tagKindSingleSelectHint =>
      'One tag per group; groups are optional';

  @override
  String get paymentMethod => 'Payment';

  @override
  String get paymentMethodNone => 'Not set';

  @override
  String get paymentMethodUnspecified => 'Payment not set';

  @override
  String get paymentMethodsTitle => 'Payment methods';

  @override
  String get paymentMethodsHint =>
      'Choose a default for new expenses. Built-in methods cannot be deleted.';

  @override
  String get paymentMethodNew => 'New payment method';

  @override
  String get paymentMethodAdd => 'Add payment method';

  @override
  String get paymentMethodEdit => 'Edit payment method';

  @override
  String get paymentMethodBuiltIn => 'Built-in';

  @override
  String get paymentMethodClearDefault => 'Clear default payment';

  @override
  String get filterPayment => 'Payment';

  @override
  String paymentSelected(int count) {
    return '$count selected';
  }

  @override
  String get chartByMonth => 'Months';

  @override
  String get chartByCurrency => 'Currency';

  @override
  String get chartByYear => 'Years';

  @override
  String get filterTags => 'Filter tags';

  @override
  String get excludeTag => 'Exclude';

  @override
  String get periodRange => 'Period';

  @override
  String get periodAll => 'All time';

  @override
  String get periodFrom => 'From';

  @override
  String get periodTo => 'To';

  @override
  String periodFromTo(String from, String to) {
    return '$from — $to';
  }

  @override
  String get periodToday => 'Today';

  @override
  String get periodYesterday => 'Yesterday';

  @override
  String get periodLast7Days => 'Last 7 days';

  @override
  String get periodLast30Days => 'Last 30 days';

  @override
  String get periodThisMonth => 'This month';

  @override
  String get periodLastMonth => 'Last month';

  @override
  String get periodThisQuarter => 'This quarter';

  @override
  String get periodThisYear => 'This year';

  @override
  String get periodPreviousYear => 'Previous year';

  @override
  String get periodLast12Months => 'Last 12 months';

  @override
  String get periodCustom => 'Custom range';

  @override
  String get periodCustomHint => 'Pick from and to dates';

  @override
  String get periodPickRange => 'Pick dates';

  @override
  String get showExpenses => 'Show expenses';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortDate => 'Date';

  @override
  String get sortAmount => 'Amount';

  @override
  String get sortCurrency => 'Currency';

  @override
  String get groupBy => 'Group by';

  @override
  String get groupNone => 'None';

  @override
  String get groupDate => 'Date';

  @override
  String get groupCurrency => 'Currency';

  @override
  String get groupTag => 'Tag';

  @override
  String get groupTagCountry => 'Country';

  @override
  String get groupPayment => 'Payment';

  @override
  String get groupTagTrip => 'Trip';

  @override
  String get groupTagCustom => 'Category';

  @override
  String get groupTags => 'Tags';

  @override
  String get excludeTags => 'Exclude tags';

  @override
  String get ascending => 'Ascending';

  @override
  String get descending => 'Descending';

  @override
  String get viewRates => 'View rates';

  @override
  String get allRates => 'All rates';

  @override
  String get addRate => 'Add rate';

  @override
  String get noRatesYet => 'No rates saved yet — refresh or add a manual rate';

  @override
  String get rateSourceApi => 'ExchangeRate-API';

  @override
  String get rateSourceManual => 'Manual';

  @override
  String get currencyFiat => 'Fiat';

  @override
  String get currencyCrypto => 'Crypto';

  @override
  String get currencyCustom => 'Custom';

  @override
  String get addCustomCurrency => 'Add currency';

  @override
  String get currencyCode => 'Currency code';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get expandFilters => 'Show filters';

  @override
  String get collapseFilters => 'Hide filters';

  @override
  String get applyFilters => 'Apply';

  @override
  String get clearFilters => 'Clear';

  @override
  String get filtersApplied => 'Filters applied';

  @override
  String get filtersCleared => 'Filters cleared';

  @override
  String get selectTags => 'Tags';

  @override
  String tagsSelected(int count) {
    return '$count tags';
  }

  @override
  String get summaryCount => 'Expenses';

  @override
  String get summaryExpenses => 'Expenses';

  @override
  String get summaryCurrencies => 'Currencies';

  @override
  String summaryPerCurrencyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses',
      one: '1 expense',
    );
    return '$_temp0';
  }

  @override
  String summaryConvertedTotal(String currency) {
    return 'Total in $currency';
  }

  @override
  String summaryPartialTotal(int converted, int total) {
    return 'Converted $converted of $total';
  }

  @override
  String totalRecords(int count) {
    return 'Total: $count';
  }

  @override
  String get perPage => 'Per page';

  @override
  String get export => 'Export';

  @override
  String get listingView => 'View';

  @override
  String get viewList => 'List';

  @override
  String get viewGrouping => 'Grouping';

  @override
  String get viewChart => 'Chart';

  @override
  String get columnDate => 'Date';

  @override
  String get columnGroup => 'Group';

  @override
  String get columnCount => 'Count';

  @override
  String get columnAmount => 'Amount';

  @override
  String get columnCurrency => 'Currency';

  @override
  String get columnTags => 'Tags';

  @override
  String get noMatchingExpenses => 'No expenses match the filters';

  @override
  String get displayIn => 'Display in';

  @override
  String get displayOriginal => 'Original currencies';

  @override
  String get displayOriginalHint => 'Show stored amounts without conversion';

  @override
  String get ratesReady => 'All rates available';

  @override
  String ratesMissingCount(int count) {
    return '$count rates missing';
  }

  @override
  String get pickOtherCurrency => 'Other currency…';

  @override
  String get missingRatesTitle => 'Conversion not possible';

  @override
  String missingRatesBody(int count, String target) {
    return 'Missing rates for $count pairs to $target. Set them to continue.';
  }

  @override
  String get retryConversion => 'Check again';

  @override
  String missingRatesStill(int count) {
    return 'Still missing $count rates';
  }

  @override
  String get saveAsIsDescription =>
      'The amount is saved in the currency you entered. No conversion is applied.';

  @override
  String get tagsNoneSelected => 'None selected';

  @override
  String tagsSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get guideTitle => 'What Valtero can do';

  @override
  String get guideSubtitle =>
      'A short tour of the main features. Tap a section to expand.';

  @override
  String get guideOpenFromSettings => 'Platform guide';

  @override
  String get dashboardSampleChartLabel =>
      'Example — your chart will look like this after you add expenses';

  @override
  String get dashboardOpenGuide => 'What the app can do';

  @override
  String get chartLegendTitle => 'Segments';

  @override
  String chartLegendSummary(int visible, int total) {
    return '$visible of $total shown';
  }

  @override
  String get guideSampleGroceries => 'Groceries';

  @override
  String get guideSampleTransport => 'Transport';

  @override
  String get guideSampleDining => 'Dining';

  @override
  String get guideSampleCountryRu => 'Russia';

  @override
  String get guideSampleCountryGe => 'Georgia';

  @override
  String get guideSampleCountryTr => 'Turkey';

  @override
  String get guideSectionGettingStartedTitle => 'Getting started';

  @override
  String get guideSectionGettingStartedBody =>
      'Tap the + button at the bottom of the screen to open the add-expense form. Enter an amount and currency, optionally convert into a reporting currency, pick a country and category tags, and save. If another expense already has the same day, amount, and currency, you can mark yours as unique, delete the match, or cancel. Tap an existing expense to edit it in the same form. Until then, the dashboard shows a sample chart with a link to this guide.';

  @override
  String get guideSectionExpenseTrackingTitle => 'Expense tracking';

  @override
  String get guideSectionExpenseTrackingBody =>
      'Each expense stores amount, currency, date, optional country (ISO), payment method, category tags, and note. The original amount and currency are always kept, even if you convert into a reporting currency for storage. On the expenses list, select several rows to delete them or change tags, country, or currency in bulk. Possible duplicates (same day, original amount, and currency) show an alert badge; open the banner to delete a row or mark it as not a duplicate.';

  @override
  String get guideSectionTagsTitle => 'Tags';

  @override
  String get guideSectionTagsBody =>
      'Category tags label what you spent on (groceries, transport, …). Country is a separate field on the expense, not a tag. Payment is also separate (cash, card, crypto, or your own). Manage tags and payment methods in Settings.';

  @override
  String get guideSectionChartsTitle => 'Spending charts';

  @override
  String get guideSectionChartsBody =>
      'The dashboard donut chart breaks down spending by country, payment method, category, months, or currency. Switch the breakdown with the icons under the chart. Missing country, payment, or category appear as not set. Tap a segment to open matching expenses. Tap a legend chip to show or hide that slice. Below the chart, the last 10 expenses are listed with a link to the full list. Open Show expenses for list, grouping, and chart views with sort and pagination.';

  @override
  String get guideSectionExchangeRatesTitle => 'Exchange rates';

  @override
  String get guideSectionExchangeRatesBody =>
      'Rates refresh in the background when stale (about every 24 hours). Connect ExchangeRate-API in Settings → Integrations, refresh manually, set overrides, and browse all rates in Settings → Currency & rates. Without a key, Frankfurter (ECB) is used.';

  @override
  String get guideSectionExportTitle => 'Export';

  @override
  String get guideSectionExportBody =>
      'Export expenses as CSV or JSON. Save a file, share it, or copy to the clipboard from the export menu or Settings → Export. Telegram appears as a destination only after you connect it under Integrations.';

  @override
  String get guideSectionDataSyncTitle => 'Backup & sync';

  @override
  String get guideSectionDataSyncBody =>
      'Create an encrypted backup of expenses, tags, payment methods, manual rates, and display settings. Protect it with your own passphrase or a generated phrase. Save the file (on Android/iOS the share sheet lets you Save to Files / Downloads), then send it (email, Telegram as a document, cloud, USB). Import merges: existing expenses are kept and new data is added. If incoming expenses look like ones you already have (same day, amount, and currency), you choose which to skip as duplicates and which to import as unique. Restore from Settings → Backup & sync, or from the empty dashboard. API keys and Telegram credentials are never included. For automatic multi-device sync, connect Google Drive Sync under Settings → Integrations (same encryption; Google only stores ciphertext).';

  @override
  String get guideSectionTelegramTitle => 'Telegram sharing';

  @override
  String get guideSectionTelegramBody =>
      'Connect Telegram in Settings → Integrations, enter a bot token and chat id, test the connection, then send an export document from the export menu.';

  @override
  String get guideSectionIntegrationsTitle => 'Integrations';

  @override
  String get guideSectionIntegrationsBody =>
      'Optional services (Telegram, Frankfurter, ExchangeRate-API, Google Drive Sync) live under Settings → Integrations. Each has its own form. Frankfurter is built-in (ECB rates, no key) and used when ExchangeRate-API is not connected. Google Drive Sync encrypts a snapshot locally, stores it in your Drive appDataFolder, and pulls/merges on launch and after edits. Cross-account sharing uses a separate shared file and the drive.file permission. Features that depend on an integration appear only while it is connected.';

  @override
  String get guideSectionDebugTitle => 'Debug & logs';

  @override
  String get guideSectionDebugBody =>
      'Settings → Debug & logs can turn on verbose logging. Errors are always recorded. You can view, copy, or share the log file with a developer; secrets are redacted.';

  @override
  String get guideSectionFiltersTitle => 'Filters';

  @override
  String get guideSectionFiltersBody =>
      'Filter by period, currency, tags, and payment on the dashboard and expenses page. Both use a compact summary bar that opens filters in a full-screen sheet. Apply or clear filters anytime.';
}
