import 'package:sealed_currencies/sealed_currencies.dart';

enum CurrencyKind { fiat, crypto, custom }

class CurrencyInfo {
  final String code;
  final String name;
  final int fractionDigits;
  final CurrencyKind kind;

  const CurrencyInfo(
    this.code,
    this.name, {
    this.fractionDigits = 2,
    this.kind = CurrencyKind.fiat,
  });
}

/// Popular crypto tickers (not ISO 4217). Rates are usually manual.
const List<CurrencyInfo> cryptoCurrencies = [
  CurrencyInfo('BTC', 'Bitcoin', fractionDigits: 8, kind: CurrencyKind.crypto),
  CurrencyInfo('ETH', 'Ethereum', fractionDigits: 8, kind: CurrencyKind.crypto),
  CurrencyInfo('USDT', 'Tether', kind: CurrencyKind.crypto),
  CurrencyInfo('USDC', 'USD Coin', kind: CurrencyKind.crypto),
  CurrencyInfo('BNB', 'BNB', fractionDigits: 8, kind: CurrencyKind.crypto),
  CurrencyInfo('XRP', 'XRP', fractionDigits: 6, kind: CurrencyKind.crypto),
  CurrencyInfo('SOL', 'Solana', fractionDigits: 8, kind: CurrencyKind.crypto),
  CurrencyInfo('ADA', 'Cardano', fractionDigits: 6, kind: CurrencyKind.crypto),
  CurrencyInfo('DOGE', 'Dogecoin', fractionDigits: 8, kind: CurrencyKind.crypto),
  CurrencyInfo('TRX', 'TRON', fractionDigits: 6, kind: CurrencyKind.crypto),
  CurrencyInfo('TON', 'Toncoin', fractionDigits: 8, kind: CurrencyKind.crypto),
  CurrencyInfo('DOT', 'Polkadot', fractionDigits: 8, kind: CurrencyKind.crypto),
  CurrencyInfo('LTC', 'Litecoin', fractionDigits: 8, kind: CurrencyKind.crypto),
  CurrencyInfo('BCH', 'Bitcoin Cash', fractionDigits: 8, kind: CurrencyKind.crypto),
  CurrencyInfo('LINK', 'Chainlink', fractionDigits: 8, kind: CurrencyKind.crypto),
];

List<CurrencyInfo> _fiatFromSealed() {
  return [
    for (final c in FiatCurrency.list)
      CurrencyInfo(
        c.code,
        c.name,
        fractionDigits: _fractionDigitsFromSubunit(c.subunitToUnit),
      ),
  ]..sort((a, b) => a.code.compareTo(b.code));
}

int _fractionDigitsFromSubunit(int subunitToUnit) {
  if (subunitToUnit <= 1) return 0;
  var n = 0;
  var v = subunitToUnit;
  while (v > 1 && v % 10 == 0) {
    v ~/= 10;
    n++;
  }
  return n == 0 ? 2 : n;
}

final List<CurrencyInfo> _fiatCurrencies = _fiatFromSealed();

List<CurrencyInfo> get fiatCurrencies => _fiatCurrencies;

/// All built-in fiat + crypto (custom codes are merged by callers via settings).
List<CurrencyInfo> get builtInCurrencies => [
      ..._fiatCurrencies,
      ...cryptoCurrencies,
    ];

CurrencyInfo? currencyByCode(
  String code, {
  List<String> customCodes = const [],
}) {
  final upper = code.toUpperCase();
  for (final c in cryptoCurrencies) {
    if (c.code == upper) return c;
  }
  for (final c in _fiatCurrencies) {
    if (c.code == upper) return c;
  }
  if (customCodes.map((e) => e.toUpperCase()).contains(upper)) {
    return CurrencyInfo(upper, upper, kind: CurrencyKind.custom);
  }
  return null;
}

List<CurrencyInfo> currenciesCatalog({List<String> customCodes = const []}) {
  final custom = [
    for (final code in customCodes)
      if (currencyByCode(code) == null)
        CurrencyInfo(code.toUpperCase(), code.toUpperCase(),
            kind: CurrencyKind.custom),
  ]..sort((a, b) => a.code.compareTo(b.code));
  return [...builtInCurrencies, ...custom];
}

List<String> currencyCodesCatalog({List<String> customCodes = const []}) =>
    currenciesCatalog(customCodes: customCodes)
        .map((c) => c.code)
        .toList(growable: false);

/// Backward-compatible alias used across the app.
List<String> get supportedCurrencyCodes => currencyCodesCatalog();

List<CurrencyInfo> get supportedCurrencies => builtInCurrencies;
