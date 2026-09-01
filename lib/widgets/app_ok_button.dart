import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_button.dart';

/// Single OK / success confirm button for info modals (text then icon).
class AppOkButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;

  const AppOkButton({
    super.key,
    this.onPressed,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppFilledButton.tonal(
      label: label ?? l10n.ok,
      icon: Icons.check_circle_outline,
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
    );
  }
}
