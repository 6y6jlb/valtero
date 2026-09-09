import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/manage_tags/model/manage_tags_controller.dart';
import 'package:valtero/features/tag_suggestions/model/country_detection.dart';
import 'package:valtero/features/tag_suggestions/ui/suggested_tags_section.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/consts/tag_icons.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';
import 'package:valtero/widgets/bookmark_tabs.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/tag_color_picker.dart';

Future<void> showTagsSheet(BuildContext context) {
  return showAppModalSheet(
    context: context,
    child: const TagsSheetBody(),
  );
}

/// Page-layer composition: manage tags + country detection suggestions.
class TagsSheetBody extends ConsumerStatefulWidget {
  const TagsSheetBody({super.key});

  @override
  ConsumerState<TagsSheetBody> createState() => _TagsSheetBodyState();
}

class _TagsSheetBodyState extends ConsumerState<TagsSheetBody> {
  TagKind _selectedKind = TagKind.custom;

  Future<void> _addTagForKind(TagKind kind) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showTagEditDialog(
      context,
      title: l10n.newTag,
      confirmLabel: l10n.add,
    );
    if (result == null) return;
    await ref.read(manageTagsControllerProvider).addTag(
          result.name,
          colorValue: result.colorValue,
          iconKey: result.iconKey,
          kind: tagKindDbValue(kind),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final tags = ref.watch(tagsStreamProvider).value ?? const [];
    final grouped = groupTagsByKind(tags);
    final settings = ref.watch(appSettingsProvider).value;
    final countryLabel = settings?.detectedCountryCode == null
        ? '—'
        : countryDisplayName(
            settings!.detectedCountryCode!,
            languageCode: lang,
          );
    final kindTags = grouped[_selectedKind] ?? const [];

    return AppSheetScaffold(
      header: AppSheetHeader(title: l10n.tagsTitle),
      actions: AppSheetActionsBar(
        children: [
          const AppCloseIconButton(),
          AppFilledButton.tonal(
            label: l10n.addTag,
            icon: Icons.add,
            onPressed: () => _addTagForKind(_selectedKind),
          ),
        ],
      ),
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: settings?.detectedCountryCode == null
              ? const Icon(Icons.public)
              : FlagIcon.country(settings!.detectedCountryCode!, size: 32),
          title: Text(l10n.country),
          subtitle: Text(
            [
              countryLabel,
              if (settings?.detectedCurrency != null)
                settings!.detectedCurrency!,
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
        BookmarkTabs(
          labels: [
            for (final kind in TagKind.values) tagKindSectionTitle(l10n, kind),
          ],
          selectedIndex: TagKind.values.indexOf(_selectedKind),
          onChanged: (i) => setState(() => _selectedKind = TagKind.values[i]),
        ),
        const SizedBox(height: 12),
        for (final tag in kindTags)
          ListTile(
            leading: () {
              final icon = iconDataForTagKey(tag.iconKey);
              if (icon != null) {
                return CircleAvatar(
                  backgroundColor: tag.colorValue != null
                      ? Color(tag.colorValue!)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  radius: 12,
                  child: Icon(icon, size: 14),
                );
              }
              return CircleAvatar(
                backgroundColor: tag.colorValue != null
                    ? Color(tag.colorValue!)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                radius: 12,
              );
            }(),
            title: Text(localizedTagLabel(context, tag)),
            subtitle: tag.isDefault ? Text(l10n.defaultTags) : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                ref.read(manageTagsControllerProvider).deleteTag(tag.id);
              },
            ),
            onTap: () async {
              final currentLabel = localizedTagLabel(context, tag);
              final result = await showTagEditDialog(
                context,
                title: l10n.tag,
                initialName: currentLabel,
                initialColor: tag.colorValue,
                initialIconKey: tag.iconKey,
                confirmLabel: l10n.save,
              );
              if (result == null) return;
              final controller = ref.read(manageTagsControllerProvider);
              await controller.setTagColor(tag, result.colorValue);
              await controller.setTagIcon(tag, result.iconKey);
              if (result.name != currentLabel) {
                await controller.renameTag(
                  tag,
                  result.name,
                  iconKey: result.iconKey,
                );
              }
            },
          ),
      ],
    );
  }
}
