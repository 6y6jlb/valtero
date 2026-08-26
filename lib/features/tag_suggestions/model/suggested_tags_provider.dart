import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/expense/model/expenses_provider.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/shared/consts/tag_suggestions.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

final suggestedTagNamesProvider = Provider<List<String>>((ref) {
  final settings = ref.watch(appSettingsProvider).value;
  final tags = ref.watch(tagsStreamProvider).value ?? const [];
  final expenses = ref.watch(allExpensesProvider).value ?? const [];
  final existing = tags.map((t) => t.name.toLowerCase()).toSet();
  final dismissed =
      (settings?.dismissedTagSuggestions ?? const []).map((e) => e.toLowerCase()).toSet();

  final suggestions = <String>{};
  suggestions.addAll(suggestionsForCountry(settings?.detectedCountryCode));

  final reporting = (settings?.reportingCurrencies ?? const []).toSet();
  for (final expense in expenses) {
    final code = expense.originalCurrencyCode;
    if (!reporting.contains(code)) {
      final trip = tripTagForCurrency(code);
      if (trip != null) suggestions.add(trip);
    }
  }

  return suggestions
      .where(
        (name) =>
            !existing.contains(name.toLowerCase()) &&
            !dismissed.contains(name.toLowerCase()),
      )
      .toList()
    ..sort();
});
