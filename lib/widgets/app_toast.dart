import 'package:flutter/material.dart';

/// Top pill toast that auto-dismisses after 2s and can be closed manually.
void showAppToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final media = MediaQuery.of(context);
  showAppToastOn(
    messenger: messenger,
    theme: Theme.of(context),
    screenHeight: media.size.height,
    topInset: media.padding.top,
    message: message,
  );
}

/// Use when [BuildContext] may be disposed after an async gap / route pop.
void showAppToastOn({
  required ScaffoldMessengerState messenger,
  required ThemeData theme,
  required double screenHeight,
  required double topInset,
  required String message,
}) {
  messenger.clearSnackBars();
  final scheme = theme.colorScheme;
  const topGap = 12.0;
  const estimatedHeight = 52.0;

  messenger.showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      showCloseIcon: true,
      closeIconColor: scheme.onSurfaceVariant,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      dismissDirection: DismissDirection.up,
      elevation: 3,
      backgroundColor: scheme.surfaceContainerHighest,
      shape: const StadiumBorder(),
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: screenHeight - topInset - topGap - estimatedHeight,
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 8, 10),
    ),
  );
}
