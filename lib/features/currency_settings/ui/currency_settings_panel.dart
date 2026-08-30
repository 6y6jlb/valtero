import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/exchange_rate/model/rate_providers.dart';
import 'package:valtero/entities/integrations/exchange_rate_api/model/exchange_rate_api_integration.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/features/currency_settings/ui/rates_sheet.dart';
import 'package:valtero/features/integrations/ui/integration_config_modal.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/currency_label.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/currency_picker.dart';
import 'package:valtero/widgets/flag_icon.dart';
import 'package:valtero/widgets/set_manual_rate_sheet.dart';

Future<void> showCurrencySettingsSheet(BuildContext context) {
  return showAppModalSheet(
    context: context,
    child: const CurrencySettingsPanel(),
  );
}

class CurrencySettingsPanel extends ConsumerStatefulWidget {
  const CurrencySettingsPanel({super.key});

  @override
  ConsumerState<CurrencySettingsPanel> createState() =>
      _CurrencySettingsPanelState();
}

class _CurrencySettingsPanelState extends ConsumerState<CurrencySettingsPanel> {
  String? _status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(appSettingsProvider);
    final apiConnected =
        ref.watch(isIntegrationConfiguredProvider(kExchangeRateApiIntegrationId));
    final scrollController = PrimaryScrollController.maybeOf(context);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (settings) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(
              l10n.settingsCurrency,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(l10n.reportingCurrencies,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final code in settings.reportingCurrencies)
                  InputChip(
                    avatar: FlagIcon.currency(code, size: 18),
                    label: Text(
                      currencyDisplayLabel(
                        code,
                        languageCode:
                            Localizations.localeOf(context).languageCode,
                        customCodes: settings.customCurrencyCodes,
                      ),
                    ),
                    onDeleted: settings.reportingCurrencies.length <= 1
                        ? null
                        : () async {
                            final next = [...settings.reportingCurrencies]
                              ..remove(code);
                            await ref
                                .read(appSettingsProvider.notifier)
                                .setReportingCurrencies(next);
                          },
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text(l10n.add),
                  onPressed: () async {
                    final code = await showCurrencyPicker(context);
                    if (code == null) return;
                    if (settings.reportingCurrencies.contains(code)) return;
                    await ref
                        .read(appSettingsProvider.notifier)
                        .setReportingCurrencies(
                          [...settings.reportingCurrencies, code],
                        );
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
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.primaryCurrency),
              items: [
                for (final code in settings.reportingCurrencies)
                  DropdownMenuItem(
                    value: code,
                    child: CurrencyCodeLabel(code),
                  ),
              ],
              onChanged: (v) {
                if (v != null) {
                  ref.read(appSettingsProvider.notifier).setPrimaryCurrency(v);
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              apiConnected
                  ? l10n.rateSourceConnected
                  : l10n.rateSourceFrankfurter,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!apiConnected)
                  OutlinedButton(
                    onPressed: () async {
                      await showIntegrationConfigSheet(
                        context,
                        integration:
                            ref.read(frankfurterIntegrationProvider),
                      );
                    },
                    child: Text(l10n.integrationFrankfurterTitle),
                  ),
                OutlinedButton(
                  onPressed: () async {
                    await showIntegrationConfigSheet(
                      context,
                      integration:
                          ref.read(exchangeRateApiIntegrationProvider),
                    );
                  },
                  child: Text(l10n.openExchangeRateApiIntegration),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(rateResolverProvider)
                        .refreshIfStale(force: true);
                    if (!mounted) return;
                    setState(() => _status = l10n.ratesRefreshed);
                  },
                  child: Text(l10n.refreshRates),
                ),
                FilledButton.tonal(
                  onPressed: () => showRatesSheet(context),
                  child: Text(l10n.viewRates),
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
            FilledButton.icon(
              onPressed: () async {
                final rate = await showSetManualRateSheet(
                  context,
                  allowPickPair: true,
                );
                if (!mounted || rate == null) return;
                setState(() => _status = l10n.save);
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.addRate),
            ),
          ],
        );
      },
    );
  }
}
