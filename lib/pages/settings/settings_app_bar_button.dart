import 'package:flutter/material.dart';
import 'package:valtero/pages/settings/settings_page.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// AppBar gear that opens [SettingsPage]. Omit on the settings screen itself.
class SettingsAppBarButton extends StatelessWidget {
  const SettingsAppBarButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      tooltip: l10n.settings,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
        );
      },
      icon: const Icon(Icons.settings_outlined),
    );
  }
}
