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

List<String> suggestionKeysForCountry(String? countryCode) {
  // Same category set for all countries; language comes from app locale.
  return [...defaultSeedTagKeys, ...extraSuggestionKeys];
}
