import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/features/integrations/model/integration_ui_meta.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_toast.dart';

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
    final message = connectionMessage(l10n, result.messageKey);
    setState(() {
      _busy = false;
      _status = result.success ? null : message;
    });
    if (result.success) {
      showAppToast(context, message);
    }
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
          child: AppFilledButton(
            label: l10n.integrationTestConnection,
            busy: _busy,
            onPressed: _busy ? null : _test,
          ),
        ),
        if (_status != null) ...[
          const SizedBox(height: 8),
          Text(
            _status!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
