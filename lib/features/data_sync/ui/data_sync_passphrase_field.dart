import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_toast.dart';
import 'package:valtero/widgets/secret_text_field.dart';

/// Passphrase input: lock toggles visibility; optional generate/copy as suffix.
class DataSyncPassphraseField extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final bool showGenerate;
  final bool showCopy;
  final bool initiallyObscured;
  final VoidCallback? onGenerate;

  const DataSyncPassphraseField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.showGenerate = false,
    this.showCopy = true,
    this.initiallyObscured = true,
    this.onGenerate,
  });

  @override
  State<DataSyncPassphraseField> createState() =>
      _DataSyncPassphraseFieldState();
}

class _DataSyncPassphraseFieldState extends State<DataSyncPassphraseField> {
  final _fieldKey = GlobalKey<SecretTextFieldState>();

  Future<void> _copy() async {
    final text = widget.controller.text.trim();
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    showAppToast(context, AppLocalizations.of(context)!.copiedToClipboard);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canAct = widget.enabled;
    final hasSuffix = widget.showGenerate || widget.showCopy;
    final suffixCount =
        (widget.showGenerate ? 1 : 0) + (widget.showCopy ? 1 : 0);

    return SecretTextField(
      key: _fieldKey,
      controller: widget.controller,
      labelText: l10n.dataSyncPassphrase,
      enabled: widget.enabled,
      initiallyObscured: widget.initiallyObscured,
      suffixIcon: hasSuffix
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showGenerate)
                  IconButton(
                    tooltip: l10n.dataSyncGeneratePassphrase,
                    onPressed: canAct
                        ? () {
                            widget.onGenerate?.call();
                            _fieldKey.currentState?.reveal();
                          }
                        : null,
                    icon: const Icon(Icons.auto_awesome_outlined),
                  ),
                if (widget.showCopy)
                  IconButton(
                    tooltip: l10n.dataSyncCopyPassphrase,
                    onPressed: canAct ? _copy : null,
                    icon: const Icon(Icons.content_copy_outlined),
                  ),
              ],
            )
          : null,
      suffixIconConstraints: hasSuffix
          ? BoxConstraints(
              minWidth: 48.0 * suffixCount,
              minHeight: 48,
            )
          : null,
    );
  }
}
