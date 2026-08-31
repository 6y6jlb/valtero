import 'package:flutter/material.dart';

/// App [FilledButton] with optional stable-size busy spinner.
///
/// When [busy] is true, taps are absorbed and the label stays laid out (invisible)
/// under a centered progress indicator — no width/height jump.
class AppFilledButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final bool _tonal;

  const AppFilledButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  }) : _tonal = false;

  const AppFilledButton.tonal({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  }) : _tonal = true;

  @override
  Widget build(BuildContext context) {
    final effective = busy ? () {} : onPressed;
    final child = _BusyLabel(label: label, busy: busy);
    if (_tonal) {
      return FilledButton.tonal(onPressed: effective, child: child);
    }
    return FilledButton(onPressed: effective, child: child);
  }
}

/// App [OutlinedButton] with optional stable-size busy spinner.
class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: busy ? () {} : onPressed,
      child: _BusyLabel(label: label, busy: busy),
    );
  }
}

/// App [TextButton] with optional stable-size busy spinner.
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: busy ? () {} : onPressed,
      child: _BusyLabel(label: label, busy: busy),
    );
  }
}

class _BusyLabel extends StatelessWidget {
  final String label;
  final bool busy;

  const _BusyLabel({required this.label, required this.busy});

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color ??
        DefaultTextStyle.of(context).style.color;

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: busy ? 0 : 1, child: Text(label)),
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
