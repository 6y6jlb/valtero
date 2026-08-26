import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/manage_tags/model/manage_tags_controller.dart';
import 'package:valtero/features/tag_suggestions/model/country_detection.dart';
import 'package:valtero/features/tag_suggestions/ui/suggested_tags_section.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

class TagsSettingsPage extends ConsumerWidget {
  const TagsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final settings = ref.watch(appSettingsProvider).value;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.tagsTitle, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.country),
          subtitle: Text(
            [
              settings?.detectedCountryCode ?? '—',
              if (settings?.detectedCurrency != null) settings!.detectedCurrency!,
            ].join(' / '),
          ),
          trailing: TextButton(
            onPressed: () async {
              await ref.read(detectCountryControllerProvider)();
            },
            child: Text(l10n.detectCountry),
          ),
        ),
        const SuggestedTagsSection(),
        const SizedBox(height: 16),
        Text(l10n.defaultTags, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final tag in tags)
          ListTile(
            title: Text(tag.name),
            subtitle: tag.isDefault ? Text(l10n.defaultTags) : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                ref.read(manageTagsControllerProvider).deleteTag(tag.id);
              },
            ),
            onTap: () async {
              final controller = TextEditingController(text: tag.name);
              final name = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.tag),
                  content: TextField(controller: controller),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, controller.text),
                      child: Text(l10n.save),
                    ),
                  ],
                ),
              );
              if (name != null) {
                await ref.read(manageTagsControllerProvider).renameTag(tag, name);
              }
            },
          ),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: () async {
            final controller = TextEditingController();
            final name = await showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.newTag),
                content: TextField(controller: controller),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, controller.text),
                    child: Text(l10n.add),
                  ),
                ],
              ),
            );
            if (name != null) {
              await ref.read(manageTagsControllerProvider).addTag(name);
            }
          },
          child: Text(l10n.addTag),
        ),
      ],
    );
  }
}
