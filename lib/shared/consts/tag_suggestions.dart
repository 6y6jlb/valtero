/// Suggested expense tags by ISO country code.
const Map<String, List<String>> countryTagSuggestions = {
  'RU': [
    'Продукты',
    'Транспорт',
    'Коммуналка',
    'Кафе и рестораны',
    'Здоровье',
    'Развлечения',
  ],
  'US': [
    'Groceries',
    'Transport',
    'Utilities',
    'Dining',
    'Health',
    'Entertainment',
  ],
  'GB': [
    'Groceries',
    'Transport',
    'Bills',
    'Eating out',
    'Health',
    'Leisure',
  ],
  'DE': [
    'Lebensmittel',
    'Transport',
    'Wohnen',
    'Restaurants',
    'Gesundheit',
    'Freizeit',
  ],
  'PL': [
    'Zakupy',
    'Transport',
    'Rachunki',
    'Jedzenie poza',
    'Zdrowie',
    'Rozrywka',
  ],
  'TR': [
    'Market',
    'Ulaşım',
    'Faturalar',
    'Yemek',
    'Sağlık',
    'Eğlence',
  ],
  'KZ': [
    'Продукты',
    'Транспорт',
    'Коммуналка',
    'Кафе',
    'Здоровье',
    'Развлечения',
  ],
};

/// Generic fallback suggestions (English keys; UI can show as-is).
const List<String> genericTagSuggestions = [
  'Groceries',
  'Transport',
  'Housing',
  'Dining',
  'Health',
  'Entertainment',
  'Shopping',
  'Travel',
];

/// Short region label for a currency — used for trip-tag suggestions.
const Map<String, String> currencyRegionLabel = {
  'RUB': 'Russia',
  'USD': 'USA',
  'EUR': 'Eurozone',
  'GBP': 'UK',
  'CNY': 'China',
  'JPY': 'Japan',
  'PLN': 'Poland',
  'TRY': 'Turkey',
  'KZT': 'Kazakhstan',
  'UAH': 'Ukraine',
  'BYN': 'Belarus',
  'CHF': 'Switzerland',
  'CAD': 'Canada',
  'AUD': 'Australia',
  'SEK': 'Sweden',
  'NOK': 'Norway',
  'CZK': 'Czechia',
  'HUF': 'Hungary',
  'INR': 'India',
  'BRL': 'Brazil',
};

List<String> suggestionsForCountry(String? countryCode) {
  if (countryCode == null || countryCode.isEmpty) {
    return List<String>.from(genericTagSuggestions);
  }
  return List<String>.from(
    countryTagSuggestions[countryCode.toUpperCase()] ?? genericTagSuggestions,
  );
}

String? tripTagForCurrency(String currencyCode) {
  final label = currencyRegionLabel[currencyCode.toUpperCase()];
  if (label == null) return null;
  return 'Trip: $label';
}
