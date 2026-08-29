import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';

/// Centered title + description + optional body + centered action row.
///
/// Use for confirmations and small parameter-change sheets.
class ConfirmActionLayout extends StatelessWidget {
  final String title;
  final String description;
  final Widget? body;
  final List<Widget> actions;

  const ConfirmActionLayout({
    super.key,
    required this.title,
    required this.description,
    this.body,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (body != null) ...[
            const SizedBox(height: 16),
            body!,
          ],
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: actions,
          ),
        ],
      ),
    );
  }
}

/// Standard cancel + primary confirm pair for [ConfirmActionLayout.actions].
///
/// Prefer calling this from a [Builder] inside the sheet so [context] is the
/// modal route (cancel/confirm pop the sheet, not the page underneath).
List<Widget> confirmActionButtons({
  required BuildContext context,
  required String confirmLabel,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  bool destructive = false,
}) {
  final l10n = AppLocalizations.of(context)!;
  return [
    TextButton(
      onPressed: onCancel ?? () => Navigator.of(context).maybePop(),
      child: Text(l10n.cancel),
    ),
    if (destructive)
      FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
        ),
        onPressed: onConfirm,
        child: Text(confirmLabel),
      )
    else
      FilledButton(
        onPressed: onConfirm,
        child: Text(confirmLabel),
      ),
  ];
}

Future<T?> showConfirmActionSheet<T>({
  required BuildContext context,
  required Widget child,
  double initialChildSize = 0.42,
  double minChildSize = 0.28,
  double maxChildSize = 0.92,
}) {
  return showAppModalSheet<T>(
    context: context,
    initialChildSize: initialChildSize,
    minChildSize: minChildSize,
    maxChildSize: maxChildSize,
    child: Builder(
      builder: (sheetContext) {
        return ListView(
          controller: PrimaryScrollController.maybeOf(sheetContext),
          padding: EdgeInsets.zero,
          children: [child],
        );
      },
    ),
  );
}
