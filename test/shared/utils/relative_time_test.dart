import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/shared/l10n/generated/app_localizations_en.dart';
import 'package:valtero/shared/utils/relative_time.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('formatRelativeTimeAgo returns just now for recent instant', () {
    final label = formatRelativeTimeAgo(DateTime.now(), l10n);
    expect(label, l10n.relativeTimeJustNow);
  });

  test('formatRelativeTimeAgo returns minutes for sub-hour delta', () {
    final label = formatRelativeTimeAgo(
      DateTime.now().subtract(const Duration(minutes: 12)),
      l10n,
    );
    expect(label, l10n.relativeTimeMinutesAgo(12));
  });
}
