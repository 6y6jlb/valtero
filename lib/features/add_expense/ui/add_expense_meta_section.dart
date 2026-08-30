import 'package:flutter/material.dart';
import 'package:valtero/entities/payment_method/ui/payment_method_chip.dart';
import 'package:valtero/entities/tag/ui/grouped_tag_picker.dart';
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
  final String tagsSubtitle;
  final ValueChanged<Tag> onTagTap;
  final TextEditingController newTagController;
  final Future<void> Function() onAddTag;

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
    required this.tagsSubtitle,
    required this.onTagTap,
    required this.newTagController,
    required this.onAddTag,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: ExpansionTile(
            initiallyExpanded: false,
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
            title: Text(l10n.tag),
            subtitle: Text(tagsSubtitle, style: subtitleStyle),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            children: [
              GroupedTagPicker(
                tags: tags,
                selectedIds: tagIds,
                singleSelectPerKind: true,
                onTagTap: onTagTap,
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
            ],
          ),
        ),
      ],
    );
  }
}
