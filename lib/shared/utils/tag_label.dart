import 'package:flutter/widgets.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

String tagLabelForKey(AppLocalizations l10n, String key, {String? languageCode}) {
  return switch (key) {
    'groceries' => l10n.tagGroceries,
    'transport' => l10n.tagTransport,
    'housing' => l10n.tagHousing,
    'dining' => l10n.tagDining,
    'health' => l10n.tagHealth,
    'entertainment' => l10n.tagEntertainment,
    'shopping' => l10n.tagShopping,
    'travel' => l10n.tagTravel,
    'utilities' => l10n.tagUtilities,
    'cash' => l10n.tagCash,
    'card' => l10n.tagCard,
    'crypto' => l10n.tagCrypto,
    'transfer' => l10n.tagTransfer,
    'ewallet' => l10n.tagEwallet,
    _ => key,
  };
}

String localizedTagLabel(BuildContext context, Tag tag) {
  final l10n = AppLocalizations.of(context)!;
  final lang = Localizations.localeOf(context).languageCode;
  final key = tag.stableKey;
  if (key != null && key.isNotEmpty) {
    return tagLabelForKey(l10n, key, languageCode: lang);
  }
  return tag.name;
}
