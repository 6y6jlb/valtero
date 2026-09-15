import 'package:intl/intl.dart';
import 'package:valtero/shared/utils/currency_symbol.dart';
import 'package:valtero/shared/utils/money.dart';

/// How amounts are shown in the UI (storage stays integer minor units).
enum MoneyDisplayFormat {
  /// Locale-aware with currency symbol when known (`$1,234.56`, `1 234,56 ₽`).
  localeSymbol,

  /// Locale-aware decimals + currency glyph or ISO (`1,234.56 $`, `1 234,56 ₽`).
  localeCode,

  /// Glyph/ISO before amount (`$ 1,234.56`, `₽ 1 234,56`).
  isoBefore,

  /// Fixed machine-like decimals + ISO code (`1234.56 USD`).
  plain,

  /// Compact currency (`$1.2K`, `₽1.2K`).
  compactSymbol,
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

  /// When true, never show fraction digits (e.g. chart totals: `$20,000`
  /// instead of `$20,000.00`). Does not change [amountMinor]'s conversion
  /// scale — only how many decimals are rendered.
  bool hideFraction = false,
}) {
  final code = currencyCode.toUpperCase();
  final major = amountMinor / Money.pow10(fractionDigits);
  final displayDigits = hideFraction ? 0 : fractionDigits;
  final glyph = currencySymbolFor(code);

  switch (format) {
    case MoneyDisplayFormat.localeSymbol:
      try {
        return NumberFormat.currency(
          locale: localeName,
          name: code,
          symbol: glyph,
          decimalDigits: displayDigits,
        ).format(major);
      } catch (_) {
        return formatMoneyDisplay(
          amountMinor: amountMinor,
          currencyCode: code,
          localeName: localeName,
          format: MoneyDisplayFormat.localeCode,
          fractionDigits: fractionDigits,
          hideFraction: hideFraction,
        );
      }
    case MoneyDisplayFormat.localeCode:
      final number = NumberFormat.decimalPatternDigits(
        locale: localeName,
        decimalDigits: displayDigits,
      ).format(major);
      return '$number $glyph';
    case MoneyDisplayFormat.isoBefore:
      final number = NumberFormat.decimalPatternDigits(
        locale: localeName,
        decimalDigits: displayDigits,
      ).format(major);
      return '$glyph $number';
    case MoneyDisplayFormat.plain:
      if (hideFraction) {
        return '${major.round()} $code';
      }
      return '${Money.formatMinor(amountMinor, fractionDigits: fractionDigits)} $code';
    case MoneyDisplayFormat.compactSymbol:
      try {
        return NumberFormat.compactCurrency(
          locale: localeName,
          name: code,
          symbol: glyph,
          decimalDigits: hideFraction ? 0 : 1,
        ).format(major);
      } catch (_) {
        return formatMoneyDisplay(
          amountMinor: amountMinor,
          currencyCode: code,
          localeName: localeName,
          format: MoneyDisplayFormat.localeCode,
          fractionDigits: fractionDigits,
          hideFraction: hideFraction,
        );
      }
  }
}
