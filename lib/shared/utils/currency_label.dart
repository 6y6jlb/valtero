import 'package:sealed_currencies/sealed_currencies.dart';
import 'package:valtero/shared/consts/currencies.dart';

/// Cached names per language (fiat via `sealed_currencies` l10n, crypto/custom
/// from the local catalog).
final Map<String, Map<String, String>> _namesByLang = {};

NaturalLanguage _languageFor(String languageCode) {
  return NaturalLanguage.maybeFromCodeShort(languageCode) ??
      const LangEng();
}

Map<String, String> _namesFor(String languageCode) {
  final lang = languageCode == 'ru' ? 'ru' : 'en';
  final cached = _namesByLang[lang];
  if (cached != null) return cached;

  final locale = BasicLocale(_languageFor(lang));
  final names = <String, String>{
    for (final c in cryptoCurrencies) c.code: c.name,
  };
  for (final fiat in FiatCurrency.list) {
    names[fiat.code] =
        fiat.maybeCommonNameFor(locale) ?? fiat.name;
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

  final fiat = FiatCurrency.maybeFromCode(upper);
  if (fiat != null) {
    final locale = BasicLocale(_languageFor(languageCode));
    final name = fiat.maybeCommonNameFor(locale) ?? fiat.name;
    names[upper] = name;
    return name;
  }

  final known = currencyByCode(upper, customCodes: customCodes);
  if (known != null) {
    names[upper] = known.name;
    return known.name;
  }
  return upper;
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
