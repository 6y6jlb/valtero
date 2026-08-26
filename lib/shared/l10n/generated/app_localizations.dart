import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
    Locale('ru'),
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
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
