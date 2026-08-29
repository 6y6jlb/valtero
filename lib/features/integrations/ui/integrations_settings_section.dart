import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/features/integrations/model/integration_ui_meta.dart';
import 'package:valtero/features/integrations/ui/integration_config_modal.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';

Future<void> showIntegrationsSheet(BuildContext context) {
  return showAppModalSheet(
    context: context,
    child: const IntegrationsSettingsSection(),
  );
}

class IntegrationsSettingsSection extends ConsumerWidget {
  const IntegrationsSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final integrations = ref.watch(integrationsProvider);
    final settings = ref.watch(appSettingsProvider).value;
    final scrollController = PrimaryScrollController.maybeOf(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Text(l10n.settingsIntegrations, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final integration in integrations) ...[
          Builder(
            builder: (context) {
              final meta = integrationUiMeta(integration.id);
              final connected =
                  settings != null && integration.isConfigured(settings);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(meta.icon),
                title: Text(meta.title(l10n)),
                subtitle: Text(meta.description(l10n)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(
                        connected
                            ? l10n.integrationConnected
                            : l10n.integrationNotConnected,
                        style: theme.textTheme.labelSmall,
                      ),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: connected
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => showIntegrationConfigSheet(
                  context,
                  integration: integration,
                ),
              );
            },
          ),
          const Divider(height: 1),
        ],
      ],
    );
  }
}
