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

List<String> suggestionKeysForCountry(String? countryCode) {
  // Same category set for all countries; language comes from app locale.
  return [...defaultSeedTagKeys, ...extraSuggestionKeys];
}

List<String> incomeSuggestionKeys() {
  return [...defaultSeedIncomeTagKeys, ...extraIncomeSuggestionKeys];
}
