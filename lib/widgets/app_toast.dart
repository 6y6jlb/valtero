import 'dart:async';

import 'package:flutter/material.dart';

OverlayEntry? _activeToast;
Timer? _activeToastTimer;

enum AppToastVariant { plain, loading, success }

/// Top toast that auto-dismisses and can be closed manually.
///
/// Duration scales with message length so long sync/error copy stays readable.
/// Uses a fixed corner radius (not a stadium) so multi-line text does not clip.
void showAppToast(
  BuildContext context,
  String message, {
  AppToastVariant variant = AppToastVariant.plain,
  bool persistent = false,
}) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;
  showAppToastOn(
    overlay: overlay,
    theme: Theme.of(context),
    message: message,
    variant: variant,
    persistent: persistent,
  );
}

/// Use when [BuildContext] may be disposed after an async gap / route pop.
void showAppToastOn({
  required OverlayState overlay,
  required ThemeData theme,
  required String message,
  AppToastVariant variant = AppToastVariant.plain,
  bool persistent = false,
}) {
  _activeToastTimer?.cancel();
  _activeToastTimer = null;
  _activeToast?.remove();
  _activeToast = null;

  final scheme = theme.colorScheme;
  // Short labels ~2s; long schema/sync errors need more reading time.
  final dismissAfter = persistent
      ? null
      : Duration(
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
                      if (variant == AppToastVariant.loading)
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 10),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.primary,
                            ),
                          ),
                        )
                      else if (variant == AppToastVariant.success)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, right: 8),
                          child: Icon(
                            Icons.check_circle,
                            size: 20,
                            color: scheme.primary,
                          ),
                        ),
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
  if (dismissAfter != null) {
    _activeToastTimer = Timer(dismissAfter, () => _dismissToast(entry));
  }
}

void _dismissToast(OverlayEntry entry) {
  if (_activeToast != entry) return;
  _activeToastTimer?.cancel();
  _activeToastTimer = null;
  entry.remove();
  _activeToast = null;
}
