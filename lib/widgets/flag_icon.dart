import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/currency_label.dart';

/// Circular ISO flag for a country or currency code.
///
/// Unknown codes use a muted help icon + tooltip instead of the package's
/// white question-mark placeholder.
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
    final codeLabel = (currencyCode ?? countryCode)?.trim().toUpperCase() ?? '';
    final flagCode = _resolveFlagCode();
    if (flagCode == null) {
      if (codeLabel.isEmpty) {
        return SizedBox(width: size, height: size);
      }
      return _UnknownFlagIcon(code: codeLabel, size: size);
    }

    final theme = ImageTheme(
      width: size,
      height: size,
      shape: const Circle(),
    );
    final Widget flag;
    if (countryCode != null && countryCode!.isNotEmpty) {
      flag = CountryFlag.fromCountryCode(countryCode!, theme: theme);
    } else {
      flag = CountryFlag.fromCurrencyCode(currencyCode!, theme: theme);
    }
    return SizedBox(width: size, height: size, child: flag);
  }

  String? _resolveFlagCode() {
    final country = countryCode?.trim();
    if (country != null && country.isNotEmpty) {
      return FlagCode.fromCountryCode(country);
    }
    final currency = currencyCode?.trim();
    if (currency != null && currency.isNotEmpty) {
      return FlagCode.fromCurrencyCode(currency);
    }
    return null;
  }
}

class _UnknownFlagIcon extends StatelessWidget {
  final String code;
  final double size;

  const _UnknownFlagIcon({required this.code, required this.size});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final icon = Icon(
      Icons.help_outline,
      size: size * 0.85,
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
    );
    return SizedBox(
      width: size,
      height: size,
      child: Tooltip(
        message: l10n?.flagUnavailableTooltip(code) ?? 'No flag for $code',
        child: Center(child: icon),
      ),
    );
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
