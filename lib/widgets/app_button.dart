import 'package:flutter/material.dart';

/// App [FilledButton] with optional trailing icon and stable-size busy spinner.
///
/// When [busy] is true, taps are absorbed and the label stays laid out (invisible)
/// under a centered progress indicator — no width/height jump.
///
/// Icon order is always **text then icon** (trailing).
class AppFilledButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;
  final bool destructive;
  final bool _tonal;

  const AppFilledButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.icon,
    this.destructive = false,
  }) : _tonal = false;

  const AppFilledButton.tonal({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.icon,
    this.destructive = false,
  }) : _tonal = true;

  @override
  Widget build(BuildContext context) {
    final effective = busy ? () {} : onPressed;
    final child = _BusyLabel(label: label, busy: busy, icon: icon);
    final scheme = Theme.of(context).colorScheme;
    final style = destructive
        ? FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          )
        : null;
    if (_tonal) {
      return FilledButton.tonal(
        onPressed: effective,
        style: style,
        child: child,
      );
    }
    return FilledButton(
      onPressed: effective,
      style: style,
      child: child,
    );
  }
}

/// App [OutlinedButton] with optional trailing icon and stable-size busy spinner.
class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;
  final bool destructive;

  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.icon,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = destructive
        ? OutlinedButton.styleFrom(
            foregroundColor: scheme.error,
            side: BorderSide(color: scheme.error),
          )
        : null;
    return OutlinedButton(
      onPressed: busy ? () {} : onPressed,
      style: style,
      child: _BusyLabel(label: label, busy: busy, icon: icon),
    );
  }
}

/// App [TextButton] with optional trailing icon and stable-size busy spinner.
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;
  final bool destructive;

  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.icon,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = destructive
        ? TextButton.styleFrom(foregroundColor: scheme.error)
        : null;
    return TextButton(
      onPressed: busy ? () {} : onPressed,
      style: style,
      child: _BusyLabel(label: label, busy: busy, icon: icon),
    );
  }
}

class _BusyLabel extends StatelessWidget {
  final String label;
  final bool busy;
  final IconData? icon;

  const _BusyLabel({
    required this.label,
    required this.busy,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color ??
        DefaultTextStyle.of(context).style.color;

    final content = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              const SizedBox(width: 8),
              Icon(icon, size: 18),
            ],
          );

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: busy ? 0 : 1, child: content),
        if (busy)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: color,
            ),
          ),
      ],
    );
  }
}
