import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/integrations/exchange_rate_api/model/exchange_rate_api_integration.dart';
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
  String? _verifiedKey;

  @override
  void initState() {
    super.initState();
    _apiKeyController.addListener(_onKeyChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = ref.read(appSettingsProvider).value?.exchangeRateApiKey;
      if (key == null || key.isEmpty) return;
      _apiKeyController.removeListener(_onKeyChanged);
      _apiKeyController.text = key;
      _apiKeyController.addListener(_onKeyChanged);
      setState(() {
        // Already connected — treat saved key as verified for Save.
        _verifiedKey = key.trim();
        _statusOk = true;
      });
    });
  }

  @override
  void dispose() {
    _apiKeyController.removeListener(_onKeyChanged);
    _apiKeyController.dispose();
    super.dispose();
  }

  void _onKeyChanged() {
    final key = _apiKeyController.text.trim();
    setState(() {
      if (_verifiedKey != null && _verifiedKey != key) {
        _verifiedKey = null;
        _statusOk = false;
        _status = null;
      }
    });
  }

  bool get _keyFilled => _apiKeyController.text.trim().isNotEmpty;

  bool get _keyVerified =>
      _keyFilled && _verifiedKey == _apiKeyController.text.trim();

  bool get _busy => _testing || _saving;

  Future<void> _test() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_keyFilled) return;
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
      _verifiedKey = result.success ? _apiKeyController.text.trim() : null;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_keyVerified) return;
    final key = _apiKeyController.text.trim();
    setState(() => _saving = true);
    final result =
        await ref.read(exchangeRateApiIntegrationProvider).testApiKey(key);
    if (!result.success) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _statusOk = false;
        _verifiedKey = null;
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
      _verifiedKey = key;
      _status = l10n.keyValid;
    });
    showAppToast(context, l10n.integrationSave);
  }

  Future<void> _disconnect() async {
    final l10n = AppLocalizations.of(context)!;
    final connected = ref.read(
      isIntegrationConfiguredProvider(kExchangeRateApiIntegrationId),
    );
    if (!connected) return;
    await ref.read(appSettingsProvider.notifier).setExchangeRateApiKey(null);
    if (!mounted) return;
    setState(() {
      _apiKeyController.clear();
      _status = null;
      _statusOk = false;
      _verifiedKey = null;
    });
    showAppToast(context, l10n.integrationDisconnect);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final connected = ref.watch(
      isIntegrationConfiguredProvider(kExchangeRateApiIntegrationId),
    );
    final canTest = !_busy && _keyFilled;
    final canSave = !_busy && _keyVerified;
    final canDisconnect = !_busy && connected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _apiKeyController,
          decoration: InputDecoration(labelText: l10n.apiKey),
          obscureText: true,
          enabled: !_busy,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: canTest ? _test : null,
              child: _testing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.integrationTestConnection),
            ),
            FilledButton.tonal(
              onPressed: canSave ? _save : null,
              child: Text(l10n.integrationSave),
            ),
            OutlinedButton(
              onPressed: canDisconnect ? _disconnect : null,
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
