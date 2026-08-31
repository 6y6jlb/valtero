import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/platform_support.dart';

/// Microphone entry point for voice expense dictation (Android only).
class VoiceExpenseMicButton extends StatelessWidget {
  final VoidCallback onPressed;

  const VoiceExpenseMicButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    if (!isVoiceInputSupported) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      tooltip: l10n.voiceExpenseMicTooltip,
      icon: const Icon(Icons.mic_outlined),
      onPressed: onPressed,
    );
  }
}
