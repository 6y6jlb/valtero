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
  String get settingsExport => 'Export & Telegram';

  @override
  String get selectCountry => 'Select country';

  @override
  String get addExpense => 'Add expense';

  @override
  String get editExpense => 'Edit expense';

  @override
  String get amount => 'Amount';

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
  String get expenseDeleted => 'Expense deleted';

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
  String get rateSourceFrankfurter => 'Frankfurter';

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
  String get applyFilters => 'Apply';

  @override
  String get clearFilters => 'Clear';

  @override
  String get selectTags => 'Tags';

  @override
  String tagsSelected(int count) {
    return '$count tags';
  }

  @override
  String get summaryCount => 'Expenses';

  @override
  String get summaryCurrencies => 'Currencies';

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
}
