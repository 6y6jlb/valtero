import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/manage_tags/model/manage_tags_controller.dart';
import 'package:valtero/features/tag_suggestions/model/suggested_tags_provider.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

class SuggestedTagsSection extends ConsumerWidget {
  const SuggestedTagsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final suggestions = ref.watch(suggestedTagNamesProvider);
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
            for (final name in suggestions)
              InputChip(
                label: Text(name),
                onPressed: () async {
                  await ref.read(manageTagsControllerProvider).addTag(name);
                },
                onDeleted: () {
                  ref.read(appSettingsProvider.notifier).dismissTagSuggestion(name);
                },
                tooltip: l10n.dismiss,
              ),
          ],
        ),
      ],
    );
  }
}
