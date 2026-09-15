import 'package:sealed_currencies/sealed_currencies.dart';

/// Display glyph for a currency code (`₽`, `$`, `€`), or the ISO code when no
/// well-known symbol exists (crypto / custom / unknown).
///
/// Prefer this over locale-dependent `intl` symbols so RUB stays `₽` even under
/// `en_US` (where `NumberFormat.currency(name: 'RUB')` often prints `RUB`).
String currencySymbolFor(String code) {
  final upper = code.trim().toUpperCase();
  if (upper.isEmpty) return upper;

  final fiat = FiatCurrency.maybeFromCode(upper);
  final symbol = fiat?.symbol?.trim();
  if (symbol != null && symbol.isNotEmpty) return symbol;

  // Explicit fallbacks for codes sealed_currencies may omit or leave blank.
  const extras = <String, String>{
    'RUB': '₽',
    'USD': r'$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CNY': '¥',
    'UAH': '₴',
    'KZT': '₸',
    'TRY': '₺',
    'INR': '₹',
    'KRW': '₩',
  };
  return extras[upper] ?? upper;
}

/// Whether [currencySymbolFor] returns a non-ISO glyph for [code].
bool hasCurrencySymbol(String code) {
  final upper = code.trim().toUpperCase();
  if (upper.isEmpty) return false;
  return currencySymbolFor(upper) != upper;
}
