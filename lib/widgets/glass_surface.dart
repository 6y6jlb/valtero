import 'dart:ui';

import 'package:flutter/material.dart';

/// Telegram-like frosted control (circle FAB, extended pill, bulk bar).
///
/// Neutral translucent fill + soft drop shadow. No stroked rim (Linux often
/// paints rounded borders jagged). [BackdropFilter] when the backend supports
/// it; the high-opacity fill still reads clean when blur is a no-op.
/// Put [MaterialType.transparency] + [InkWell] inside [child] for ripples.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final Color tint;
  final double blurSigma;

  const GlassSurface({
    super.key,
    required this.child,
    required this.borderRadius,
    required this.tint,
    this.blurSigma = 20,
  });

  /// Circular 56×56 glass disc (standard FAB footprint).
  factory GlassSurface.circle({
    Key? key,
    required Widget child,
    required Color tint,
  }) {
    return GlassSurface(
      key: key,
      borderRadius: BorderRadius.circular(28),
      tint: tint,
      child: SizedBox(width: 56, height: 56, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.14),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: ColoredBox(
            color: tint,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Neutral frosted plate — Telegram light/dark floating chrome.
Color glassFabTint(ColorScheme scheme) {
  if (scheme.brightness == Brightness.dark) {
    // Near-opaque dark plate so content behind doesn't muddy icons.
    return const Color(0xE62C2C2E);
  }
  return Colors.white.withValues(alpha: 0.94);
}

/// Same family for open-menu chips (slightly more opaque so labels stay crisp).
Color glassFabActionTint(ColorScheme scheme) {
  if (scheme.brightness == Brightness.dark) {
    return const Color(0xF02C2C2E);
  }
  return Colors.white.withValues(alpha: 0.97);
}

/// Accent on glass (Telegram-style blue/primary glyph on a white plate).
Color glassFabAccent(ColorScheme scheme) => scheme.primary;

/// Body text / secondary glyphs on glass.
Color glassFabOnPlate(ColorScheme scheme) => scheme.onSurface;

/// Solid secondary fill — kept for contrast helpers / legacy callers.
Color expandFabActionBackgroundSolid(ColorScheme scheme) {
  return glassFabActionTint(scheme).withValues(alpha: 1);
}
