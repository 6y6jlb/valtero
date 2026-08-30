import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Text field for secrets (API keys, tokens, passphrases).
/// Prefix lock toggles visibility: closed = obscured, open = plain text.
class SecretTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? helperText;
  final bool enabled;
  final bool initiallyObscured;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final BoxConstraints? suffixIconConstraints;

  const SecretTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.helperText,
    this.enabled = true,
    this.initiallyObscured = true,
    this.keyboardType,
    this.onChanged,
    this.suffixIcon,
    this.suffixIconConstraints,
  });

  @override
  State<SecretTextField> createState() => SecretTextFieldState();
}

class SecretTextFieldState extends State<SecretTextField> {
  late bool _obscured = widget.initiallyObscured;

  void reveal() {
    if (_obscured) setState(() => _obscured = false);
  }

  void conceal() {
    if (!_obscured) setState(() => _obscured = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.labelText,
        helperText: widget.helperText,
        prefixIcon: IconButton(
          tooltip: _obscured ? l10n.showSecret : l10n.hideSecret,
          onPressed: widget.enabled
              ? () => setState(() => _obscured = !_obscured)
              : null,
          icon: Icon(
            _obscured ? Icons.lock_outline : Icons.lock_open,
          ),
        ),
        suffixIcon: widget.suffixIcon,
        suffixIconConstraints: widget.suffixIconConstraints,
      ),
    );
  }
}
