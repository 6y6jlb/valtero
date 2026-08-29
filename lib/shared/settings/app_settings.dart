class AppSettings {
  final List<String> reportingCurrencies;
  final String primaryCurrency;
  final String? exchangeRateApiKey;
  final String activeRateProviderId;
  final DateTime? lastRateRefreshAt;
  final int? defaultTagId;
  final int? defaultPaymentMethodId;
  final String? detectedCountryCode;
  final String? detectedCurrency;
  final DateTime? countryDetectedAt;
  final String themeMode;
  final String locale;
  /// UI money layout: `localeSymbol` | `localeCode` | `plain`.
  final String moneyDisplayFormat;
  /// UI date layout: `localeMedium` | `isoYmd` | `dmy` | `mdy`.
  final String dateDisplayFormat;
  /// IANA id, or `'system'` to follow the device timezone.
  final String timeZoneId;
  /// User-defined currency codes (e.g. niche crypto).
  final List<String> customCurrencyCodes;
  final bool telegramEnabled;
  final String telegramBotToken;
  final String telegramChatId;
  final List<String> dismissedTagSuggestions;
  /// Persisted expenses page listing mode: `list` | `grouping` | `chart`.
  final String expensesListView;
  /// Persisted group-by when view is grouping: `currency` | `date` | `tag`.
  final String expensesListGroup;
  /// Persisted chart breakdown: `currency` | `tags` | `month` | `year`.
  final String expensesChartBreakdown;

  const AppSettings({
    required this.reportingCurrencies,
    required this.primaryCurrency,
    this.exchangeRateApiKey,
    this.activeRateProviderId = 'frankfurter',
    this.lastRateRefreshAt,
    this.defaultTagId,
    this.defaultPaymentMethodId,
    this.detectedCountryCode,
    this.detectedCurrency,
    this.countryDetectedAt,
    this.themeMode = 'system',
    this.locale = 'system',
    this.moneyDisplayFormat = 'localeCode',
    this.dateDisplayFormat = 'isoYmd',
    this.timeZoneId = 'system',
    this.customCurrencyCodes = const [],
    this.telegramEnabled = false,
    this.telegramBotToken = '',
    this.telegramChatId = '',
    this.dismissedTagSuggestions = const [],
    this.expensesListView = 'list',
    this.expensesListGroup = 'currency',
    this.expensesChartBreakdown = 'currency',
  });

  factory AppSettings.initial() {
    return const AppSettings(
      reportingCurrencies: ['RUB', 'USD'],
      primaryCurrency: 'RUB',
    );
  }

  AppSettings copyWith({
    List<String>? reportingCurrencies,
    String? primaryCurrency,
    String? exchangeRateApiKey,
    bool clearApiKey = false,
    String? activeRateProviderId,
    DateTime? lastRateRefreshAt,
    bool clearLastRateRefreshAt = false,
    int? defaultTagId,
    bool clearDefaultTagId = false,
    int? defaultPaymentMethodId,
    bool clearDefaultPaymentMethodId = false,
    String? detectedCountryCode,
    String? detectedCurrency,
    DateTime? countryDetectedAt,
    String? themeMode,
    String? locale,
    String? moneyDisplayFormat,
    String? dateDisplayFormat,
    String? timeZoneId,
    List<String>? customCurrencyCodes,
    bool? telegramEnabled,
    String? telegramBotToken,
    String? telegramChatId,
    List<String>? dismissedTagSuggestions,
    String? expensesListView,
    String? expensesListGroup,
    String? expensesChartBreakdown,
  }) {
    return AppSettings(
      reportingCurrencies: reportingCurrencies ?? this.reportingCurrencies,
      primaryCurrency: primaryCurrency ?? this.primaryCurrency,
      exchangeRateApiKey:
          clearApiKey ? null : (exchangeRateApiKey ?? this.exchangeRateApiKey),
      activeRateProviderId: activeRateProviderId ?? this.activeRateProviderId,
      lastRateRefreshAt: clearLastRateRefreshAt
          ? null
          : (lastRateRefreshAt ?? this.lastRateRefreshAt),
      defaultTagId: clearDefaultTagId ? null : (defaultTagId ?? this.defaultTagId),
      defaultPaymentMethodId: clearDefaultPaymentMethodId
          ? null
          : (defaultPaymentMethodId ?? this.defaultPaymentMethodId),
      detectedCountryCode: detectedCountryCode ?? this.detectedCountryCode,
      detectedCurrency: detectedCurrency ?? this.detectedCurrency,
      countryDetectedAt: countryDetectedAt ?? this.countryDetectedAt,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      moneyDisplayFormat: moneyDisplayFormat ?? this.moneyDisplayFormat,
      dateDisplayFormat: dateDisplayFormat ?? this.dateDisplayFormat,
      timeZoneId: timeZoneId ?? this.timeZoneId,
      customCurrencyCodes: customCurrencyCodes ?? this.customCurrencyCodes,
      telegramEnabled: telegramEnabled ?? this.telegramEnabled,
      telegramBotToken: telegramBotToken ?? this.telegramBotToken,
      telegramChatId: telegramChatId ?? this.telegramChatId,
      dismissedTagSuggestions:
          dismissedTagSuggestions ?? this.dismissedTagSuggestions,
      expensesListView: expensesListView ?? this.expensesListView,
      expensesListGroup: expensesListGroup ?? this.expensesListGroup,
      expensesChartBreakdown:
          expensesChartBreakdown ?? this.expensesChartBreakdown,
    );
  }

  Map<String, dynamic> toJson() => {
        'reportingCurrencies': reportingCurrencies,
        'primaryCurrency': primaryCurrency,
        'exchangeRateApiKey': exchangeRateApiKey,
        'activeRateProviderId': activeRateProviderId,
        'lastRateRefreshAt': lastRateRefreshAt?.toIso8601String(),
        'defaultTagId': defaultTagId,
        'defaultPaymentMethodId': defaultPaymentMethodId,
        'detectedCountryCode': detectedCountryCode,
        'detectedCurrency': detectedCurrency,
        'countryDetectedAt': countryDetectedAt?.toIso8601String(),
        'themeMode': themeMode,
        'locale': locale,
        'moneyDisplayFormat': moneyDisplayFormat,
        'dateDisplayFormat': dateDisplayFormat,
        'timeZoneId': timeZoneId,
        'customCurrencyCodes': customCurrencyCodes,
        'telegramEnabled': telegramEnabled,
        'telegramBotToken': telegramBotToken,
        'telegramChatId': telegramChatId,
        'dismissedTagSuggestions': dismissedTagSuggestions,
        'expensesListView': expensesListView,
        'expensesListGroup': expensesListGroup,
        'expensesChartBreakdown': expensesChartBreakdown,
      };

  factory AppSettings.fromJson(Map<dynamic, dynamic> json) {
    return AppSettings(
      reportingCurrencies: (json['reportingCurrencies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['RUB', 'USD'],
      primaryCurrency: json['primaryCurrency'] as String? ?? 'RUB',
      exchangeRateApiKey: json['exchangeRateApiKey'] as String?,
      activeRateProviderId: json['activeRateProviderId'] as String? ?? 'frankfurter',
      lastRateRefreshAt: json['lastRateRefreshAt'] != null
          ? DateTime.tryParse(json['lastRateRefreshAt'] as String)
          : null,
      defaultTagId: json['defaultTagId'] as int?,
      defaultPaymentMethodId: json['defaultPaymentMethodId'] as int?,
      detectedCountryCode: json['detectedCountryCode'] as String?,
      detectedCurrency: json['detectedCurrency'] as String?,
      countryDetectedAt: json['countryDetectedAt'] != null
          ? DateTime.tryParse(json['countryDetectedAt'] as String)
          : null,
      themeMode: json['themeMode'] as String? ?? 'system',
      locale: json['locale'] as String? ?? 'system',
      moneyDisplayFormat: json['moneyDisplayFormat'] as String? ?? 'localeCode',
      dateDisplayFormat: json['dateDisplayFormat'] as String? ?? 'isoYmd',
      timeZoneId: json['timeZoneId'] as String? ?? 'system',
      customCurrencyCodes: (json['customCurrencyCodes'] as List<dynamic>?)
              ?.map((e) => e.toString().toUpperCase())
              .toList() ??
          const [],
      telegramEnabled: json['telegramEnabled'] as bool? ?? false,
      telegramBotToken: json['telegramBotToken'] as String? ?? '',
      telegramChatId: json['telegramChatId'] as String? ?? '',
      dismissedTagSuggestions: (json['dismissedTagSuggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      expensesListView: json['expensesListView'] as String? ?? 'list',
      expensesListGroup: json['expensesListGroup'] as String? ?? 'currency',
      expensesChartBreakdown:
          json['expensesChartBreakdown'] as String? ?? 'currency',
    );
  }
}
