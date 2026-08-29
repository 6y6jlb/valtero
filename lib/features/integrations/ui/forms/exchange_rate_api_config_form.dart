import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/features/integrations/model/integration_ui_meta.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/widgets/app_toast.dart';

class ExchangeRateApiConfigForm extends ConsumerStatefulWidget {
  const ExchangeRateApiConfigForm({super.key});

  @override
  ConsumerState<ExchangeRateApiConfigForm> createState() =>
      _ExchangeRateApiConfigFormState();
}

class _ExchangeRateApiConfigFormState
    extends ConsumerState<ExchangeRateApiConfigForm> {
  final _apiKeyController = TextEditingController();
  bool _testing = false;
  bool _saving = false;
  String? _status;
  bool _statusOk = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = ref.read(appSettingsProvider).value?.exchangeRateApiKey;
      if (key != null) _apiKeyController.text = key;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _test() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _testing = true;
      _status = null;
    });
    final result = await ref
        .read(exchangeRateApiIntegrationProvider)
        .testApiKey(_apiKeyController.text);
    if (!mounted) return;
    setState(() {
      _testing = false;
      _statusOk = result.success;
      _status = connectionMessage(l10n, result.messageKey);
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final key = _apiKeyController.text.trim();
    setState(() => _saving = true);
    final result =
        await ref.read(exchangeRateApiIntegrationProvider).testApiKey(key);
    if (!result.success) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _statusOk = false;
        _status = connectionMessage(l10n, result.messageKey);
      });
      return;
    }
    await ref.read(appSettingsProvider.notifier).setExchangeRateApiKey(key);
    await ref.read(rateResolverProvider).refreshIfStale(force: true);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _statusOk = true;
      _status = l10n.keyValid;
    });
    showAppToast(context, l10n.integrationSave);
  }

  Future<void> _disconnect() async {
    final l10n = AppLocalizations.of(context)!;
    await ref.read(appSettingsProvider.notifier).setExchangeRateApiKey(null);
    if (!mounted) return;
    setState(() {
      _apiKeyController.clear();
      _status = null;
    });
    showAppToast(context, l10n.integrationDisconnect);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _apiKeyController,
          decoration: InputDecoration(labelText: l10n.apiKey),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: _testing ? null : _test,
              child: _testing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.integrationTestConnection),
            ),
            FilledButton.tonal(
              onPressed: _saving ? null : _save,
              child: Text(l10n.integrationSave),
            ),
            OutlinedButton(
              onPressed: _disconnect,
              child: Text(l10n.integrationDisconnect),
            ),
          ],
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
