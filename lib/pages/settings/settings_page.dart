import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/features/currency_settings/ui/currency_settings_panel.dart';
import 'package:valtero/features/export_expenses/ui/export_flow.dart';
import 'package:valtero/pages/tags/tags_sheet.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/app_timezone.dart';
import 'package:valtero/shared/utils/app_version_provider.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _openAppearance(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return showAppModalSheet(
      context: context,
      initialChildSize: 0.65,
      minChildSize: 0.4,
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
    final versionAsync = ref.watch(appVersionLabelProvider);
    final theme = Theme.of(context);

    return Scaffold(
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
            leading: const Icon(Icons.ios_share),
            title: Text(l10n.settingsExport),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showExportSheet(context),
          ),
          const SizedBox(height: 24),
          Center(
            child: versionAsync.when(
              data: (label) => Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
