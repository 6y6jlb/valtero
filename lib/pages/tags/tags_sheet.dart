import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/tag/model/tag_hierarchy.dart';
import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/entities/tag/model/tags_provider.dart';
import 'package:valtero/features/manage_tags/model/manage_tags_controller.dart';
import 'package:valtero/features/tag_suggestions/model/country_detection.dart';
import 'package:valtero/features/tag_suggestions/ui/suggested_tags_section.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/consts/tag_icons.dart';
import 'package:valtero/shared/database/app_database.dart';
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

  Future<void> _addTagForKind(TagKind kind, {int? parentTagId}) async {
    final l10n = AppLocalizations.of(context)!;
    final tags = ref.read(tagsStreamProvider).value ?? const [];
    final parents = topLevelTags(
      [for (final t in tags) if (tagKindOf(t) == kind) t],
    );
    final result = await showTagEditSheet(
      context,
      title: parentTagId == null ? l10n.newTag : l10n.addSubcategory,
      confirmLabel: l10n.add,
      initialParentTagId: parentTagId,
      parentOptions: parents,
      showParentPicker: true,
      requireParent: parentTagId != null,
    );
    if (result == null) return;
    await ref.read(manageTagsControllerProvider).addTag(
          result.name,
          colorValue: result.colorValue,
          iconKey: result.iconKey,
          kind: tagKindDbValue(kind),
          parentTagId: parentTagId != null
              ? (result.parentTagId ?? parentTagId)
              : result.parentTagId,
        );
  }

  Future<void> _editTag(Tag tag, List<Tag> parents) async {
    final l10n = AppLocalizations.of(context)!;
    final currentLabel = localizedTagLabel(context, tag);
    final isSub = tag.parentTagId != null;
    final result = await showTagEditSheet(
      context,
      title: l10n.tag,
      initialName: currentLabel,
      initialColor: tag.colorValue,
      initialIconKey: tag.iconKey,
      initialParentTagId: tag.parentTagId,
      parentOptions: [
        for (final p in parents)
          if (p.id != tag.id) p,
      ],
      // Only subcategories may change parent; top-level stay top-level.
      showParentPicker: isSub,
      requireParent: isSub,
      confirmLabel: l10n.save,
    );
    if (result == null) return;
    final controller = ref.read(manageTagsControllerProvider);
    await controller.setTagColor(tag, result.colorValue);
    await controller.setTagIcon(tag, result.iconKey);
    final clearParent =
        isSub && result.parentTagId == null;
    if (result.name != currentLabel ||
        result.parentTagId != tag.parentTagId ||
        clearParent) {
      await controller.renameTag(
        tag,
        result.name,
        iconKey: result.iconKey,
        parentTagId: result.parentTagId,
        clearParent: clearParent,
      );
    }
  }

  Widget _leading(Tag tag) {
    final icon = iconDataForTagKey(tag.iconKey);
    final bg = tag.colorValue != null
        ? Color(tag.colorValue!)
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    if (icon != null) {
      return CircleAvatar(
        backgroundColor: bg,
        radius: 12,
        child: Icon(icon, size: 14),
      );
    }
    return CircleAvatar(backgroundColor: bg, radius: 12);
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
    final parents = topLevelTags(kindTags);
    final parentIds = {for (final p in parents) p.id};
    final orphans = [
      for (final t in kindTags)
        if (t.parentTagId != null && !parentIds.contains(t.parentTagId)) t,
    ];

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
        for (final parent in parents) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: _leading(parent),
            title: Text(localizedTagLabel(context, parent)),
            subtitle: parent.isDefault ? Text(l10n.defaultTags) : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: l10n.addSubcategory,
                  icon: const Icon(Icons.subdirectory_arrow_right),
                  onPressed: () => _addTagForKind(
                    _selectedKind,
                    parentTagId: parent.id,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    ref.read(manageTagsControllerProvider).deleteTag(parent.id);
                  },
                ),
              ],
            ),
            onTap: () => _editTag(parent, parents),
          ),
          for (final child in childrenOf(kindTags, parent.id))
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: _leading(child),
                title: Text(localizedTagLabel(context, child)),
                subtitle: child.isDefault ? Text(l10n.defaultTags) : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    ref
                        .read(manageTagsControllerProvider)
                        .deleteTag(child.id);
                  },
                ),
                onTap: () => _editTag(child, parents),
              ),
            ),
        ],
        for (final orphan in orphans)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: _leading(orphan),
            title: Text(localizedTagLabel(context, orphan)),
            subtitle: orphan.isDefault ? Text(l10n.defaultTags) : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                ref.read(manageTagsControllerProvider).deleteTag(orphan.id);
              },
            ),
            onTap: () => _editTag(orphan, parents),
          ),
      ],
    );
  }
}
