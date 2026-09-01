import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/entities/tag/ui/grouped_tag_picker.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/manage_tags/model/manage_tags_controller.dart';
import 'package:valtero/features/tag_suggestions/model/country_detection.dart';
import 'package:valtero/features/tag_suggestions/ui/suggested_tags_section.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/tag_color_picker.dart';

Future<void> showTagsSheet(BuildContext context) {
  return showAppModalSheet(
    context: context,
    child: const TagsSheetBody(),
  );
}

/// Page-layer composition: manage tags + country detection suggestions.
class TagsSheetBody extends ConsumerWidget {
  const TagsSheetBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return AppSheetScaffold(
      header: AppSheetHeader(title: l10n.tagsTitle),
      actions: AppSheetActionsBar(
        children: [
          const AppCloseIconButton(),
          AppFilledButton.tonal(
            label: l10n.addTag,
            icon: Icons.add,
            onPressed: () async {
              final result = await showTagEditDialog(
                context,
                title: l10n.newTag,
                confirmLabel: l10n.add,
              );
              if (result == null) return;
              await ref.read(manageTagsControllerProvider).addTag(
                    result.name,
                    colorValue: result.colorValue,
                  );
            },
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
        for (final kind in TagKind.values) ...[
          TagKindSectionHeader(kind: kind),
          for (final tag in grouped[kind]!)
            ListTile(
                leading: CircleAvatar(
                  backgroundColor: tag.colorValue != null
                      ? Color(tag.colorValue!)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  radius: 12,
                ),
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
                    confirmLabel: l10n.save,
                  );
                  if (result == null) return;
                  final controller = ref.read(manageTagsControllerProvider);
                  await controller.setTagColor(tag, result.colorValue);
                  if (result.name != currentLabel) {
                    await controller.renameTag(tag, result.name);
                  }
                },
              ),
        ],
      ],
    );
  }
}
