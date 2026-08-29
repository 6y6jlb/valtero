import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/date_display.dart';

class DateText extends ConsumerWidget {
  final DateTime instant;
  final TextStyle? style;

  const DateText({
    super.key,
    required this.instant,
    this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider).value;
    final format = dateDisplayFormatFromName(settings?.dateDisplayFormat);
    final tzId = settings?.timeZoneId ?? kSystemTimeZoneId;
    final localeName = Localizations.localeOf(context).toString();
    return Text(
      formatDateDisplay(
        instant: instant,
        timeZoneId: tzId,
        format: format,
        localeName: localeName,
      ),
      style: style,
    );
  }
}

/// Formats a date using the current app settings + widget locale.
String formatDateOf(
  BuildContext context,
  WidgetRef ref, {
  required DateTime instant,
}) {
  final settings = ref.watch(appSettingsProvider).value;
  return formatDateDisplay(
    instant: instant,
    timeZoneId: settings?.timeZoneId ?? kSystemTimeZoneId,
    format: dateDisplayFormatFromName(settings?.dateDisplayFormat),
    localeName: Localizations.localeOf(context).toString(),
  );
}
