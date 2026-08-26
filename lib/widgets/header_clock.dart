import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';

/// Live date + time in the configured timezone.
class HeaderClock extends ConsumerStatefulWidget {
  const HeaderClock({super.key});

  @override
  ConsumerState<HeaderClock> createState() => _HeaderClockState();
}

class _HeaderClockState extends ConsumerState<HeaderClock> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tzId =
        ref.watch(appSettingsProvider).value?.timeZoneId ?? kSystemTimeZoneId;
    final now = nowInTimeZone(tzId);
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.yMMMd(locale).format(now);
    final time = DateFormat.Hm(locale).format(now);
    final style = Theme.of(context).textTheme.titleSmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(date, style: style),
        Text(time, style: style?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
