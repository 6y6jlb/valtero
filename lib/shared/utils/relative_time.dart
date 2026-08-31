import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// User-facing “how long ago” label for a past [instant] (local wall clock).
String formatRelativeTimeAgo(DateTime instant, AppLocalizations l10n) {
  final diff = DateTime.now().difference(instant.toLocal());
  if (diff.isNegative || diff.inMinutes < 1) {
    return l10n.relativeTimeJustNow;
  }
  if (diff.inMinutes < 60) {
    return l10n.relativeTimeMinutesAgo(diff.inMinutes);
  }
  if (diff.inHours < 24) {
    return l10n.relativeTimeHoursAgo(diff.inHours);
  }
  if (diff.inDays < 14) {
    return l10n.relativeTimeDaysAgo(diff.inDays);
  }
  return l10n.googleDriveLastSynced(instant.toLocal().toString());
}
