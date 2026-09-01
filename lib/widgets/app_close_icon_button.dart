import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_button.dart';

/// Close action for modals: label then trailing grey X (text → icon).
class AppCloseIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;

  const AppCloseIconButton({
    super.key,
    this.onPressed,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppOutlinedButton(
      label: label ?? l10n.close,
      icon: Icons.close,
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
    );
  }
}
