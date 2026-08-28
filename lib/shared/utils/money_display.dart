import 'package:intl/intl.dart';
import 'package:valtero/shared/utils/money.dart';

/// How amounts are shown in the UI (storage stays integer minor units).
enum MoneyDisplayFormat {
  /// Locale-aware with currency symbol when known (`$1,234.56`, `1 234,56 ₽`).
  localeSymbol,

  /// Locale-aware decimals + ISO code (`1,234.56 USD`).
  localeCode,

  /// Fixed machine-like decimals + ISO code (`1234.56 USD`).
  plain,
}

MoneyDisplayFormat moneyDisplayFormatFromName(String? name) {
  return MoneyDisplayFormat.values.firstWhere(
    (f) => f.name == name,
    orElse: () => MoneyDisplayFormat.localeCode,
  );
}

/// Formats [amountMinor] for on-screen display via `intl` (or plain).
///
/// Export / interchange should keep using [Money.formatMinor] (dot decimals,
/// no grouping) so files stay stable across locales.
String formatMoneyDisplay({
  required int amountMinor,
  required String currencyCode,
  required String localeName,
  required MoneyDisplayFormat format,
  int fractionDigits = 2,
}) {
  final code = currencyCode.toUpperCase();
  final major = amountMinor / Money.pow10(fractionDigits);

  switch (format) {
    case MoneyDisplayFormat.localeSymbol:
      try {
        return NumberFormat.currency(
          locale: localeName,
          name: code,
          decimalDigits: fractionDigits,
        ).format(major);
      } catch (_) {
        return formatMoneyDisplay(
          amountMinor: amountMinor,
          currencyCode: code,
          localeName: localeName,
          format: MoneyDisplayFormat.localeCode,
          fractionDigits: fractionDigits,
        );
      }
    case MoneyDisplayFormat.localeCode:
      final number = NumberFormat.decimalPatternDigits(
        locale: localeName,
        decimalDigits: fractionDigits,
      ).format(major);
      return '$number $code';
    case MoneyDisplayFormat.plain:
      return '${Money.formatMinor(amountMinor, fractionDigits: fractionDigits)} $code';
  }
}
