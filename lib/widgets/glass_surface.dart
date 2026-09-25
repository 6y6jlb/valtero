import 'package:flutter/material.dart';

/// Solid rounded plate for sticky bottom FABs and bulk bars.
///
/// Fill is [ColorScheme.primaryContainer] (same as a selected bookmark tab).
/// Shape stays circle / pill / bar via [borderRadius]; no blur.
/// Put [MaterialType.transparency] + [InkWell] inside [child] for ripples.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final Color tint;

  const GlassSurface({
    super.key,
    required this.child,
    required this.borderRadius,
    required this.tint,
  });

  /// Circular 56×56 disc (standard FAB footprint).
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
        child: ColoredBox(
          color: tint,
          child: child,
        ),
      ),
    );
  }
}

/// Closed FAB / bulk bar fill — matches selected bookmark tab.
Color glassFabTint(ColorScheme scheme) => scheme.primaryContainer;

/// Open-menu chip fill (same solid plate as the closed trigger).
Color glassFabActionTint(ColorScheme scheme) => scheme.primaryContainer;

/// Icons and labels on the FAB plate.
Color glassFabAccent(ColorScheme scheme) => scheme.onPrimaryContainer;

/// Body text / secondary glyphs on the FAB plate.
Color glassFabOnPlate(ColorScheme scheme) => scheme.onPrimaryContainer;

/// Solid secondary fill — kept for contrast helpers / legacy callers.
Color expandFabActionBackgroundSolid(ColorScheme scheme) =>
    scheme.primaryContainer;
