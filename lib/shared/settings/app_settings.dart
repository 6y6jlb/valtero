class AppSettings {
  final List<String> reportingCurrencies;
  final String primaryCurrency;
  final String? exchangeRateApiKey;
  final String activeRateProviderId;
  final DateTime? lastRateRefreshAt;
  final int? defaultTagId;
  final String? detectedCountryCode;
  final String? detectedCurrency;
  final DateTime? countryDetectedAt;
  final String themeMode;
  final String locale;
  final bool telegramEnabled;
  final String telegramBotToken;
  final String telegramChatId;
  final List<String> dismissedTagSuggestions;

  const AppSettings({
    required this.reportingCurrencies,
    required this.primaryCurrency,
    this.exchangeRateApiKey,
    this.activeRateProviderId = 'frankfurter',
    this.lastRateRefreshAt,
    this.defaultTagId,
    this.detectedCountryCode,
    this.detectedCurrency,
    this.countryDetectedAt,
    this.themeMode = 'system',
    this.locale = 'system',
    this.telegramEnabled = false,
    this.telegramBotToken = '',
    this.telegramChatId = '',
    this.dismissedTagSuggestions = const [],
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
    String? detectedCountryCode,
    String? detectedCurrency,
    DateTime? countryDetectedAt,
    String? themeMode,
    String? locale,
    bool? telegramEnabled,
    String? telegramBotToken,
    String? telegramChatId,
    List<String>? dismissedTagSuggestions,
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
      detectedCountryCode: detectedCountryCode ?? this.detectedCountryCode,
      detectedCurrency: detectedCurrency ?? this.detectedCurrency,
      countryDetectedAt: countryDetectedAt ?? this.countryDetectedAt,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      telegramEnabled: telegramEnabled ?? this.telegramEnabled,
      telegramBotToken: telegramBotToken ?? this.telegramBotToken,
      telegramChatId: telegramChatId ?? this.telegramChatId,
      dismissedTagSuggestions:
          dismissedTagSuggestions ?? this.dismissedTagSuggestions,
    );
  }

  Map<String, dynamic> toJson() => {
        'reportingCurrencies': reportingCurrencies,
        'primaryCurrency': primaryCurrency,
        'exchangeRateApiKey': exchangeRateApiKey,
        'activeRateProviderId': activeRateProviderId,
        'lastRateRefreshAt': lastRateRefreshAt?.toIso8601String(),
        'defaultTagId': defaultTagId,
        'detectedCountryCode': detectedCountryCode,
        'detectedCurrency': detectedCurrency,
        'countryDetectedAt': countryDetectedAt?.toIso8601String(),
        'themeMode': themeMode,
        'locale': locale,
        'telegramEnabled': telegramEnabled,
        'telegramBotToken': telegramBotToken,
        'telegramChatId': telegramChatId,
        'dismissedTagSuggestions': dismissedTagSuggestions,
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
      detectedCountryCode: json['detectedCountryCode'] as String?,
      detectedCurrency: json['detectedCurrency'] as String?,
      countryDetectedAt: json['countryDetectedAt'] != null
          ? DateTime.tryParse(json['countryDetectedAt'] as String)
          : null,
      themeMode: json['themeMode'] as String? ?? 'system',
      locale: json['locale'] as String? ?? 'system',
      telegramEnabled: json['telegramEnabled'] as bool? ?? false,
      telegramBotToken: json['telegramBotToken'] as String? ?? '',
      telegramChatId: json['telegramChatId'] as String? ?? '',
      dismissedTagSuggestions: (json['dismissedTagSuggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
