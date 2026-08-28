import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/currency_settings/ui/currency_settings_panel.dart';
import 'package:valtero/features/export_expenses/ui/export_flow.dart';
import 'package:valtero/features/manage_payment_methods/ui/payment_methods_sheet.dart';
import 'package:valtero/pages/platform_guide/platform_guide_page.dart';
import 'package:valtero/pages/tags/tags_sheet.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/app_version_provider.dart';
import 'package:valtero/shared/utils/money_display.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_page_scaffold.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _openAppearance(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return showAppModalSheet(
      context: context,
      initialChildSize: 0.75,
      minChildSize: 0.45,
      child: Consumer(
        builder: (context, ref, _) {
          final settings = ref.watch(appSettingsProvider).value;
          final scrollController = PrimaryScrollController.maybeOf(context);
          final selectedTz = settings?.timeZoneId ?? kSystemTimeZoneId;
          final tzValue = selectableTimeZones.contains(selectedTz)
              ? selectedTz
              : kSystemTimeZoneId;

          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Text(
                l10n.settingsAppearance,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(l10n.theme, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'system', label: Text(l10n.system)),
                  ButtonSegment(value: 'light', label: Text(l10n.light)),
                  ButtonSegment(value: 'dark', label: Text(l10n.dark)),
                ],
                selected: {settings?.themeMode ?? 'system'},
                onSelectionChanged: (s) {
                  ref.read(appSettingsProvider.notifier).setThemeMode(s.first);
                },
              ),
              const SizedBox(height: 16),
              Text(l10n.locale, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'system', label: Text(l10n.system)),
                  const ButtonSegment(value: 'en', label: Text('EN')),
                  const ButtonSegment(value: 'ru', label: Text('RU')),
                ],
                selected: {settings?.locale ?? 'system'},
                onSelectionChanged: (s) {
                  ref.read(appSettingsProvider.notifier).setLocale(s.first);
                },
              ),
              const SizedBox(height: 16),
              Text(l10n.moneyFormat, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: moneyDisplayFormatFromName(settings?.moneyDisplayFormat)
                    .name,
                decoration: InputDecoration(labelText: l10n.moneyFormat),
                isExpanded: true,
                items: [
                  for (final format in MoneyDisplayFormat.values)
                    DropdownMenuItem(
                      value: format.name,
                      child: Text(
                        _moneyFormatLabel(l10n, format),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setMoneyDisplayFormat(v);
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n.moneyFormatPreview}: '
                '${formatMoneyDisplay(
                  amountMinor: 123456,
                  currencyCode: settings?.primaryCurrency ?? 'RUB',
                  localeName: Localizations.localeOf(context).toString(),
                  format: moneyDisplayFormatFromName(
                    settings?.moneyDisplayFormat,
                  ),
                )}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: tzValue,
                decoration: InputDecoration(labelText: l10n.timeZone),
                isExpanded: true,
                items: [
                  for (final id in selectableTimeZones)
                    DropdownMenuItem(
                      value: id,
                      child: Text(
                        id == kSystemTimeZoneId
                            ? l10n.timeZoneSystem(detectedLocalTimeZoneId)
                            : id,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    ref.read(appSettingsProvider.notifier).setTimeZoneId(v);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  static String _moneyFormatLabel(AppLocalizations l10n, MoneyDisplayFormat f) {
    return switch (f) {
      MoneyDisplayFormat.localeSymbol => l10n.moneyFormatLocaleSymbol,
      MoneyDisplayFormat.localeCode => l10n.moneyFormatLocaleCode,
      MoneyDisplayFormat.plain => l10n.moneyFormatPlain,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final versionLabel = ref.watch(appVersionLabelProvider);
    final theme = Theme.of(context);

    return AppPageScaffold(
      showAddExpenseFab: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.settingsAppearance),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openAppearance(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: Text(l10n.settingsCurrency),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showCurrencySettingsSheet(context),
          ),
          ListTile(
            leading: const Icon(Icons.label_outline),
            title: Text(l10n.tagsTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showTagsSheet(context),
          ),
          ListTile(
            leading: const Icon(Icons.payments_outlined),
            title: Text(l10n.paymentMethodsTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showPaymentMethodsSheet(context),
          ),
          ListTile(
            leading: const Icon(Icons.ios_share),
            title: Text(l10n.settingsExport),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showExportSheet(context),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: Text(l10n.guideOpenFromSettings),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => PlatformGuidePage.open(context),
          ),
          if (versionLabel != null) ...[
            const SizedBox(height: 24),
            Center(
              child: Text(
                versionLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
