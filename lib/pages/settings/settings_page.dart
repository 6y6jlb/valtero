import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/about_support/ui/contact_developer_sheet.dart';
import 'package:valtero/features/about_support/ui/thanks_sheet.dart';
import 'package:valtero/features/currency_settings/ui/currency_settings_panel.dart';
import 'package:valtero/features/data_sync/ui/data_sync_flow.dart';
import 'package:valtero/features/debug_logs/ui/debug_logs_panel.dart';
import 'package:valtero/features/export_expenses/ui/export_flow.dart';
import 'package:valtero/features/integrations/ui/integrations_settings_section.dart';
import 'package:valtero/features/manage_payment_methods/ui/payment_methods_sheet.dart';
import 'package:valtero/pages/platform_guide/platform_guide_page.dart';
import 'package:valtero/pages/tags/tags_sheet.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/app_version_provider.dart';
import 'package:valtero/shared/utils/date_display.dart';
import 'package:valtero/shared/utils/money_display.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_page_scaffold.dart';
import 'package:valtero/widgets/app_sheet_header.dart';

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
              AppSheetHeader(title: l10n.settingsAppearance),
              const SizedBox(height: 16),
              Text(l10n.theme, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: settings?.themeMode ?? 'system',
                decoration: InputDecoration(labelText: l10n.theme),
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                    value: 'system',
                    child: Row(
                      children: [
                        const Icon(Icons.brightness_auto, size: 20),
                        const SizedBox(width: 12),
                        Text(l10n.system),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'light',
                    child: Row(
                      children: [
                        const Icon(Icons.light_mode_outlined, size: 20),
                        const SizedBox(width: 12),
                        Text(l10n.light),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'dark',
                    child: Row(
                      children: [
                        const Icon(Icons.dark_mode_outlined, size: 20),
                        const SizedBox(width: 12),
                        Text(l10n.dark),
                      ],
                    ),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    ref.read(appSettingsProvider.notifier).setThemeMode(v);
                  }
                },
              ),
              const SizedBox(height: 16),
              Text(l10n.locale, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: settings?.locale ?? 'system',
                decoration: InputDecoration(labelText: l10n.locale),
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                    value: 'system',
                    child: Row(
                      children: [
                        const Icon(Icons.language, size: 20),
                        const SizedBox(width: 12),
                        Text(l10n.system),
                      ],
                    ),
                  ),
                  const DropdownMenuItem(
                    value: 'en',
                    child: Row(
                      children: [
                        Icon(Icons.translate, size: 20),
                        SizedBox(width: 12),
                        Text('English'),
                      ],
                    ),
                  ),
                  const DropdownMenuItem(
                    value: 'ru',
                    child: Row(
                      children: [
                        Icon(Icons.translate, size: 20),
                        SizedBox(width: 12),
                        Text('Русский'),
                      ],
                    ),
                  ),
                  const DropdownMenuItem(
                    value: 'es',
                    child: Row(
                      children: [
                        Icon(Icons.translate, size: 20),
                        SizedBox(width: 12),
                        Text('Español'),
                      ],
                    ),
                  ),
                  const DropdownMenuItem(
                    value: 'sr',
                    child: Row(
                      children: [
                        Icon(Icons.translate, size: 20),
                        SizedBox(width: 12),
                        Text('Srpski'),
                      ],
                    ),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    ref.read(appSettingsProvider.notifier).setLocale(v);
                  }
                },
              ),
              const SizedBox(height: 16),
              Text(
                l10n.moneyFormat,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: moneyDisplayFormatFromName(
                  settings?.moneyDisplayFormat,
                ).name,
                decoration: InputDecoration(labelText: l10n.moneyFormat),
                isExpanded: true,
                items: [
                  for (final format in MoneyDisplayFormat.values)
                    DropdownMenuItem(
                      value: format.name,
                      child: Text(
                        formatMoneyDisplay(
                          amountMinor: 123456,
                          currencyCode: settings?.primaryCurrency ?? 'USD',
                          localeName: Localizations.localeOf(
                            context,
                          ).toString(),
                          format: format,
                        ),
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
              const SizedBox(height: 16),
              Text(
                l10n.dateFormat,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: dateDisplayFormatFromName(
                  settings?.dateDisplayFormat,
                ).name,
                decoration: InputDecoration(labelText: l10n.dateFormat),
                isExpanded: true,
                items: [
                  for (final format in DateDisplayFormat.values)
                    DropdownMenuItem(
                      value: format.name,
                      child: Text(
                        formatDateDisplay(
                          instant: DateTime(2026, 1, 15),
                          timeZoneId: selectedTz,
                          format: format,
                          localeName: Localizations.localeOf(
                            context,
                          ).toString(),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setDateDisplayFormat(v);
                  }
                },
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
            leading: const Icon(Icons.extension_outlined),
            title: Text(l10n.settingsIntegrations),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showIntegrationsSheet(context),
          ),
          ListTile(
            leading: const Icon(Icons.ios_share),
            title: Text(l10n.settingsExport),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showExportSheet(context),
          ),
          ListTile(
            leading: const Icon(Icons.sync_outlined),
            title: Text(l10n.settingsDataSync),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showDataSyncSheet(context),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: Text(l10n.guideOpenFromSettings),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => PlatformGuidePage.open(context),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_outline),
            title: Text(l10n.settingsThanks),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showThanksSheet(context),
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(l10n.settingsContactDeveloper),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showContactDeveloperSheet(context),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: Text(l10n.settingsDebug),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showDebugLogsSheet(context),
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
