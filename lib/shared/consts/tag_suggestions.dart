/// Stable suggestion keys (localized via AppLocalizations / [tagLabelForKey]).
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

/// Payment / funding source tags seeded for every install.
const List<String> resourceSeedTagKeys = [
  'cash',
  'card',
  'crypto',
  'transfer',
  'ewallet',
];

/// Extra suggestion keys shown for any country (beyond seeds).
const List<String> extraSuggestionKeys = [
  'utilities',
];

String tripStableKey(String currencyCode) => 'trip_${currencyCode.toUpperCase()}';

bool isTripStableKey(String? key) => key != null && key.startsWith('trip_');

bool isResourceStableKey(String? key) =>
    key != null && resourceSeedTagKeys.contains(key);

String? currencyFromTripKey(String key) {
  if (!isTripStableKey(key)) return null;
  return key.substring('trip_'.length);
}

List<String> suggestionKeysForCountry(String? countryCode) {
  // Same category set for all countries; language comes from app locale, not country.
  return [...defaultSeedTagKeys, ...extraSuggestionKeys];
}
