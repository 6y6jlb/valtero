/// ISO country codes → display names by language (`en` / `ru`).
const Map<String, Map<String, String>> _countryNames = {
  'en': {
    'RU': 'Russia',
    'US': 'United States',
    'GB': 'United Kingdom',
    'DE': 'Germany',
    'FR': 'France',
    'IT': 'Italy',
    'ES': 'Spain',
    'PL': 'Poland',
    'TR': 'Turkey',
    'KZ': 'Kazakhstan',
    'UA': 'Ukraine',
    'BY': 'Belarus',
    'CN': 'China',
    'JP': 'Japan',
    'KR': 'South Korea',
    'IN': 'India',
    'BR': 'Brazil',
    'CA': 'Canada',
    'AU': 'Australia',
    'CH': 'Switzerland',
    'SE': 'Sweden',
    'NO': 'Norway',
    'FI': 'Finland',
    'CZ': 'Czechia',
    'HU': 'Hungary',
    'AT': 'Austria',
    'NL': 'Netherlands',
    'BE': 'Belgium',
    'PT': 'Portugal',
    'GR': 'Greece',
    'IE': 'Ireland',
    'AE': 'United Arab Emirates',
    'TH': 'Thailand',
    'VN': 'Vietnam',
    'ID': 'Indonesia',
    'MY': 'Malaysia',
    'SG': 'Singapore',
    'GE': 'Georgia',
    'AM': 'Armenia',
    'AZ': 'Azerbaijan',
    'UZ': 'Uzbekistan',
    'EG': 'Egypt',
    'IL': 'Israel',
    'MX': 'Mexico',
    'AR': 'Argentina',
  },
  'ru': {
    'RU': 'Россия',
    'US': 'США',
    'GB': 'Великобритания',
    'DE': 'Германия',
    'FR': 'Франция',
    'IT': 'Италия',
    'ES': 'Испания',
    'PL': 'Польша',
    'TR': 'Турция',
    'KZ': 'Казахстан',
    'UA': 'Украина',
    'BY': 'Беларусь',
    'CN': 'Китай',
    'JP': 'Япония',
    'KR': 'Южная Корея',
    'IN': 'Индия',
    'BR': 'Бразилия',
    'CA': 'Канада',
    'AU': 'Австралия',
    'CH': 'Швейцария',
    'SE': 'Швеция',
    'NO': 'Норвегия',
    'FI': 'Финляндия',
    'CZ': 'Чехия',
    'HU': 'Венгрия',
    'AT': 'Австрия',
    'NL': 'Нидерланды',
    'BE': 'Бельгия',
    'PT': 'Португалия',
    'GR': 'Греция',
    'IE': 'Ирландия',
    'AE': 'ОАЭ',
    'TH': 'Таиланд',
    'VN': 'Вьетнам',
    'ID': 'Индонезия',
    'MY': 'Малайзия',
    'SG': 'Сингапур',
    'GE': 'Грузия',
    'AM': 'Армения',
    'AZ': 'Азербайджан',
    'UZ': 'Узбекистан',
    'EG': 'Египет',
    'IL': 'Израиль',
    'MX': 'Мексика',
    'AR': 'Аргентина',
  },
};

String _lang(String? languageCode) {
  if (languageCode == 'ru') return 'ru';
  return 'en';
}

String countryDisplayName(String code, {String? languageCode}) {
  final upper = code.toUpperCase();
  final lang = _lang(languageCode);
  return _countryNames[lang]?[upper] ??
      _countryNames['en']?[upper] ??
      upper;
}

List<MapEntry<String, String>> sortedCountries({String? languageCode}) {
  final lang = _lang(languageCode);
  final map = _countryNames[lang] ?? _countryNames['en']!;
  final entries = map.entries.toList()
    ..sort((a, b) => a.value.compareTo(b.value));
  return entries;
}

/// Currency → country/region code used for trip-tag labeling.
const Map<String, String> currencyRegionCode = {
  'RUB': 'RU',
  'USD': 'US',
  'EUR': 'EU',
  'GBP': 'GB',
  'CNY': 'CN',
  'JPY': 'JP',
  'PLN': 'PL',
  'TRY': 'TR',
  'KZT': 'KZ',
  'UAH': 'UA',
  'BYN': 'BY',
  'CHF': 'CH',
  'CAD': 'CA',
  'AUD': 'AU',
  'SEK': 'SE',
  'NOK': 'NO',
  'CZK': 'CZ',
  'HUF': 'HU',
  'INR': 'IN',
  'BRL': 'BR',
};

String regionLabelForCurrency(String currencyCode, {String? languageCode}) {
  final code = currencyRegionCode[currencyCode.toUpperCase()];
  if (code == null) return currencyCode.toUpperCase();
  if (code == 'EU') {
    return languageCode == 'ru' ? 'Еврозона' : 'Eurozone';
  }
  return countryDisplayName(code, languageCode: languageCode);
}
