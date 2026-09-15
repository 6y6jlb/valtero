import 'package:flutter/material.dart';
import 'package:valtero/entities/payment_method/ui/payment_method_chip.dart';
import 'package:valtero/entities/tag/model/tag_hierarchy.dart';
import 'package:valtero/entities/tag/model/tag_kind.dart';
import 'package:valtero/entities/tag/ui/grouped_tag_picker.dart';
import 'package:valtero/entities/tag/ui/tag_chip.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/flag_icon.dart';

/// Payment / country / tags expandable sections for the add/edit expense form.
class AddExpenseMetaSection extends StatelessWidget {
  final List<PaymentMethod> paymentMethods;
  final int? paymentMethodId;
  final String paymentSubtitle;
  final ValueChanged<int?> onPaymentMethodChanged;
  final String? countryCode;
  final String countrySubtitle;
  final VoidCallback onPickCountry;
  final VoidCallback onClearCountry;
  final List<Tag> tags;
  final Set<int> tagIds;
  /// Selected tags shown in the collapsed subtitle (category then subcategory).
  final List<Tag> selectedTags;
  final ValueChanged<Tag> onTagTap;
  final ValueChanged<Tag>? onSubtagTap;
  final VoidCallback? onClearSubtag;
  final TextEditingController newTagController;
  final Future<void> Function() onAddTag;
  final TextEditingController? newSubtagController;
  final Future<void> Function()? onAddSubtag;
  final Iterable<TagKind>? tagKinds;

  const AddExpenseMetaSection({
    super.key,
    required this.paymentMethods,
    required this.paymentMethodId,
    required this.paymentSubtitle,
    required this.onPaymentMethodChanged,
    required this.countryCode,
    required this.countrySubtitle,
    required this.onPickCountry,
    required this.onClearCountry,
    required this.tags,
    required this.tagIds,
    required this.selectedTags,
    required this.onTagTap,
    required this.newTagController,
    required this.onAddTag,
    this.onSubtagTap,
    this.onClearSubtag,
    this.newSubtagController,
    this.onAddSubtag,
    this.tagKinds,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final tagById = {for (final t in tags) t.id: t};
    final kind = tagKinds?.isNotEmpty == true
        ? tagKinds!.first
        : TagKind.custom;
    final selectedParentId = selectedTopLevelTagId(tagIds, tagById, kind);
    final subtags = selectedParentId == null
        ? const <Tag>[]
        : childrenOf(tags, selectedParentId);
    final selectedSubId = selectedParentId == null
        ? null
        : selectedSubtagId(tagIds, tagById, selectedParentId);

    return Column(
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: ExpansionTile(
            initiallyExpanded: false,
            shape: const Border(),
            collapsedShape: const Border(),
            title: Text(l10n.paymentMethod),
            subtitle: Text(paymentSubtitle, style: subtitleStyle),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final method in paymentMethods)
                    PaymentMethodChip(
                      method: method,
                      selected: paymentMethodId == method.id,
                      onTap: () {
                        onPaymentMethodChanged(
                          paymentMethodId == method.id ? null : method.id,
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: ExpansionTile(
            initiallyExpanded: true,
            shape: const Border(),
            collapsedShape: const Border(),
            title: Text(l10n.country),
            subtitle: Text(countrySubtitle, style: subtitleStyle),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.public, size: 18),
                    label: Text(l10n.selectCountry),
                    onPressed: onPickCountry,
                  ),
                  if (countryCode != null)
                    InputChip(
                      avatar: FlagIcon.country(countryCode!, size: 18),
                      label: Text(
                        countryDisplayName(
                          countryCode!,
                          languageCode: lang,
                        ),
                      ),
                      selected: true,
                      onDeleted: onClearCountry,
                      onPressed: onPickCountry,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: ExpansionTile(
            initiallyExpanded: false,
            shape: const Border(),
            collapsedShape: const Border(),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            title: Text(l10n.tag),
            subtitle: selectedTags.isEmpty
                ? Text(l10n.tagsNoneSelected, style: subtitleStyle)
                : Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final tag in selectedTags)
                        TagChip(tag: tag, selected: true),
                    ],
                  ),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            children: [
              GroupedTagPicker(
                tags: tags,
                selectedIds: tagIds,
                singleSelectPerKind: true,
                onTagTap: onTagTap,
                kinds: tagKinds,
                topLevelOnly: true,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: newTagController,
                      decoration: InputDecoration(labelText: l10n.newTag),
                    ),
                  ),
                  IconButton(
                    onPressed: onAddTag,
                    icon: const Icon(Icons.add),
                    tooltip: l10n.addTag,
                  ),
                ],
              ),
              if (selectedParentId != null && onSubtagTap != null) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.subcategory,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: Text(l10n.subcategoryNone),
                      selected: selectedSubId == null,
                      onSelected: (_) => onClearSubtag?.call(),
                    ),
                    for (final tag in subtags)
                      TagChip(
                        tag: tag,
                        selected: selectedSubId == tag.id,
                        onTap: () => onSubtagTap!(tag),
                      ),
                  ],
                ),
                if (newSubtagController != null && onAddSubtag != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: newSubtagController,
                          decoration:
                              InputDecoration(labelText: l10n.addSubcategory),
                        ),
                      ),
                      IconButton(
                        onPressed: onAddSubtag,
                        icon: const Icon(Icons.add),
                        tooltip: l10n.addSubcategory,
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
