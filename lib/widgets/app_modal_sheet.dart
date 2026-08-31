import 'package:flutter/material.dart';

/// Bottom padding for scrollable modal content (safe area + base inset).
EdgeInsets appModalScrollPadding(
  BuildContext context, {
  EdgeInsets base = const EdgeInsets.fromLTRB(16, 0, 16, 24),
}) {
  final bottomSafe = MediaQuery.paddingOf(context).bottom;
  return base.copyWith(bottom: base.bottom + bottomSafe);
}

Future<T?> showAppModalSheet<T>({
  required BuildContext context,
  required Widget child,
  double initialChildSize = 0.75,
  double minChildSize = 0.4,
  double maxChildSize = 0.95,
  bool isScrollControlled = true,
}) {
  final width = MediaQuery.sizeOf(context).width;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    showDragHandle: true,
    // Desktop Material defaults to a narrow sheet — force full window width.
    constraints: BoxConstraints(maxWidth: width, minWidth: width),
    builder: (context) {
      return _AppModalSheetBody(
        width: width,
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        child: child,
      );
    },
  );
}

class _AppModalSheetBody extends StatelessWidget {
  final double width;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final Widget child;

  const _AppModalSheetBody({
    required this.width,
    required this.initialChildSize,
    required this.minChildSize,
    required this.maxChildSize,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final topInset = mediaQuery.padding.top;

    // Compute heights from the full screen so keyboard lift does not shrink
    // the sheet twice (fraction-of-parent + bottom padding).
    final fullUsableHeight = screenHeight - topInset;
    final aboveKeyboard = fullUsableHeight - keyboardHeight;

    final minHeight = fullUsableHeight * minChildSize;
    final maxHeight = fullUsableHeight * maxChildSize;
    final preferredHeight = fullUsableHeight * initialChildSize;

    // When the keyboard is open, never enforce [minChildSize] — it is a fraction
    // of full screen and would push content under the keyboard with padding.
    final sheetHeight = keyboardHeight > 0
        ? aboveKeyboard.clamp(0.0, maxHeight)
        : preferredHeight.clamp(minHeight, maxHeight);

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        height: sheetHeight,
        width: width,
        child: DraggableScrollableSheet(
          expand: true,
          initialChildSize: 1.0,
          minChildSize: 1.0,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return Material(
              color: Theme.of(context).colorScheme.surface,
              child: PrimaryScrollController(
                controller: scrollController,
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}
