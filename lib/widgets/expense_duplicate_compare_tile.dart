import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/date_text.dart';
import 'package:valtero/widgets/money_text.dart';

/// Compact side-by-side summary used in duplicate-resolution UIs.
class ExpenseDuplicateCompareTile extends StatelessWidget {
  final String title;
  final DateTime occurredAt;
  final int amountMinor;
  final String currencyCode;
  final String? paymentLabel;
  final String? countryLabel;
  final String? tagsLabel;
  final String? note;
  final Color? borderColor;

  const ExpenseDuplicateCompareTile({
    super.key,
    required this.title,
    required this.occurredAt,
    required this.amountMinor,
    required this.currencyCode,
    this.paymentLabel,
    this.countryLabel,
    this.tagsLabel,
    this.note,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final parts = <String>[
      if (paymentLabel != null && paymentLabel!.isNotEmpty) paymentLabel!,
      if (countryLabel != null && countryLabel!.isNotEmpty) countryLabel!,
      if (tagsLabel != null && tagsLabel!.isNotEmpty) tagsLabel!,
    ];

    return Card(
      margin: EdgeInsets.zero,
      shape: borderColor == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: borderColor!),
            ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            MoneyText(
              amountMinor: amountMinor,
              currencyCode: currencyCode,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            DateText(
              instant: occurredAt,
              style: theme.textTheme.bodySmall,
            ),
            if (parts.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                parts.join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (note != null && note!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                note!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (parts.isEmpty && (note == null || note!.trim().isEmpty))
              Text(
                l10n.untagged,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
