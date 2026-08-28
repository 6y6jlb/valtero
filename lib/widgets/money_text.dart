import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/money_display.dart';

class MoneyText extends ConsumerWidget {
  final int amountMinor;
  final String currencyCode;
  final TextStyle? style;

  const MoneyText({
    super.key,
    required this.amountMinor,
    required this.currencyCode,
    this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider).value;
    final format = moneyDisplayFormatFromName(settings?.moneyDisplayFormat);
    final localeName = Localizations.localeOf(context).toString();
    return Text(
      formatMoneyDisplay(
        amountMinor: amountMinor,
        currencyCode: currencyCode,
        localeName: localeName,
        format: format,
      ),
      style: style,
    );
  }
}

/// Formats money using the current app settings + widget locale.
String formatMoneyOf(
  BuildContext context,
  WidgetRef ref, {
  required int amountMinor,
  required String currencyCode,
}) {
  final settings = ref.watch(appSettingsProvider).value;
  return formatMoneyDisplay(
    amountMinor: amountMinor,
    currencyCode: currencyCode,
    localeName: Localizations.localeOf(context).toString(),
    format: moneyDisplayFormatFromName(settings?.moneyDisplayFormat),
  );
}
