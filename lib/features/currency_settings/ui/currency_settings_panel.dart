import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/shared/consts/currencies.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';

class CurrencySettingsPanel extends ConsumerStatefulWidget {
  const CurrencySettingsPanel({super.key});

  @override
  ConsumerState<CurrencySettingsPanel> createState() =>
      _CurrencySettingsPanelState();
}

class _CurrencySettingsPanelState extends ConsumerState<CurrencySettingsPanel> {
  final _apiKeyController = TextEditingController();
  final _manualRateController = TextEditingController();
  String _manualBase = 'USD';
  String _manualTarget = 'RUB';
  String? _status;

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
    _manualRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(appSettingsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (settings) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.reportingCurrencies,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final code in supportedCurrencyCodes)
                  FilterChip(
                    label: Text(code),
                    selected: settings.reportingCurrencies.contains(code),
                    onSelected: (selected) async {
                      final next = [...settings.reportingCurrencies];
                      if (selected) {
                        if (!next.contains(code)) next.add(code);
                      } else {
                        if (next.length <= 1) return;
                        next.remove(code);
                      }
                      await ref
                          .read(appSettingsProvider.notifier)
                          .setReportingCurrencies(next);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: settings.reportingCurrencies.contains(settings.primaryCurrency)
                  ? settings.primaryCurrency
                  : settings.reportingCurrencies.first,
              decoration: InputDecoration(labelText: l10n.primaryCurrency),
              items: [
                for (final code in settings.reportingCurrencies)
                  DropdownMenuItem(value: code, child: Text(code)),
              ],
              onChanged: (v) {
                if (v != null) {
                  ref.read(appSettingsProvider.notifier).setPrimaryCurrency(v);
                }
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(labelText: l10n.apiKey),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton(
                  onPressed: () async {
                    final key = _apiKeyController.text.trim();
                    final ok = await ref
                        .read(exchangeRateApiProvider)
                        .validateApiKey(key);
                    if (!mounted) return;
                    if (ok) {
                      await ref
                          .read(appSettingsProvider.notifier)
                          .setExchangeRateApiKey(key);
                      await ref
                          .read(rateResolverProvider)
                          .refreshIfStale(force: true);
                      setState(() => _status = l10n.keyValid);
                    } else {
                      setState(() => _status = l10n.keyInvalid);
                    }
                  },
                  child: Text(l10n.validateKey),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(rateResolverProvider).refreshIfStale(force: true);
                    if (!mounted) return;
                    setState(() => _status = l10n.ratesRefreshed);
                  },
                  child: Text(l10n.refreshRates),
                ),
              ],
            ),
            if (_status != null) ...[
              const SizedBox(height: 8),
              Text(_status!),
            ],
            const SizedBox(height: 24),
            Text(l10n.manualRates, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _manualBase,
                    decoration: InputDecoration(labelText: l10n.baseCurrency),
                    items: [
                      for (final code in supportedCurrencyCodes)
                        DropdownMenuItem(value: code, child: Text(code)),
                    ],
                    onChanged: (v) => setState(() => _manualBase = v ?? _manualBase),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _manualTarget,
                    decoration: InputDecoration(labelText: l10n.targetCurrency),
                    items: [
                      for (final code in supportedCurrencyCodes)
                        DropdownMenuItem(value: code, child: Text(code)),
                    ],
                    onChanged: (v) =>
                        setState(() => _manualTarget = v ?? _manualTarget),
                  ),
                ),
              ],
            ),
            TextField(
              controller: _manualRateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.rate),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () async {
                final rate = double.tryParse(
                  _manualRateController.text.trim().replaceAll(',', '.'),
                );
                if (rate == null || rate <= 0) return;
                await ref.read(rateResolverProvider).setManualRate(
                      base: _manualBase,
                      target: _manualTarget,
                      rate: rate,
                    );
                if (!mounted) return;
                setState(() => _status = l10n.save);
              },
              child: Text(l10n.save),
            ),
            const SizedBox(height: 24),
            Text(l10n.theme, style: Theme.of(context).textTheme.titleMedium),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'system', label: Text(l10n.system)),
                ButtonSegment(value: 'light', label: Text(l10n.light)),
                ButtonSegment(value: 'dark', label: Text(l10n.dark)),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) {
                ref.read(appSettingsProvider.notifier).setThemeMode(s.first);
              },
            ),
            const SizedBox(height: 16),
            Text(l10n.locale, style: Theme.of(context).textTheme.titleMedium),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'system', label: Text(l10n.system)),
                const ButtonSegment(value: 'en', label: Text('EN')),
                const ButtonSegment(value: 'ru', label: Text('RU')),
              ],
              selected: {settings.locale},
              onSelectionChanged: (s) {
                ref.read(appSettingsProvider.notifier).setLocale(s.first);
              },
            ),
          ],
        );
      },
    );
  }
}
