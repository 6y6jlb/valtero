/// Seeded category keys (localized via AppLocalizations / [tagLabelForKey]).
const List<String> defaultSeedTagKeys = [
  'groceries',
  'transport',
  'housing',
  'dining',
  'health',
  'entertainment',
  'shopping',
  'travel',
];

/// Extra suggestion keys shown beyond seeds.
const List<String> extraSuggestionKeys = [
  'utilities',
];

/// Seeded income source keys (localized via AppLocalizations / [tagLabelForKey]).
const List<String> defaultSeedIncomeTagKeys = [
  'salary',
  'sale',
  'gift',
  'refund',
  'investment',
  'other_income',
];

/// Extra income suggestion keys shown beyond seeds.
const List<String> extraIncomeSuggestionKeys = [];

/// Default subcategories keyed by parent category [stableKey] (expense).
const Map<String, List<String>> defaultSeedSubtagKeysByCategory = {
  'groceries': [
    'household_supplies',
    'alcohol',
    'snacks',
    'pet_food',
    'baby_food',
  ],
  'transport': [
    'fuel',
    'repair',
    'tuning',
    'parking',
    'taxi',
    'public_transit',
  ],
  'housing': [
    'rent',
    'utilities_bill',
    'furniture',
    'dacha',
    'home_repairs',
    'cleaning',
    'internet',
  ],
  'dining': ['restaurant', 'cafe', 'delivery'],
  'health': ['lab_tests', 'doctor', 'medications', 'dentistry', 'optics'],
  'entertainment': ['cinema', 'games', 'streaming', 'events', 'hobbies'],
  'shopping': [
    'clothing',
    'electronics',
    'gifts_shopping',
    'home_goods',
    'beauty',
  ],
  'travel': ['flights', 'hotels', 'tours', 'travel_insurance', 'visas'],
};

/// Default subcategories keyed by parent category [stableKey] (income).
const Map<String, List<String>> defaultSeedIncomeSubtagKeysByCategory = {
  'salary': ['bonus', 'overtime', 'advance'],
  'sale': ['personal_items', 'property_sale', 'vehicle_sale'],
  'gift': ['family_gift', 'friends_gift', 'holiday_gift'],
  'refund': ['tax_refund', 'purchase_refund', 'insurance_refund'],
  'investment': ['dividends', 'interest_income', 'capital_gains'],
  'other_income': ['freelance', 'cashback', 'side_gig'],
};

List<String> suggestionKeysForCountry(String? countryCode) {
  // Same category set for all countries; language comes from app locale.
  return [...defaultSeedTagKeys, ...extraSuggestionKeys];
}

List<String> incomeSuggestionKeys() {
  return [...defaultSeedIncomeTagKeys, ...extraIncomeSuggestionKeys];
}
