import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ru'),
    Locale('sr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Valtero'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get navExpenses;

  /// No description provided for @recentOperations.
  ///
  /// In en, this message translates to:
  /// **'Recent operations'**
  String get recentOperations;

  /// No description provided for @navAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get navAdd;

  /// No description provided for @navTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get navTags;

  /// No description provided for @navCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get navCurrency;

  /// No description provided for @navExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get navExport;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency & rates'**
  String get settingsCurrency;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get settingsExport;

  /// No description provided for @settingsIntegrations.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get settingsIntegrations;

  /// No description provided for @settingsDebug.
  ///
  /// In en, this message translates to:
  /// **'Debug & logs'**
  String get settingsDebug;

  /// No description provided for @integrationConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get integrationConnected;

  /// No description provided for @integrationNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get integrationNotConnected;

  /// No description provided for @integrationTestConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get integrationTestConnection;

  /// No description provided for @integrationSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get integrationSave;

  /// No description provided for @integrationDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get integrationDisconnect;

  /// No description provided for @connectionOk.
  ///
  /// In en, this message translates to:
  /// **'Connection successful'**
  String get connectionOk;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get connectionFailed;

  /// No description provided for @connectionNetwork.
  ///
  /// In en, this message translates to:
  /// **'No network / DNS lookup failed. Check internet, VPN, or DNS and try again.'**
  String get connectionNetwork;

  /// No description provided for @connectionMissingFields.
  ///
  /// In en, this message translates to:
  /// **'Fill in all required fields'**
  String get connectionMissingFields;

  /// No description provided for @connectionInvalidToken.
  ///
  /// In en, this message translates to:
  /// **'Bot token is invalid'**
  String get connectionInvalidToken;

  /// No description provided for @connectionInvalidChat.
  ///
  /// In en, this message translates to:
  /// **'Chat id is invalid or bot cannot access it'**
  String get connectionInvalidChat;

  /// No description provided for @connectionInvalidKey.
  ///
  /// In en, this message translates to:
  /// **'API key is invalid'**
  String get connectionInvalidKey;

  /// No description provided for @showSecret.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get showSecret;

  /// No description provided for @hideSecret.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hideSecret;

  /// No description provided for @integrationTelegramTitle.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get integrationTelegramTitle;

  /// No description provided for @integrationTelegramDescription.
  ///
  /// In en, this message translates to:
  /// **'Send expense exports to a Telegram chat via bot.'**
  String get integrationTelegramDescription;

  /// No description provided for @integrationFrankfurterTitle.
  ///
  /// In en, this message translates to:
  /// **'Frankfurter'**
  String get integrationFrankfurterTitle;

  /// No description provided for @integrationFrankfurterDescription.
  ///
  /// In en, this message translates to:
  /// **'Free ECB exchange rates (no API key). Used automatically when ExchangeRate-API is not connected.'**
  String get integrationFrankfurterDescription;

  /// No description provided for @integrationFrankfurterHint.
  ///
  /// In en, this message translates to:
  /// **'Built-in fallback. Probe api.frankfurter.dev — if this fails, rates cannot refresh until network/DNS works. Coverage is the ECB currency set only.'**
  String get integrationFrankfurterHint;

  /// No description provided for @integrationExchangeRateApiTitle.
  ///
  /// In en, this message translates to:
  /// **'ExchangeRate-API'**
  String get integrationExchangeRateApiTitle;

  /// No description provided for @integrationExchangeRateApiDescription.
  ///
  /// In en, this message translates to:
  /// **'Fetch FX rates with a key from exchangerate-api.com (v6 API). Keys from exchangeratesapi.io will not work. Without a key, Frankfurter (ECB) is used.'**
  String get integrationExchangeRateApiDescription;

  /// No description provided for @exchangeRateApiEnabled.
  ///
  /// In en, this message translates to:
  /// **'Use ExchangeRate-API for rates'**
  String get exchangeRateApiEnabled;

  /// No description provided for @integrationGoogleDriveSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Google Drive Sync'**
  String get integrationGoogleDriveSyncTitle;

  /// No description provided for @integrationGoogleDriveSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'Encrypted automatic sync between your devices via Google Drive. Google never sees your expenses — only ciphertext.'**
  String get integrationGoogleDriveSyncDescription;

  /// No description provided for @googleDriveSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get googleDriveSignIn;

  /// No description provided for @googleDriveSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get googleDriveSyncNow;

  /// No description provided for @googleDriveSyncOk.
  ///
  /// In en, this message translates to:
  /// **'Sync completed'**
  String get googleDriveSyncOk;

  /// No description provided for @googleDriveSyncPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Sync passphrase'**
  String get googleDriveSyncPassphrase;

  /// No description provided for @googleDriveSyncPassphraseHint.
  ///
  /// In en, this message translates to:
  /// **'Used only on this device to encrypt data. Google never receives it. Use the same passphrase on every device.'**
  String get googleDriveSyncPassphraseHint;

  /// No description provided for @googleDrivePassphraseTooShort.
  ///
  /// In en, this message translates to:
  /// **'Passphrase must be at least 8 characters'**
  String get googleDrivePassphraseTooShort;

  /// No description provided for @googleDriveWrongPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Wrong sync passphrase for the remote backup'**
  String get googleDriveWrongPassphrase;

  /// No description provided for @googleDriveMissingClientId.
  ///
  /// In en, this message translates to:
  /// **'Google OAuth client id is not configured. Copy local.oauth.env.example to local.oauth.env and set GOOGLE_OAUTH_CLIENT_ID_DESKTOP / _ANDROID, then rebuild (make run-*).'**
  String get googleDriveMissingClientId;

  /// No description provided for @googleDriveReauthRequired.
  ///
  /// In en, this message translates to:
  /// **'Please sign in with Google again'**
  String get googleDriveReauthRequired;

  /// No description provided for @googleDriveSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed'**
  String get googleDriveSignInFailed;

  /// No description provided for @googleDriveAuthCanceled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was canceled'**
  String get googleDriveAuthCanceled;

  /// No description provided for @googleDriveAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Google access was denied. Allow Drive permissions and try again.'**
  String get googleDriveAccessDenied;

  /// No description provided for @googleDriveAndroidCustomUriHint.
  ///
  /// In en, this message translates to:
  /// **'On Android, open Google Cloud Console → your Android OAuth client → Advanced settings and enable “Custom URI scheme”, then try again. Google blocks this redirect by default on new Android clients.'**
  String get googleDriveAndroidCustomUriHint;

  /// No description provided for @googleDriveMissingClientSecret.
  ///
  /// In en, this message translates to:
  /// **'Desktop Google OAuth client secret is missing. In Google Cloud Console open your Desktop OAuth client, copy the Client secret into local.oauth.env as GOOGLE_OAUTH_CLIENT_SECRET_DESKTOP, then rebuild (make run-linux).'**
  String get googleDriveMissingClientSecret;

  /// No description provided for @googleDriveLastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced: {when}'**
  String googleDriveLastSynced(String when);

  /// No description provided for @relativeTimeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get relativeTimeJustNow;

  /// No description provided for @relativeTimeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String relativeTimeMinutesAgo(int count);

  /// No description provided for @relativeTimeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String relativeTimeHoursAgo(int count);

  /// No description provided for @relativeTimeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} d ago'**
  String relativeTimeDaysAgo(int count);

  /// No description provided for @googleDriveSyncStatusHint.
  ///
  /// In en, this message translates to:
  /// **'Last sync time'**
  String get googleDriveSyncStatusHint;

  /// No description provided for @actionSuccessStatusHint.
  ///
  /// In en, this message translates to:
  /// **'Last action time'**
  String get actionSuccessStatusHint;

  /// No description provided for @googleDriveSharedTitle.
  ///
  /// In en, this message translates to:
  /// **'Shared sync (other Google accounts)'**
  String get googleDriveSharedTitle;

  /// No description provided for @googleDriveSharedDescription.
  ///
  /// In en, this message translates to:
  /// **'Share the encrypted sync file with another person. Requires an extra Google permission (drive.file) and may need OAuth verification for public release.'**
  String get googleDriveSharedDescription;

  /// No description provided for @googleDriveShareEmail.
  ///
  /// In en, this message translates to:
  /// **'Collaborator email'**
  String get googleDriveShareEmail;

  /// No description provided for @googleDriveShareAdd.
  ///
  /// In en, this message translates to:
  /// **'Share with email'**
  String get googleDriveShareAdd;

  /// No description provided for @googleDriveShareOk.
  ///
  /// In en, this message translates to:
  /// **'Shared successfully'**
  String get googleDriveShareOk;

  /// No description provided for @googleDriveShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share the sync file'**
  String get googleDriveShareFailed;

  /// No description provided for @googleDriveInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get googleDriveInvalidEmail;

  /// No description provided for @googleDriveRemoteNewerSchemaTitle.
  ///
  /// In en, this message translates to:
  /// **'Update required to sync'**
  String get googleDriveRemoteNewerSchemaTitle;

  /// No description provided for @googleDriveRemoteNewerSchema.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync data was written by a newer app (schema {remoteSchema}, app {remoteApp}). This device is schema {localSchema}. Sync was blocked so newer cloud data is not overwritten. Update the app, then try again.'**
  String googleDriveRemoteNewerSchema(
    int remoteSchema,
    int localSchema,
    String remoteApp,
  );

  /// No description provided for @googleDriveUnsupportedFormat.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync file format is not supported by this app version'**
  String get googleDriveUnsupportedFormat;

  /// No description provided for @googleDriveHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'How Google Drive Sync works'**
  String get googleDriveHelpTitle;

  /// No description provided for @googleDriveHelpSameAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Same Google account on another device'**
  String get googleDriveHelpSameAccountTitle;

  /// No description provided for @googleDriveHelpSameAccountBody.
  ///
  /// In en, this message translates to:
  /// **'1. On this device: set a sync passphrase, then Sign in with Google.\n2. On the other device: Sign in with the same Google account and enter the exact same passphrase.\n3. Sync runs automatically after login and when you tap Sync now. Nothing else to configure.'**
  String get googleDriveHelpSameAccountBody;

  /// No description provided for @googleDriveHelpCrossAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Different Google accounts'**
  String get googleDriveHelpCrossAccountTitle;

  /// No description provided for @googleDriveHelpCrossAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Account 1 (owner):\n1. Set a sync passphrase and Sign in with Google.\n2. Under “Share with another account”, enter account 2’s email and share.\n\nAccount 2 (joiner):\n1. Tap “Join a sync someone shared with you”.\n2. Sign in with Google (broader Drive permission is requested so the app can find the shared file).\n3. Pick the shared sync file, then enter the exact same passphrase account 1 used.\n4. Sync now pulls and merges data both ways through that shared file.'**
  String get googleDriveHelpCrossAccountBody;

  /// No description provided for @googleDriveHelpPassphraseNote.
  ///
  /// In en, this message translates to:
  /// **'The passphrase never leaves the device — Google only stores encrypted data. Everyone who syncs together must know and enter the same passphrase.'**
  String get googleDriveHelpPassphraseNote;

  /// No description provided for @googleDriveHelpRegenNote.
  ///
  /// In en, this message translates to:
  /// **'If you regenerate or change the passphrase after connecting, other devices and accounts stop decrypting until they enter the new passphrase too.'**
  String get googleDriveHelpRegenNote;

  /// No description provided for @googleDriveJoinShared.
  ///
  /// In en, this message translates to:
  /// **'Join a sync someone shared with you'**
  String get googleDriveJoinShared;

  /// No description provided for @googleDriveJoinPickTitle.
  ///
  /// In en, this message translates to:
  /// **'Shared sync files'**
  String get googleDriveJoinPickTitle;

  /// No description provided for @googleDriveJoinPickEmpty.
  ///
  /// In en, this message translates to:
  /// **'No shared Valtero sync files found. Ask the owner to share with this Google account first.'**
  String get googleDriveJoinPickEmpty;

  /// No description provided for @googleDriveJoinConfirm.
  ///
  /// In en, this message translates to:
  /// **'Join this sync'**
  String get googleDriveJoinConfirm;

  /// No description provided for @googleDriveJoinedAs.
  ///
  /// In en, this message translates to:
  /// **'Joined shared sync'**
  String get googleDriveJoinedAs;

  /// No description provided for @googleDriveLeaveShared.
  ///
  /// In en, this message translates to:
  /// **'Leave shared sync'**
  String get googleDriveLeaveShared;

  /// No description provided for @googleDrivePassphraseChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change sync passphrase?'**
  String get googleDrivePassphraseChangeTitle;

  /// No description provided for @googleDrivePassphraseChangeBody.
  ///
  /// In en, this message translates to:
  /// **'Other devices and accounts will stop syncing until they enter this new passphrase. Continue?'**
  String get googleDrivePassphraseChangeBody;

  /// No description provided for @googleDriveSharedFrom.
  ///
  /// In en, this message translates to:
  /// **'Shared by {email}'**
  String googleDriveSharedFrom(String email);

  /// No description provided for @fetchAllRatesFrom.
  ///
  /// In en, this message translates to:
  /// **'Fetch all rates from {service}'**
  String fetchAllRatesFrom(String service);

  /// No description provided for @fetchAllRatesDone.
  ///
  /// In en, this message translates to:
  /// **'Saved {count} rates from {service} to local cache'**
  String fetchAllRatesDone(int count, String service);

  /// No description provided for @fetchRateFromService.
  ///
  /// In en, this message translates to:
  /// **'Fetch from {service}'**
  String fetchRateFromService(String service);

  /// No description provided for @rateFetchedFromCache.
  ///
  /// In en, this message translates to:
  /// **'Using rate from local cache ({service}). Tap refresh to update.'**
  String rateFetchedFromCache(String service);

  /// No description provided for @rateRefreshPair.
  ///
  /// In en, this message translates to:
  /// **'Refresh this rate'**
  String get rateRefreshPair;

  /// No description provided for @ratesFetchCooldown.
  ///
  /// In en, this message translates to:
  /// **'Next network fetch in {minutes} min (keeps free API quota)'**
  String ratesFetchCooldown(int minutes);

  /// No description provided for @flagUnavailableTooltip.
  ///
  /// In en, this message translates to:
  /// **'No flag for {code}'**
  String flagUnavailableTooltip(String code);

  /// No description provided for @telegramNotConnectedHint.
  ///
  /// In en, this message translates to:
  /// **'Connect Telegram in Settings → Integrations to send exports there.'**
  String get telegramNotConnectedHint;

  /// No description provided for @openTelegramIntegration.
  ///
  /// In en, this message translates to:
  /// **'Open Telegram settings'**
  String get openTelegramIntegration;

  /// No description provided for @openExchangeRateApiIntegration.
  ///
  /// In en, this message translates to:
  /// **'Configure ExchangeRate-API'**
  String get openExchangeRateApiIntegration;

  /// No description provided for @rateSourceConnected.
  ///
  /// In en, this message translates to:
  /// **'Rates: ExchangeRate-API (connected)'**
  String get rateSourceConnected;

  /// No description provided for @rateSourceFrankfurter.
  ///
  /// In en, this message translates to:
  /// **'Frankfurter'**
  String get rateSourceFrankfurter;

  /// No description provided for @debugLoggingEnabled.
  ///
  /// In en, this message translates to:
  /// **'Debug logging'**
  String get debugLoggingEnabled;

  /// No description provided for @debugLoggingDescription.
  ///
  /// In en, this message translates to:
  /// **'When enabled, detailed breadcrumbs are written to the log. Errors are always logged. Secrets (API keys, bot tokens, chat ids, passphrases) are never written.'**
  String get debugLoggingDescription;

  /// No description provided for @debugViewLogs.
  ///
  /// In en, this message translates to:
  /// **'Log contents'**
  String get debugViewLogs;

  /// No description provided for @debugShareLogs.
  ///
  /// In en, this message translates to:
  /// **'Share with developer'**
  String get debugShareLogs;

  /// No description provided for @debugCopyLogs.
  ///
  /// In en, this message translates to:
  /// **'Copy logs'**
  String get debugCopyLogs;

  /// No description provided for @debugClearLogs.
  ///
  /// In en, this message translates to:
  /// **'Clear logs'**
  String get debugClearLogs;

  /// No description provided for @debugLogsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No log entries yet.'**
  String get debugLogsEmpty;

  /// No description provided for @debugLogsShared.
  ///
  /// In en, this message translates to:
  /// **'Log file ready to share'**
  String get debugLogsShared;

  /// No description provided for @debugLogsCopied.
  ///
  /// In en, this message translates to:
  /// **'Logs copied to clipboard'**
  String get debugLogsCopied;

  /// No description provided for @debugLogsCleared.
  ///
  /// In en, this message translates to:
  /// **'Logs cleared'**
  String get debugLogsCleared;

  /// No description provided for @settingsDataSync.
  ///
  /// In en, this message translates to:
  /// **'Backup & sync'**
  String get settingsDataSync;

  /// No description provided for @dataSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & sync'**
  String get dataSyncTitle;

  /// No description provided for @dataSyncExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get dataSyncExport;

  /// No description provided for @dataSyncImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get dataSyncImport;

  /// No description provided for @dataSyncChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose backup file'**
  String get dataSyncChooseFile;

  /// No description provided for @dataSyncFileSelected.
  ///
  /// In en, this message translates to:
  /// **'Backup file selected'**
  String get dataSyncFileSelected;

  /// No description provided for @dataSyncImportFromFile.
  ///
  /// In en, this message translates to:
  /// **'Import from file'**
  String get dataSyncImportFromFile;

  /// No description provided for @dataSyncImportMergeHint.
  ///
  /// In en, this message translates to:
  /// **'Import data from a file. Your existing expenses will not be overwritten — new data will be added.'**
  String get dataSyncImportMergeHint;

  /// No description provided for @dataSyncGuide.
  ///
  /// In en, this message translates to:
  /// **'Export: create an encrypted backup with a passphrase, then save or share the file. Import: load that file on this or another device and enter the same passphrase to restore. Sync means exchanging this file between devices.'**
  String get dataSyncGuide;

  /// No description provided for @dataSyncShareManualTitle.
  ///
  /// In en, this message translates to:
  /// **'How to send the backup'**
  String get dataSyncShareManualTitle;

  /// No description provided for @dataSyncShareManualGuide.
  ///
  /// In en, this message translates to:
  /// **'Built-in sharing is not available on this platform. After you save the backup file, send it yourself, for example:\n• attach it to an email;\n• send it in Telegram (or another messenger) as a document;\n• upload it to cloud storage (Google Drive, Dropbox, …) or copy it to a USB drive.\nOn the other device open Backup & sync → Import → choose the file, and enter the same passphrase.'**
  String get dataSyncShareManualGuide;

  /// No description provided for @dataSyncCopyFilePath.
  ///
  /// In en, this message translates to:
  /// **'Copy file path'**
  String get dataSyncCopyFilePath;

  /// No description provided for @dataSyncPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Passphrase'**
  String get dataSyncPassphrase;

  /// No description provided for @dataSyncGeneratePassphrase.
  ///
  /// In en, this message translates to:
  /// **'Generate passphrase'**
  String get dataSyncGeneratePassphrase;

  /// No description provided for @dataSyncCopyPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Copy passphrase'**
  String get dataSyncCopyPassphrase;

  /// No description provided for @dataSyncGenerateShort.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get dataSyncGenerateShort;

  /// No description provided for @dataSyncCopyShort.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get dataSyncCopyShort;

  /// No description provided for @dataSyncShowPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Show passphrase'**
  String get dataSyncShowPassphrase;

  /// No description provided for @dataSyncHidePassphrase.
  ///
  /// In en, this message translates to:
  /// **'Hide passphrase'**
  String get dataSyncHidePassphrase;

  /// No description provided for @dataSyncApplyAppearance.
  ///
  /// In en, this message translates to:
  /// **'Apply appearance from backup'**
  String get dataSyncApplyAppearance;

  /// No description provided for @dataSyncApplyAppearanceHint.
  ///
  /// In en, this message translates to:
  /// **'Restores theme, language, money and date formats, timezone, and reporting currencies from the backup. Leave off to keep this device’s current look.'**
  String get dataSyncApplyAppearanceHint;

  /// No description provided for @dataSyncPassphraseWarning.
  ///
  /// In en, this message translates to:
  /// **'Store this passphrase safely. Without it, the backup cannot be opened.'**
  String get dataSyncPassphraseWarning;

  /// No description provided for @dataSyncExportDone.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get dataSyncExportDone;

  /// No description provided for @dataSyncExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the backup'**
  String get dataSyncExportFailed;

  /// No description provided for @dataSyncImportDone.
  ///
  /// In en, this message translates to:
  /// **'Imported {expenses} expenses, {tags} tags, {payments} payment methods'**
  String dataSyncImportDone(int expenses, int tags, int payments);

  /// No description provided for @dataSyncWrongPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Wrong passphrase or damaged file'**
  String get dataSyncWrongPassphrase;

  /// No description provided for @dataSyncUnsupportedFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported or invalid backup file'**
  String get dataSyncUnsupportedFormat;

  /// No description provided for @dataSyncNewerSchema.
  ///
  /// In en, this message translates to:
  /// **'This backup needs a newer app version'**
  String get dataSyncNewerSchema;

  /// No description provided for @dataSyncIntegrationsNotTransferred.
  ///
  /// In en, this message translates to:
  /// **'API keys and Telegram credentials are not included in backups.'**
  String get dataSyncIntegrationsNotTransferred;

  /// No description provided for @dataSyncGoogleDriveHint.
  ///
  /// In en, this message translates to:
  /// **'You can also enable automatic encrypted sync via Google Drive — backups update across devices without manual file exchange.'**
  String get dataSyncGoogleDriveHint;

  /// No description provided for @dataSyncGoogleDriveSetup.
  ///
  /// In en, this message translates to:
  /// **'Connect Google Drive Sync'**
  String get dataSyncGoogleDriveSetup;

  /// No description provided for @dataSyncGoogleDriveManage.
  ///
  /// In en, this message translates to:
  /// **'Open Google Drive Sync settings'**
  String get dataSyncGoogleDriveManage;

  /// No description provided for @dataSyncImportDoneWithDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Imported {expenses} expenses, {tags} tags, {payments} payment methods ({skipped} duplicates skipped)'**
  String dataSyncImportDoneWithDuplicates(
    int expenses,
    int tags,
    int payments,
    int skipped,
  );

  /// No description provided for @dataSyncDuplicatesFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicates found'**
  String get dataSyncDuplicatesFoundTitle;

  /// No description provided for @dataSyncDuplicatesFoundHint.
  ///
  /// In en, this message translates to:
  /// **'These incoming expenses look like ones you already have (same day, amount, and currency). Choose how to handle each.'**
  String get dataSyncDuplicatesFoundHint;

  /// No description provided for @dataSyncMarkAsDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Mark as duplicate'**
  String get dataSyncMarkAsDuplicate;

  /// No description provided for @dataSyncMarkAsUnique.
  ///
  /// In en, this message translates to:
  /// **'Mark as unique'**
  String get dataSyncMarkAsUnique;

  /// No description provided for @dataSyncMarkSelectedAsDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Selected → duplicate'**
  String get dataSyncMarkSelectedAsDuplicate;

  /// No description provided for @dataSyncMarkSelectedAsUnique.
  ///
  /// In en, this message translates to:
  /// **'Selected → unique'**
  String get dataSyncMarkSelectedAsUnique;

  /// No description provided for @dataSyncMarkAllAsDuplicate.
  ///
  /// In en, this message translates to:
  /// **'All → duplicate'**
  String get dataSyncMarkAllAsDuplicate;

  /// No description provided for @dataSyncMarkAllAsUnique.
  ///
  /// In en, this message translates to:
  /// **'All → unique'**
  String get dataSyncMarkAllAsUnique;

  /// No description provided for @dataSyncContinueImport.
  ///
  /// In en, this message translates to:
  /// **'Continue import'**
  String get dataSyncContinueImport;

  /// No description provided for @dataSyncIncomingExpense.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get dataSyncIncomingExpense;

  /// No description provided for @dataSyncExistingExpense.
  ///
  /// In en, this message translates to:
  /// **'Existing'**
  String get dataSyncExistingExpense;

  /// No description provided for @possibleDuplicateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicate'**
  String get possibleDuplicateTooltip;

  /// No description provided for @possibleDuplicatesBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicates ({count})'**
  String possibleDuplicatesBannerTitle(int count);

  /// No description provided for @duplicateReviewSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicates'**
  String get duplicateReviewSheetTitle;

  /// No description provided for @duplicateMarkNotDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Not a duplicate'**
  String get duplicateMarkNotDuplicate;

  /// No description provided for @duplicateConflictDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Similar expense found'**
  String get duplicateConflictDialogTitle;

  /// No description provided for @duplicateConflictDialogHint.
  ///
  /// In en, this message translates to:
  /// **'An expense with the same day, amount, and currency already exists.'**
  String get duplicateConflictDialogHint;

  /// No description provided for @duplicateSaveAsUnique.
  ///
  /// In en, this message translates to:
  /// **'Save as unique'**
  String get duplicateSaveAsUnique;

  /// No description provided for @duplicateDeleteMatchAndSave.
  ///
  /// In en, this message translates to:
  /// **'Delete match and save'**
  String get duplicateDeleteMatchAndSave;

  /// No description provided for @duplicateYourExpense.
  ///
  /// In en, this message translates to:
  /// **'Your expense'**
  String get duplicateYourExpense;

  /// No description provided for @duplicateMatchingExpense.
  ///
  /// In en, this message translates to:
  /// **'Matching expense'**
  String get duplicateMatchingExpense;

  /// No description provided for @dashboardRestoreFromBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get dashboardRestoreFromBackup;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get selectCountry;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get editExpense;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get amountRequired;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @saveAsIs.
  ///
  /// In en, this message translates to:
  /// **'Save as-is'**
  String get saveAsIs;

  /// No description provided for @convertTo.
  ///
  /// In en, this message translates to:
  /// **'Convert to'**
  String get convertTo;

  /// No description provided for @exchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Rate: {rate}'**
  String exchangeRate(String rate);

  /// No description provided for @rateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No rate for this pair'**
  String get rateUnavailable;

  /// No description provided for @setRateNow.
  ///
  /// In en, this message translates to:
  /// **'Set rate'**
  String get setRateNow;

  /// No description provided for @setManualRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Set exchange rate'**
  String get setManualRateTitle;

  /// No description provided for @setManualRateHint.
  ///
  /// In en, this message translates to:
  /// **'How many {target} for 1 {base}'**
  String setManualRateHint(String base, String target);

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tag;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @confirmDeleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete this expense?'**
  String get confirmDeleteExpense;

  /// No description provided for @confirmDeleteExpenseDescription.
  ///
  /// In en, this message translates to:
  /// **'This expense will be permanently deleted.'**
  String get confirmDeleteExpenseDescription;

  /// No description provided for @expenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expenseDeleted;

  /// No description provided for @bulkSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String bulkSelectedCount(int count);

  /// No description provided for @bulkAndMore.
  ///
  /// In en, this message translates to:
  /// **'…and {count} more'**
  String bulkAndMore(int count);

  /// No description provided for @bulkDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete expenses?'**
  String get bulkDeleteTitle;

  /// No description provided for @bulkDeleteDescription.
  ///
  /// In en, this message translates to:
  /// **'These expenses will be permanently deleted:\n{list}'**
  String bulkDeleteDescription(String list);

  /// No description provided for @bulkChangeTags.
  ///
  /// In en, this message translates to:
  /// **'Change tags'**
  String get bulkChangeTags;

  /// No description provided for @bulkChangeTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Change tags'**
  String get bulkChangeTagsTitle;

  /// No description provided for @bulkChangeTagsDescription.
  ///
  /// In en, this message translates to:
  /// **'New tags will replace existing tags on:\n{list}'**
  String bulkChangeTagsDescription(String list);

  /// No description provided for @bulkChangeCountry.
  ///
  /// In en, this message translates to:
  /// **'Change country'**
  String get bulkChangeCountry;

  /// No description provided for @bulkChangeCountryTitle.
  ///
  /// In en, this message translates to:
  /// **'Change country'**
  String get bulkChangeCountryTitle;

  /// No description provided for @bulkChangeCountryDescription.
  ///
  /// In en, this message translates to:
  /// **'Country will be updated for:\n{list}'**
  String bulkChangeCountryDescription(String list);

  /// No description provided for @bulkChangeCurrency.
  ///
  /// In en, this message translates to:
  /// **'Change currency'**
  String get bulkChangeCurrency;

  /// No description provided for @bulkChangeCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Change currency'**
  String get bulkChangeCurrencyTitle;

  /// No description provided for @bulkChangeCurrencyDescription.
  ///
  /// In en, this message translates to:
  /// **'Amounts will be converted to {currency} for:\n{list}'**
  String bulkChangeCurrencyDescription(String currency, String list);

  /// No description provided for @bulkExpensesDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count} expenses deleted'**
  String bulkExpensesDeleted(int count);

  /// No description provided for @bulkExpensesUpdated.
  ///
  /// In en, this message translates to:
  /// **'{count} expenses updated'**
  String bulkExpensesUpdated(int count);

  /// No description provided for @bulkCurrencyRateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not convert: exchange rate unavailable'**
  String get bulkCurrencyRateUnavailable;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @reportingCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Reporting currencies'**
  String get reportingCurrencies;

  /// No description provided for @primaryCurrency.
  ///
  /// In en, this message translates to:
  /// **'Primary currency'**
  String get primaryCurrency;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'ExchangeRate-API key'**
  String get apiKey;

  /// No description provided for @validateKey.
  ///
  /// In en, this message translates to:
  /// **'Validate & bind'**
  String get validateKey;

  /// No description provided for @refreshRates.
  ///
  /// In en, this message translates to:
  /// **'Refresh rates now'**
  String get refreshRates;

  /// No description provided for @manualRates.
  ///
  /// In en, this message translates to:
  /// **'Manual rates'**
  String get manualRates;

  /// No description provided for @baseCurrency.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get baseCurrency;

  /// No description provided for @targetCurrency.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get targetCurrency;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @tagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsTitle;

  /// No description provided for @suggestedTags.
  ///
  /// In en, this message translates to:
  /// **'Suggested tags'**
  String get suggestedTags;

  /// No description provided for @detectCountry.
  ///
  /// In en, this message translates to:
  /// **'Detect country again'**
  String get detectCountry;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @defaultTags.
  ///
  /// In en, this message translates to:
  /// **'Default tags'**
  String get defaultTags;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportTitle;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get exportCsv;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'JSON'**
  String get exportJson;

  /// No description provided for @saveFile.
  ///
  /// In en, this message translates to:
  /// **'Save file'**
  String get saveFile;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @copyAs.
  ///
  /// In en, this message translates to:
  /// **'Copy as'**
  String get copyAs;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @sendTelegram.
  ///
  /// In en, this message translates to:
  /// **'Send to Telegram'**
  String get sendTelegram;

  /// No description provided for @telegramBotToken.
  ///
  /// In en, this message translates to:
  /// **'Telegram bot token'**
  String get telegramBotToken;

  /// No description provided for @telegramChatId.
  ///
  /// In en, this message translates to:
  /// **'Telegram chat id'**
  String get telegramChatId;

  /// No description provided for @telegramEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable Telegram'**
  String get telegramEnabled;

  /// No description provided for @summaryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get summaryTotal;

  /// No description provided for @byTag.
  ///
  /// In en, this message translates to:
  /// **'By tag'**
  String get byTag;

  /// No description provided for @byPeriod.
  ///
  /// In en, this message translates to:
  /// **'By period'**
  String get byPeriod;

  /// No description provided for @displayCurrency.
  ///
  /// In en, this message translates to:
  /// **'Display currency'**
  String get displayCurrency;

  /// No description provided for @noExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get noExpenses;

  /// No description provided for @expensesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get expensesEmptyTitle;

  /// No description provided for @expensesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense to see the list, summary, and charts.'**
  String get expensesEmptyBody;

  /// No description provided for @filterTag.
  ///
  /// In en, this message translates to:
  /// **'Tag filter'**
  String get filterTag;

  /// No description provided for @filterCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency filter'**
  String get filterCurrency;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @locale.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get locale;

  /// No description provided for @moneyFormat.
  ///
  /// In en, this message translates to:
  /// **'Money display'**
  String get moneyFormat;

  /// No description provided for @moneyFormatPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get moneyFormatPreview;

  /// No description provided for @moneyFormatLocaleSymbol.
  ///
  /// In en, this message translates to:
  /// **'Locale with symbol'**
  String get moneyFormatLocaleSymbol;

  /// No description provided for @moneyFormatLocaleCode.
  ///
  /// In en, this message translates to:
  /// **'Locale with currency code'**
  String get moneyFormatLocaleCode;

  /// No description provided for @moneyFormatPlain.
  ///
  /// In en, this message translates to:
  /// **'Plain (1234.56 CODE)'**
  String get moneyFormatPlain;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date display'**
  String get dateFormat;

  /// No description provided for @timeZone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get timeZone;

  /// No description provided for @timeZoneSystem.
  ///
  /// In en, this message translates to:
  /// **'System ({id})'**
  String timeZoneSystem(String id);

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @keyValid.
  ///
  /// In en, this message translates to:
  /// **'API key is valid'**
  String get keyValid;

  /// No description provided for @keyInvalid.
  ///
  /// In en, this message translates to:
  /// **'API key is invalid'**
  String get keyInvalid;

  /// No description provided for @ratesRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Rates refreshed'**
  String get ratesRefreshed;

  /// No description provided for @exportDone.
  ///
  /// In en, this message translates to:
  /// **'Export ready'**
  String get exportDone;

  /// No description provided for @telegramSent.
  ///
  /// In en, this message translates to:
  /// **'Sent to Telegram'**
  String get telegramSent;

  /// No description provided for @telegramFailed.
  ///
  /// In en, this message translates to:
  /// **'Telegram send failed'**
  String get telegramFailed;

  /// No description provided for @telegramSetupNeeded.
  ///
  /// In en, this message translates to:
  /// **'Turn on Telegram and enter bot token and chat id to send exports.'**
  String get telegramSetupNeeded;

  /// No description provided for @shareUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Sharing files is not available on this platform.'**
  String get shareUnsupported;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share the export file.'**
  String get shareFailed;

  /// No description provided for @untagged.
  ///
  /// In en, this message translates to:
  /// **'Untagged'**
  String get untagged;

  /// No description provided for @periodDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get periodDay;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @newTag.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get newTag;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// No description provided for @tagGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get tagGroceries;

  /// No description provided for @tagTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get tagTransport;

  /// No description provided for @tagHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get tagHousing;

  /// No description provided for @tagDining.
  ///
  /// In en, this message translates to:
  /// **'Dining'**
  String get tagDining;

  /// No description provided for @tagHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get tagHealth;

  /// No description provided for @tagEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get tagEntertainment;

  /// No description provided for @tagShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get tagShopping;

  /// No description provided for @tagTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get tagTravel;

  /// No description provided for @tagUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get tagUtilities;

  /// No description provided for @tagCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get tagCash;

  /// No description provided for @tagCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get tagCard;

  /// No description provided for @tagCrypto.
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get tagCrypto;

  /// No description provided for @tagTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get tagTransfer;

  /// No description provided for @tagEwallet.
  ///
  /// In en, this message translates to:
  /// **'E-wallet'**
  String get tagEwallet;

  /// No description provided for @tripTag.
  ///
  /// In en, this message translates to:
  /// **'Trip: {region}'**
  String tripTag(String region);

  /// No description provided for @tagColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get tagColor;

  /// No description provided for @tagColorNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get tagColorNone;

  /// No description provided for @chartBy.
  ///
  /// In en, this message translates to:
  /// **'Chart by'**
  String get chartBy;

  /// No description provided for @chartByTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get chartByTags;

  /// No description provided for @chartByTagCountry.
  ///
  /// In en, this message translates to:
  /// **'Country tags'**
  String get chartByTagCountry;

  /// No description provided for @chartByPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get chartByPayment;

  /// No description provided for @chartByTagTrip.
  ///
  /// In en, this message translates to:
  /// **'Trip tags'**
  String get chartByTagTrip;

  /// No description provided for @chartByTagCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom tags'**
  String get chartByTagCustom;

  /// No description provided for @chartTagKindHint.
  ///
  /// In en, this message translates to:
  /// **'Each expense counts once within this tag kind; missing tags appear as not set'**
  String get chartTagKindHint;

  /// No description provided for @chartMissingRatesAlert.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 expense shown without a conversion rate} other{{count} expenses shown without conversion rates}}'**
  String chartMissingRatesAlert(int count);

  /// No description provided for @chartHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'About the chart'**
  String get chartHelpTitle;

  /// No description provided for @chartTypeDonut.
  ///
  /// In en, this message translates to:
  /// **'Donut chart'**
  String get chartTypeDonut;

  /// No description provided for @chartTypeColumn.
  ///
  /// In en, this message translates to:
  /// **'Column chart'**
  String get chartTypeColumn;

  /// No description provided for @chartHelpBody.
  ///
  /// In en, this message translates to:
  /// **'The chart includes expenses in all currencies. When an exchange rate is missing, amounts are shown in their original currency. Totals may mix currencies until rates are set.'**
  String get chartHelpBody;

  /// No description provided for @expensesSummaryHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'About expenses summary'**
  String get expensesSummaryHelpTitle;

  /// No description provided for @expensesSummaryHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Totals are grouped by stored currency. Use the convert button to display list amounts in one currency; the converted total shows how many expenses could be converted.'**
  String get expensesSummaryHelpBody;

  /// No description provided for @displayCurrencyHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a currency to convert list amounts. Original stored amounts are always kept. Missing rates can be set manually before conversion.'**
  String get displayCurrencyHelpBody;

  /// No description provided for @chartPaymentHint.
  ///
  /// In en, this message translates to:
  /// **'Each expense has at most one payment method; unset appears as not set'**
  String get chartPaymentHint;

  /// No description provided for @tagKindSectionCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get tagKindSectionCountry;

  /// No description provided for @tagKindSectionTrip.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get tagKindSectionTrip;

  /// No description provided for @tagKindSectionCustom.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get tagKindSectionCustom;

  /// No description provided for @tagKindUnspecifiedCountry.
  ///
  /// In en, this message translates to:
  /// **'Country not set'**
  String get tagKindUnspecifiedCountry;

  /// No description provided for @tagKindUnspecifiedTrip.
  ///
  /// In en, this message translates to:
  /// **'Trip not set'**
  String get tagKindUnspecifiedTrip;

  /// No description provided for @tagKindUnspecifiedCustom.
  ///
  /// In en, this message translates to:
  /// **'Category not set'**
  String get tagKindUnspecifiedCustom;

  /// No description provided for @tagKindSingleSelectHint.
  ///
  /// In en, this message translates to:
  /// **'One tag per group; groups are optional'**
  String get tagKindSingleSelectHint;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentMethod;

  /// No description provided for @paymentMethodNone.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get paymentMethodNone;

  /// No description provided for @paymentMethodUnspecified.
  ///
  /// In en, this message translates to:
  /// **'Payment not set'**
  String get paymentMethodUnspecified;

  /// No description provided for @paymentMethodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get paymentMethodsTitle;

  /// No description provided for @paymentMethodsHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a default for new expenses. Built-in methods cannot be deleted.'**
  String get paymentMethodsHint;

  /// No description provided for @paymentMethodNew.
  ///
  /// In en, this message translates to:
  /// **'New payment method'**
  String get paymentMethodNew;

  /// No description provided for @paymentMethodAdd.
  ///
  /// In en, this message translates to:
  /// **'Add payment method'**
  String get paymentMethodAdd;

  /// No description provided for @paymentMethodEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit payment method'**
  String get paymentMethodEdit;

  /// No description provided for @paymentMethodBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get paymentMethodBuiltIn;

  /// No description provided for @paymentMethodClearDefault.
  ///
  /// In en, this message translates to:
  /// **'Clear default payment'**
  String get paymentMethodClearDefault;

  /// No description provided for @filterPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get filterPayment;

  /// No description provided for @paymentSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String paymentSelected(int count);

  /// No description provided for @chartByMonth.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get chartByMonth;

  /// No description provided for @chartByDay.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get chartByDay;

  /// No description provided for @chartByWeek.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get chartByWeek;

  /// No description provided for @chartByDate.
  ///
  /// In en, this message translates to:
  /// **'By date'**
  String get chartByDate;

  /// No description provided for @chartByCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get chartByCurrency;

  /// No description provided for @chartByYear.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get chartByYear;

  /// No description provided for @filterTags.
  ///
  /// In en, this message translates to:
  /// **'Filter tags'**
  String get filterTags;

  /// No description provided for @excludeTag.
  ///
  /// In en, this message translates to:
  /// **'Exclude'**
  String get excludeTag;

  /// No description provided for @periodRange.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get periodRange;

  /// No description provided for @periodAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get periodAll;

  /// No description provided for @periodFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get periodFrom;

  /// No description provided for @periodTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get periodTo;

  /// No description provided for @periodFromTo.
  ///
  /// In en, this message translates to:
  /// **'{from} — {to}'**
  String periodFromTo(String from, String to);

  /// No description provided for @periodToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get periodToday;

  /// No description provided for @periodYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get periodYesterday;

  /// No description provided for @periodLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get periodLast7Days;

  /// No description provided for @periodLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get periodLast30Days;

  /// No description provided for @periodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get periodThisMonth;

  /// No description provided for @periodLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get periodLastMonth;

  /// No description provided for @periodThisQuarter.
  ///
  /// In en, this message translates to:
  /// **'This quarter'**
  String get periodThisQuarter;

  /// No description provided for @periodThisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get periodThisYear;

  /// No description provided for @periodPreviousYear.
  ///
  /// In en, this message translates to:
  /// **'Previous year'**
  String get periodPreviousYear;

  /// No description provided for @periodLast12Months.
  ///
  /// In en, this message translates to:
  /// **'Last 12 months'**
  String get periodLast12Months;

  /// No description provided for @periodCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get periodCustom;

  /// No description provided for @periodCustomHint.
  ///
  /// In en, this message translates to:
  /// **'Pick from and to dates'**
  String get periodCustomHint;

  /// No description provided for @periodPickRange.
  ///
  /// In en, this message translates to:
  /// **'Pick dates'**
  String get periodPickRange;

  /// No description provided for @showExpenses.
  ///
  /// In en, this message translates to:
  /// **'Show expenses'**
  String get showExpenses;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get sortDate;

  /// No description provided for @sortAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get sortAmount;

  /// No description provided for @sortCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get sortCurrency;

  /// No description provided for @groupBy.
  ///
  /// In en, this message translates to:
  /// **'Group by'**
  String get groupBy;

  /// No description provided for @groupNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get groupNone;

  /// No description provided for @groupDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get groupDate;

  /// No description provided for @groupCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get groupCurrency;

  /// No description provided for @groupTag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get groupTag;

  /// No description provided for @groupTagCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get groupTagCountry;

  /// No description provided for @groupPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get groupPayment;

  /// No description provided for @groupTagTrip.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get groupTagTrip;

  /// No description provided for @groupTagCustom.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get groupTagCustom;

  /// No description provided for @groupTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get groupTags;

  /// No description provided for @excludeTags.
  ///
  /// In en, this message translates to:
  /// **'Exclude tags'**
  String get excludeTags;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @viewRates.
  ///
  /// In en, this message translates to:
  /// **'View rates'**
  String get viewRates;

  /// No description provided for @allRates.
  ///
  /// In en, this message translates to:
  /// **'All rates'**
  String get allRates;

  /// No description provided for @addRate.
  ///
  /// In en, this message translates to:
  /// **'Add rate'**
  String get addRate;

  /// No description provided for @noRatesYet.
  ///
  /// In en, this message translates to:
  /// **'No rates saved yet — refresh or add a manual rate'**
  String get noRatesYet;

  /// No description provided for @rateSourceApi.
  ///
  /// In en, this message translates to:
  /// **'ExchangeRate-API'**
  String get rateSourceApi;

  /// No description provided for @rateSourceManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get rateSourceManual;

  /// No description provided for @currencyFiat.
  ///
  /// In en, this message translates to:
  /// **'Fiat'**
  String get currencyFiat;

  /// No description provided for @currencyCrypto.
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get currencyCrypto;

  /// No description provided for @currencyCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get currencyCustom;

  /// No description provided for @addCustomCurrency.
  ///
  /// In en, this message translates to:
  /// **'Add currency'**
  String get addCustomCurrency;

  /// No description provided for @currencyCode.
  ///
  /// In en, this message translates to:
  /// **'Currency code'**
  String get currencyCode;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @expandFilters.
  ///
  /// In en, this message translates to:
  /// **'Show filters'**
  String get expandFilters;

  /// No description provided for @collapseFilters.
  ///
  /// In en, this message translates to:
  /// **'Hide filters'**
  String get collapseFilters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyFilters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearFilters;

  /// No description provided for @filtersApplied.
  ///
  /// In en, this message translates to:
  /// **'Filters applied'**
  String get filtersApplied;

  /// No description provided for @filtersCleared.
  ///
  /// In en, this message translates to:
  /// **'Filters cleared'**
  String get filtersCleared;

  /// No description provided for @selectTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get selectTags;

  /// No description provided for @tagsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} tags'**
  String tagsSelected(int count);

  /// No description provided for @summaryCount.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get summaryCount;

  /// No description provided for @summaryExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get summaryExpenses;

  /// No description provided for @summaryCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Currencies'**
  String get summaryCurrencies;

  /// No description provided for @summaryPerCurrencyCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 expense} other{{count} expenses}}'**
  String summaryPerCurrencyCount(int count);

  /// No description provided for @summaryConvertedTotal.
  ///
  /// In en, this message translates to:
  /// **'Total in {currency}'**
  String summaryConvertedTotal(String currency);

  /// No description provided for @summaryPartialTotal.
  ///
  /// In en, this message translates to:
  /// **'Converted {converted} of {total}'**
  String summaryPartialTotal(int converted, int total);

  /// No description provided for @totalRecords.
  ///
  /// In en, this message translates to:
  /// **'Total: {count}'**
  String totalRecords(int count);

  /// No description provided for @perPage.
  ///
  /// In en, this message translates to:
  /// **'Per page'**
  String get perPage;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @listingView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get listingView;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get viewList;

  /// No description provided for @viewGrouping.
  ///
  /// In en, this message translates to:
  /// **'Grouping'**
  String get viewGrouping;

  /// No description provided for @viewChart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get viewChart;

  /// No description provided for @columnDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get columnDate;

  /// No description provided for @columnGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get columnGroup;

  /// No description provided for @columnCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get columnCount;

  /// No description provided for @columnAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get columnAmount;

  /// No description provided for @columnCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get columnCurrency;

  /// No description provided for @columnTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get columnTags;

  /// No description provided for @noMatchingExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses match the filters'**
  String get noMatchingExpenses;

  /// No description provided for @displayIn.
  ///
  /// In en, this message translates to:
  /// **'Display in'**
  String get displayIn;

  /// No description provided for @displayOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original currencies'**
  String get displayOriginal;

  /// No description provided for @displayOriginalHint.
  ///
  /// In en, this message translates to:
  /// **'Show stored amounts without conversion'**
  String get displayOriginalHint;

  /// No description provided for @ratesReady.
  ///
  /// In en, this message translates to:
  /// **'All rates available'**
  String get ratesReady;

  /// No description provided for @ratesMissingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} rates missing'**
  String ratesMissingCount(int count);

  /// No description provided for @pickOtherCurrency.
  ///
  /// In en, this message translates to:
  /// **'Other currency…'**
  String get pickOtherCurrency;

  /// No description provided for @missingRatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Conversion not possible'**
  String get missingRatesTitle;

  /// No description provided for @missingRatesBody.
  ///
  /// In en, this message translates to:
  /// **'Missing rates for {count} pairs to {target}. Set them to continue.'**
  String missingRatesBody(int count, String target);

  /// No description provided for @retryConversion.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get retryConversion;

  /// No description provided for @missingRatesStill.
  ///
  /// In en, this message translates to:
  /// **'Still missing {count} rates'**
  String missingRatesStill(int count);

  /// No description provided for @saveAsIsDescription.
  ///
  /// In en, this message translates to:
  /// **'The amount is saved in the currency you entered. No conversion is applied.'**
  String get saveAsIsDescription;

  /// No description provided for @tagsNoneSelected.
  ///
  /// In en, this message translates to:
  /// **'None selected'**
  String get tagsNoneSelected;

  /// No description provided for @tagsSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String tagsSelectedCount(int count);

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'What Valtero can do'**
  String get guideTitle;

  /// No description provided for @guideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A short tour of the main features. Tap a section to expand.'**
  String get guideSubtitle;

  /// No description provided for @guideOpenFromSettings.
  ///
  /// In en, this message translates to:
  /// **'Platform guide'**
  String get guideOpenFromSettings;

  /// No description provided for @dashboardSampleChartLabel.
  ///
  /// In en, this message translates to:
  /// **'Example — your chart will look like this after you add expenses'**
  String get dashboardSampleChartLabel;

  /// No description provided for @dashboardOpenGuide.
  ///
  /// In en, this message translates to:
  /// **'What the app can do'**
  String get dashboardOpenGuide;

  /// No description provided for @chartLegendTitle.
  ///
  /// In en, this message translates to:
  /// **'Segments'**
  String get chartLegendTitle;

  /// No description provided for @chartLegendSummary.
  ///
  /// In en, this message translates to:
  /// **'{visible} of {total} shown'**
  String chartLegendSummary(int visible, int total);

  /// No description provided for @guideSampleGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get guideSampleGroceries;

  /// No description provided for @guideSampleTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get guideSampleTransport;

  /// No description provided for @guideSampleDining.
  ///
  /// In en, this message translates to:
  /// **'Dining'**
  String get guideSampleDining;

  /// No description provided for @guideSampleCountryRu.
  ///
  /// In en, this message translates to:
  /// **'Russia'**
  String get guideSampleCountryRu;

  /// No description provided for @guideSampleCountryGe.
  ///
  /// In en, this message translates to:
  /// **'Georgia'**
  String get guideSampleCountryGe;

  /// No description provided for @guideSampleCountryTr.
  ///
  /// In en, this message translates to:
  /// **'Turkey'**
  String get guideSampleCountryTr;

  /// No description provided for @guideSectionGettingStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting started'**
  String get guideSectionGettingStartedTitle;

  /// No description provided for @guideSectionGettingStartedBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button at the bottom of the screen to open the add-expense form. Enter an amount and currency, optionally convert into a reporting currency, pick a country and category tags, and save. If another expense already has the same day, amount, and currency, you can mark yours as unique, delete the match, or cancel. Tap an existing expense to edit it in the same form. Until then, the dashboard shows a sample chart with a link to this guide.'**
  String get guideSectionGettingStartedBody;

  /// No description provided for @guideSectionExpenseTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense tracking'**
  String get guideSectionExpenseTrackingTitle;

  /// No description provided for @guideSectionExpenseTrackingBody.
  ///
  /// In en, this message translates to:
  /// **'Each expense stores amount, currency, date, optional country (ISO), payment method, category tags, and note. The original amount and currency are always kept, even if you convert into a reporting currency for storage. On the expenses list, select several rows to delete them or change tags, country, or currency in bulk. Possible duplicates (same day, original amount, and currency) show an alert badge; open the banner to delete a row or mark it as not a duplicate.'**
  String get guideSectionExpenseTrackingBody;

  /// No description provided for @guideSectionTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get guideSectionTagsTitle;

  /// No description provided for @guideSectionTagsBody.
  ///
  /// In en, this message translates to:
  /// **'Category tags label what you spent on (groceries, transport, …). Country is a separate field on the expense, not a tag. Payment is also separate (cash, card, crypto, or your own). Manage tags and payment methods in Settings.'**
  String get guideSectionTagsBody;

  /// No description provided for @guideSectionChartsTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending charts'**
  String get guideSectionChartsTitle;

  /// No description provided for @guideSectionChartsBody.
  ///
  /// In en, this message translates to:
  /// **'The dashboard donut chart breaks down spending by country, payment method, category, months, or currency. Switch the breakdown with the icons under the chart. Missing country, payment, or category appear as not set. Tap a segment to open matching expenses. Tap a legend chip to show or hide that slice. Below the chart, the last 10 expenses are listed with a link to the full list. Open Show expenses for list, grouping, and chart views with sort and pagination.'**
  String get guideSectionChartsBody;

  /// No description provided for @guideSectionExchangeRatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Exchange rates'**
  String get guideSectionExchangeRatesTitle;

  /// No description provided for @guideSectionExchangeRatesBody.
  ///
  /// In en, this message translates to:
  /// **'Rates refresh in the background when stale (about every 24 hours). Connect ExchangeRate-API in Settings → Integrations, refresh manually, set overrides, and browse all rates in Settings → Currency & rates. Without a key, Frankfurter (ECB) is used.'**
  String get guideSectionExchangeRatesBody;

  /// No description provided for @guideSectionExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get guideSectionExportTitle;

  /// No description provided for @guideSectionExportBody.
  ///
  /// In en, this message translates to:
  /// **'Export expenses as CSV or JSON. Save a file, share it, or copy to the clipboard from the export menu or Settings → Export. Telegram appears as a destination only after you connect it under Integrations.'**
  String get guideSectionExportBody;

  /// No description provided for @guideSectionDataSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & sync'**
  String get guideSectionDataSyncTitle;

  /// No description provided for @guideSectionDataSyncBody.
  ///
  /// In en, this message translates to:
  /// **'Create an encrypted backup of expenses, tags, payment methods, manual rates, and display settings. Protect it with your own passphrase or a generated phrase. Save the file (on Android/iOS the share sheet lets you Save to Files / Downloads), then send it (email, Telegram as a document, cloud, USB). Import merges: existing expenses are kept and new data is added. If incoming expenses look like ones you already have (same day, amount, and currency), you choose which to skip as duplicates and which to import as unique. Restore from Settings → Backup & sync, or from the empty dashboard. API keys and Telegram credentials are never included. For automatic multi-device sync, connect Google Drive Sync under Settings → Integrations (same encryption; Google only stores ciphertext).'**
  String get guideSectionDataSyncBody;

  /// No description provided for @guideSectionTelegramTitle.
  ///
  /// In en, this message translates to:
  /// **'Telegram sharing'**
  String get guideSectionTelegramTitle;

  /// No description provided for @guideSectionTelegramBody.
  ///
  /// In en, this message translates to:
  /// **'Connect Telegram in Settings → Integrations, enter a bot token and chat id, test the connection, then send an export document from the export menu.'**
  String get guideSectionTelegramBody;

  /// No description provided for @guideSectionIntegrationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get guideSectionIntegrationsTitle;

  /// No description provided for @guideSectionIntegrationsBody.
  ///
  /// In en, this message translates to:
  /// **'Optional services (Telegram, Frankfurter, ExchangeRate-API, Google Drive Sync) live under Settings → Integrations. Each has its own form. Frankfurter is built-in (ECB rates, no key) and used when ExchangeRate-API is not connected. Google Drive Sync encrypts a snapshot locally, stores it in your Drive appDataFolder, and pulls/merges on launch and after edits. Cross-account sharing uses a separate shared file and the drive.file permission. Features that depend on an integration appear only while it is connected.'**
  String get guideSectionIntegrationsBody;

  /// No description provided for @guideSectionDebugTitle.
  ///
  /// In en, this message translates to:
  /// **'Debug & logs'**
  String get guideSectionDebugTitle;

  /// No description provided for @guideSectionDebugBody.
  ///
  /// In en, this message translates to:
  /// **'Settings → Debug & logs can turn on verbose logging. Errors are always recorded. You can view, copy, or share the log file with a developer; secrets are redacted.'**
  String get guideSectionDebugBody;

  /// No description provided for @guideSectionFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get guideSectionFiltersTitle;

  /// No description provided for @guideSectionFiltersBody.
  ///
  /// In en, this message translates to:
  /// **'Filter by period, currency, tags, and payment on the dashboard and expenses page. Both use a compact summary bar that opens filters in a full-screen sheet. Apply or clear filters anytime.'**
  String get guideSectionFiltersBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ru', 'sr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ru':
      return AppLocalizationsRu();
    case 'sr':
      return AppLocalizationsSr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
