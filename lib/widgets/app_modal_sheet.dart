import 'package:flutter/material.dart';

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
      final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
      return AnimatedPadding(
        padding: EdgeInsets.only(bottom: bottomInset),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: SizedBox(
          width: width,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: initialChildSize,
            minChildSize: minChildSize,
            maxChildSize: maxChildSize,
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
    },
  );
}
