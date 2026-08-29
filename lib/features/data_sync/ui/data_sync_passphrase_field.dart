import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_toast.dart';

/// Passphrase input with a compact Generate / Copy / Show action bar below.
class DataSyncPassphraseField extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final bool showGenerate;
  final VoidCallback? onGenerate;

  const DataSyncPassphraseField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.showGenerate = false,
    this.onGenerate,
  });

  @override
  State<DataSyncPassphraseField> createState() =>
      _DataSyncPassphraseFieldState();
}

class _DataSyncPassphraseFieldState extends State<DataSyncPassphraseField> {
  bool _obscured = true;

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
    final theme = Theme.of(context);
    final canAct = widget.enabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: _obscured,
          decoration: InputDecoration(
            labelText: l10n.dataSyncPassphrase,
            prefixIcon: const Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.55,
          ),
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                if (widget.showGenerate) ...[
                  Expanded(
                    child: _PassphraseAction(
                      icon: Icons.auto_awesome_outlined,
                      label: l10n.dataSyncGenerateShort,
                      onPressed: canAct
                          ? () {
                              widget.onGenerate?.call();
                              setState(() => _obscured = false);
                            }
                          : null,
                    ),
                  ),
                  _ActionDivider(color: theme.colorScheme.outlineVariant),
                ],
                Expanded(
                  child: _PassphraseAction(
                    icon: Icons.content_copy_outlined,
                    label: l10n.dataSyncCopyShort,
                    onPressed: canAct ? _copy : null,
                  ),
                ),
                _ActionDivider(color: theme.colorScheme.outlineVariant),
                Expanded(
                  child: _PassphraseAction(
                    icon: _obscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    label: _obscured
                        ? l10n.dataSyncShowPassphrase
                        : l10n.dataSyncHidePassphrase,
                    onPressed: canAct
                        ? () => setState(() => _obscured = !_obscured)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PassphraseAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _PassphraseAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        foregroundColor: theme.colorScheme.onSurface,
        disabledForegroundColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.38,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _ActionDivider extends StatelessWidget {
  final Color color;

  const _ActionDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: VerticalDivider(
        width: 1,
        thickness: 1,
        color: color.withValues(alpha: 0.6),
      ),
    );
  }
}
