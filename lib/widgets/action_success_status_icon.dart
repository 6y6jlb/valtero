import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/relative_time.dart';
import 'package:valtero/widgets/app_toast.dart';

/// Compact success checkmark beside an action button.
///
/// Tap shows [detailMessage], or a relative-time label when [completedAt] is set.
class ActionSuccessStatusIcon extends StatelessWidget {
  final DateTime? completedAt;
  final String? detailMessage;
  final String? tooltip;

  const ActionSuccessStatusIcon({
    super.key,
    this.completedAt,
    this.detailMessage,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final message = detailMessage ??
        formatRelativeTimeAgo(completedAt!, l10n);

    return IconButton(
      tooltip: tooltip ?? l10n.actionSuccessStatusHint,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: () => showAppToast(context, message),
      icon: Icon(
        Icons.check_circle_outline,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
