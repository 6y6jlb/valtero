class CurrencyInfo {
  final String code;
  final String name;
  final int fractionDigits;

  const CurrencyInfo(this.code, this.name, {this.fractionDigits = 2});
}

/// Common ISO currencies used by the app.
const List<CurrencyInfo> supportedCurrencies = [
  CurrencyInfo('RUB', 'Russian Ruble'),
  CurrencyInfo('USD', 'US Dollar'),
  CurrencyInfo('EUR', 'Euro'),
  CurrencyInfo('GBP', 'British Pound'),
  CurrencyInfo('CNY', 'Chinese Yuan'),
  CurrencyInfo('JPY', 'Japanese Yen', fractionDigits: 0),
  CurrencyInfo('PLN', 'Polish Zloty'),
  CurrencyInfo('TRY', 'Turkish Lira'),
  CurrencyInfo('KZT', 'Kazakhstani Tenge'),
  CurrencyInfo('UAH', 'Ukrainian Hryvnia'),
  CurrencyInfo('BYN', 'Belarusian Ruble'),
  CurrencyInfo('CHF', 'Swiss Franc'),
  CurrencyInfo('CAD', 'Canadian Dollar'),
  CurrencyInfo('AUD', 'Australian Dollar'),
  CurrencyInfo('SEK', 'Swedish Krona'),
  CurrencyInfo('NOK', 'Norwegian Krone'),
  CurrencyInfo('CZK', 'Czech Koruna'),
  CurrencyInfo('HUF', 'Hungarian Forint', fractionDigits: 0),
  CurrencyInfo('INR', 'Indian Rupee'),
  CurrencyInfo('BRL', 'Brazilian Real'),
];

CurrencyInfo? currencyByCode(String code) {
  final upper = code.toUpperCase();
  for (final c in supportedCurrencies) {
    if (c.code == upper) return c;
  }
  return null;
}

List<String> get supportedCurrencyCodes =>
    supportedCurrencies.map((c) => c.code).toList(growable: false);
