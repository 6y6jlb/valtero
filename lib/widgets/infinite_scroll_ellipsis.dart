import 'package:flutter/material.dart';

/// Centered “…” footer that hints more rows can be loaded via scroll.
class InfiniteScrollEllipsis extends StatelessWidget {
  const InfiniteScrollEllipsis({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          '…',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

/// Returns true when [notification] indicates the user is near the bottom.
bool isNearScrollBottom(ScrollNotification notification, {double threshold = 80}) {
  if (notification is! ScrollUpdateNotification &&
      notification is! OverscrollNotification) {
    return false;
  }
  final metrics = notification.metrics;
  if (!metrics.hasPixels || !metrics.hasContentDimensions) return false;
  return metrics.pixels >= metrics.maxScrollExtent - threshold;
}
