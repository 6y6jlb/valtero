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
  String get settingsExport => 'Export & Telegram';

  @override
  String get settingsDataSync => 'Backup & sync';

  @override
  String get dataSyncTitle => 'Backup & sync';

  @override
  String get dataSyncExport => 'Export';

  @override
  String get dataSyncImport => 'Import';

  @override
  String get dataSyncPassphrase => 'Passphrase';

  @override
  String get dataSyncGeneratePassphrase => 'Generate passphrase';

  @override
  String get dataSyncCopyPassphrase => 'Copy passphrase';

  @override
  String get dataSyncPassphraseWarning =>
      'Store this passphrase safely. Without it, the backup cannot be opened.';

  @override
  String get dataSyncExportDone => 'Backup saved';

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
      'Tap the + button at the bottom of the screen to open the add-expense form. Enter an amount and currency, optionally convert into a reporting currency, pick a country and category tags, and save. Tap an existing expense to edit it in the same form. Until then, the dashboard shows a sample chart with a link to this guide.';

  @override
  String get guideSectionExpenseTrackingTitle => 'Expense tracking';

  @override
  String get guideSectionExpenseTrackingBody =>
      'Each expense stores amount, currency, date, optional country (ISO), payment method, category tags, and note. The original amount and currency are always kept, even if you convert into a reporting currency for storage.';

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
      'Rates refresh in the background when stale (about every 24 hours). Bind an ExchangeRate-API key, refresh manually, set overrides, and browse all rates in Settings → Currency & rates.';

  @override
  String get guideSectionExportTitle => 'Export';

  @override
  String get guideSectionExportBody =>
      'Export expenses as CSV or JSON. Save a file, share it, or copy to the clipboard from the export menu or Settings → Export & Telegram.';

  @override
  String get guideSectionDataSyncTitle => 'Backup & sync';

  @override
  String get guideSectionDataSyncBody =>
      'Create an encrypted backup of expenses, tags, payment methods, manual rates, and display settings. Protect it with your own passphrase or a generated phrase. Restore on another device from Settings → Backup & sync, or from the empty dashboard. API keys and Telegram credentials are never included.';

  @override
  String get guideSectionTelegramTitle => 'Telegram sharing';

  @override
  String get guideSectionTelegramBody =>
      'Enable Telegram in Export settings, enter a bot token and chat id, then send an export document straight to Telegram.';

  @override
  String get guideSectionFiltersTitle => 'Filters';

  @override
  String get guideSectionFiltersBody =>
      'Filter by period, currency, tags, and payment on the dashboard and expenses page. Both use a compact summary bar that opens filters in a full-screen sheet. Apply or clear filters anytime.';
}
