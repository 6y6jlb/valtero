import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/manage_tags/model/manage_tags_controller.dart';
import 'package:valtero/features/tag_suggestions/model/suggested_tags_provider.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/tag_label.dart';

class SuggestedTagsSection extends ConsumerWidget {
  const SuggestedTagsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final suggestions = ref.watch(suggestedTagKeysProvider);
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.suggestedTags, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final key in suggestions)
              InputChip(
                label: Text(tagLabelForKey(l10n, key, languageCode: lang)),
                onPressed: () async {
                  await ref.read(manageTagsControllerProvider).addTag(
                        tagLabelForKey(l10n, key, languageCode: lang),
                        stableKey: key,
                        kind: 'normal',
                      );
                },
                onDeleted: () {
                  ref.read(appSettingsProvider.notifier).dismissTagSuggestion(key);
                },
                tooltip: l10n.dismiss,
              ),
          ],
        ),
      ],
    );
  }
}
