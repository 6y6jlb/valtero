import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:valtero/shared/utils/currency_label.dart';

/// Circular ISO flag for a country or currency code.
class FlagIcon extends StatelessWidget {
  final String? countryCode;
  final String? currencyCode;
  final double size;

  const FlagIcon.country(
    this.countryCode, {
    super.key,
    this.size = 20,
  }) : currencyCode = null;

  const FlagIcon.currency(
    this.currencyCode, {
    super.key,
    this.size = 20,
  }) : countryCode = null;

  @override
  Widget build(BuildContext context) {
    final theme = ImageTheme(
      width: size,
      height: size,
      shape: const Circle(),
    );
    final Widget flag;
    if (countryCode != null && countryCode!.isNotEmpty) {
      flag = CountryFlag.fromCountryCode(countryCode!, theme: theme);
    } else if (currencyCode != null && currencyCode!.isNotEmpty) {
      flag = CountryFlag.fromCurrencyCode(currencyCode!, theme: theme);
    } else {
      return SizedBox(width: size, height: size);
    }
    return SizedBox(width: size, height: size, child: flag);
  }
}

/// Flag + localized `Name (CODE)` for dropdowns / list tiles.
class CurrencyCodeLabel extends StatelessWidget {
  final String code;
  final double flagSize;
  final bool compact;

  const CurrencyCodeLabel(
    this.code, {
    super.key,
    this.flagSize = 20,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final label = compact
        ? code.toUpperCase()
        : currencyDisplayLabel(code, languageCode: lang);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlagIcon.currency(code, size: flagSize),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
