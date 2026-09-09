import 'package:flutter/material.dart';
import 'package:valtero/features/expenses_list/model/transaction_direction.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Folder-style bookmark tabs for expenses / income / cash-flow views.
///
/// The selected tab sits slightly higher, like a label sticking out of a
/// folder; inactive tabs stay flush with the baseline.
class OperationDirectionTabs extends StatelessWidget {
  final TransactionDirection selected;
  final ValueChanged<TransactionDirection> onChanged;

  const OperationDirectionTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  String _label(AppLocalizations l10n, TransactionDirection direction) {
    return switch (direction) {
      TransactionDirection.expenses => l10n.directionExpenses,
      TransactionDirection.income => l10n.directionIncome,
      TransactionDirection.cashFlow => l10n.directionCashFlow,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final outline = Theme.of(context)
        .colorScheme
        .outlineVariant
        .withValues(alpha: 0.7);

    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(height: 1, color: outline),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < TransactionDirection.values.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: _BookmarkTab(
                    label: _label(l10n, TransactionDirection.values[i]),
                    selected: selected == TransactionDirection.values[i],
                    onTap: () => onChanged(TransactionDirection.values[i]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BookmarkTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BookmarkTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final outline = scheme.outlineVariant.withValues(alpha: 0.7);
    const radius = BorderRadius.vertical(top: Radius.circular(12));

    final bg = selected
        ? scheme.primaryContainer
        : scheme.surfaceContainerHighest.withValues(alpha: 0.55);
    final fg =
        selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;

    // Paint the tab 1px below the shared baseline so the fill covers the
    // hairline under the active tab — without a non-uniform Border (which
    // Flutter rejects when combined with borderRadius).
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Transform.translate(
        offset: const Offset(0, 1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: selected ? 40 : 32,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: Border.all(color: outline),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    style:
                        (theme.textTheme.labelLarge ?? const TextStyle())
                            .copyWith(
                      color: fg,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
