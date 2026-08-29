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
  /// **'Export & Telegram'**
  String get settingsExport;

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

  /// No description provided for @expenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expenseDeleted;

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

  /// No description provided for @rateSourceFrankfurter.
  ///
  /// In en, this message translates to:
  /// **'Frankfurter'**
  String get rateSourceFrankfurter;

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
  /// **'Tap the + button at the bottom of the screen to open the add-expense form. Enter an amount and currency, optionally convert into a reporting currency, pick a country and category tags, and save. Tap an existing expense to edit it in the same form. Until then, the dashboard shows a sample chart with a link to this guide.'**
  String get guideSectionGettingStartedBody;

  /// No description provided for @guideSectionExpenseTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense tracking'**
  String get guideSectionExpenseTrackingTitle;

  /// No description provided for @guideSectionExpenseTrackingBody.
  ///
  /// In en, this message translates to:
  /// **'Each expense stores amount, currency, date, optional country (ISO), payment method, category tags, and note. The original amount and currency are always kept, even if you convert into a reporting currency for storage.'**
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
  /// **'Rates refresh in the background when stale (about every 24 hours). Bind an ExchangeRate-API key, refresh manually, set overrides, and browse all rates in Settings → Currency & rates.'**
  String get guideSectionExchangeRatesBody;

  /// No description provided for @guideSectionExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get guideSectionExportTitle;

  /// No description provided for @guideSectionExportBody.
  ///
  /// In en, this message translates to:
  /// **'Export expenses as CSV or JSON. Save a file, share it, or copy to the clipboard from the export menu or Settings → Export & Telegram.'**
  String get guideSectionExportBody;

  /// No description provided for @guideSectionDataSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & sync'**
  String get guideSectionDataSyncTitle;

  /// No description provided for @guideSectionDataSyncBody.
  ///
  /// In en, this message translates to:
  /// **'Create an encrypted backup of expenses, tags, payment methods, manual rates, and display settings. Protect it with your own passphrase or a generated phrase. Restore on another device from Settings → Backup & sync, or from the empty dashboard. API keys and Telegram credentials are never included.'**
  String get guideSectionDataSyncBody;

  /// No description provided for @guideSectionTelegramTitle.
  ///
  /// In en, this message translates to:
  /// **'Telegram sharing'**
  String get guideSectionTelegramTitle;

  /// No description provided for @guideSectionTelegramBody.
  ///
  /// In en, this message translates to:
  /// **'Enable Telegram in Export settings, enter a bot token and chat id, then send an export document straight to Telegram.'**
  String get guideSectionTelegramBody;

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
