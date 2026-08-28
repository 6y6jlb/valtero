import 'package:flutter/material.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/tag_label.dart';

String localizedPaymentMethodLabel(
  BuildContext context,
  PaymentMethod method,
) {
  final l10n = AppLocalizations.of(context)!;
  final key = method.stableKey;
  if (key != null && key.isNotEmpty) {
    final fromKey = tagLabelForKey(
      l10n,
      key,
      languageCode: Localizations.localeOf(context).languageCode,
    );
    // tagLabelForKey returns the raw key when unknown — keep name then.
    if (fromKey != key) return fromKey;
  }
  return method.name;
}
