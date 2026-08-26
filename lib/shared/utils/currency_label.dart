import 'package:l10n_currencies/l10n_currencies.dart';
import 'package:valtero/shared/consts/currencies.dart';

/// Cached names per language. `CurrenciesLocaleMapper` is single-use after
/// [CurrenciesLocaleMapper.localize], so we materialize maps once.
final Map<String, Map<String, String>> _namesByLang = {};

Map<String, String> _namesFor(String languageCode) {
  final lang = languageCode == 'ru' ? 'ru' : 'en';
  final cached = _namesByLang[lang];
  if (cached != null) return cached;

  final fiatCodes = fiatCurrencies.map((c) => c.code).toSet();
  final mapper = CurrenciesLocaleMapper();
  final localized = mapper.localize(
    fiatCodes,
    mainLocale: lang,
    fallbackLocale: 'en',
  );
  final names = <String, String>{
    for (final c in cryptoCurrencies) c.code: c.name,
  };
  for (final entry in localized.entries) {
    if (entry.key.locale == lang || !names.containsKey(entry.key.isoCode)) {
      names[entry.key.isoCode] = entry.value;
    }
  }
  return _namesByLang[lang] = names;
}

/// Localized currency name, e.g. `Доллар США` / `US Dollar`.
String localizedCurrencyName(
  String code, {
  required String languageCode,
  List<String> customCodes = const [],
}) {
  final upper = code.toUpperCase();
  final names = _namesFor(languageCode);
  final cached = names[upper];
  if (cached != null) return cached;

  final known = currencyByCode(upper, customCodes: customCodes);
  if (known != null && known.kind != CurrencyKind.fiat) {
    names[upper] = known.name;
    return known.name;
  }

  final lang = languageCode == 'ru' ? 'ru' : 'en';
  final mapper = CurrenciesLocaleMapper();
  final localized = mapper.localize(
    {upper},
    mainLocale: lang,
    fallbackLocale: 'en',
  );
  for (final entry in localized.entries) {
    if (entry.key.isoCode == upper) {
      names[upper] = entry.value;
      return entry.value;
    }
  }
  return known?.name ?? upper;
}

/// Display label: `US Dollar (USD)`.
String currencyDisplayLabel(
  String code, {
  required String languageCode,
  List<String> customCodes = const [],
}) {
  final upper = code.toUpperCase();
  final name = localizedCurrencyName(
    upper,
    languageCode: languageCode,
    customCodes: customCodes,
  );
  return '$name ($upper)';
}
