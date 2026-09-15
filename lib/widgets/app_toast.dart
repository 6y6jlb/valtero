import 'dart:async';

import 'package:flutter/material.dart';

OverlayEntry? _activeToast;

/// Top toast that auto-dismisses and can be closed manually.
///
/// Duration scales with message length so long sync/error copy stays readable.
/// Uses a fixed corner radius (not a stadium) so multi-line text does not clip.
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
  // Short labels ~2s; long schema/sync errors need more reading time.
  final dismissAfter = Duration(
    milliseconds: (2000 + message.length * 35).clamp(2000, 8000),
  );
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
                // Fixed radius (not StadiumBorder): multi-line text must not
                // clip into a height-dependent capsule curve.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, right: 4),
                          child: Text(
                            message,
                            softWrap: true,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
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
    Future<void>.delayed(dismissAfter, () {
      _dismissToast(entry);
    }),
  );
}

void _dismissToast(OverlayEntry entry) {
  if (_activeToast != entry) return;
  entry.remove();
  _activeToast = null;
}
