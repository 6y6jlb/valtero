import 'dart:async';

import 'package:flutter/material.dart';

OverlayEntry? _activeToast;

/// Top pill toast that auto-dismisses after 2s and can be closed manually.
void showAppToast(BuildContext context, String message) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;
  showAppToastOn(
    overlay: overlay,
    theme: Theme.of(context),
    message: message,
  );
}

/// Use when [BuildContext] may be disposed after an async gap / route pop.
void showAppToastOn({
  required OverlayState overlay,
  required ThemeData theme,
  required String message,
}) {
  _activeToast?.remove();
  _activeToast = null;

  final scheme = theme.colorScheme;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      final topInset = MediaQuery.paddingOf(context).top;
      return Positioned(
        top: topInset + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Material(
                elevation: 3,
                color: scheme.surfaceContainerHighest,
                shape: const StadiumBorder(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 4, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _dismissToast(entry),
                        icon: Icon(
                          Icons.close,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  _activeToast = entry;
  overlay.insert(entry);
  unawaited(
    Future<void>.delayed(const Duration(seconds: 2), () {
      _dismissToast(entry);
    }),
  );
}

void _dismissToast(OverlayEntry entry) {
  if (_activeToast != entry) return;
  entry.remove();
  _activeToast = null;
}
