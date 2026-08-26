import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/shared/consts/tag_suggestions.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

/// Suggested tags as stable keys (not localized display strings).
final suggestedTagKeysProvider = Provider<List<String>>((ref) {
  final settings = ref.watch(appSettingsProvider).value;
  final tags = ref.watch(tagsStreamProvider).value ?? const [];
  final expenses = ref.watch(allExpensesProvider).value ?? const [];
  final existingKeys = tags
      .map((t) => t.stableKey)
      .whereType<String>()
      .map((k) => k.toLowerCase())
      .toSet();
  final dismissed =
      (settings?.dismissedTagSuggestions ?? const []).map((e) => e.toLowerCase()).toSet();

  final suggestions = <String>{};
  suggestions.addAll(suggestionKeysForCountry(settings?.detectedCountryCode));

  final reporting = (settings?.reportingCurrencies ?? const []).toSet();
  for (final expense in expenses) {
    final code = expense.originalCurrencyCode;
    if (!reporting.contains(code)) {
      suggestions.add(tripStableKey(code));
    }
  }

  return suggestions
      .where(
        (key) =>
            !existingKeys.contains(key.toLowerCase()) &&
            !dismissed.contains(key.toLowerCase()),
      )
      .toList()
    ..sort();
});
