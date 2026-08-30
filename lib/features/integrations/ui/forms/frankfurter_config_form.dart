import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/features/integrations/model/integration_ui_meta.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

/// Built-in free rate source: test reachability only (no credentials).
class FrankfurterConfigForm extends ConsumerStatefulWidget {
  const FrankfurterConfigForm({super.key});

  @override
  ConsumerState<FrankfurterConfigForm> createState() =>
      _FrankfurterConfigFormState();
}

class _FrankfurterConfigFormState extends ConsumerState<FrankfurterConfigForm> {
  bool _busy = false;
  String? _status;
  bool _statusOk = false;

  Future<void> _test() async {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.read(appSettingsProvider).value;
    if (settings == null) return;
    setState(() {
      _busy = true;
      _status = null;
    });
    final result = await ref
        .read(frankfurterIntegrationProvider)
        .testConnection(settings);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _statusOk = result.success;
      _status = connectionMessage(l10n, result.messageKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.integrationFrankfurterHint,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: _busy ? null : _test,
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.integrationTestConnection),
          ),
        ),
        if (_status != null) ...[
          const SizedBox(height: 12),
          Text(
            _status!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _statusOk
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
