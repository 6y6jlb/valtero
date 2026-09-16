import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/model/integration_registry.dart';
import 'package:valtero/features/integrations/model/integration_ui_meta.dart';
import 'package:valtero/features/integrations/ui/integration_config_modal.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';

Future<void> showIntegrationsSheet(
  BuildContext context, {
  VoidCallback? onSuggestIntegration,
}) {
  return showAppModalSheet(
    context: context,
    child: IntegrationsSettingsSection(
      onSuggestIntegration: onSuggestIntegration,
    ),
  );
}

class IntegrationsSettingsSection extends ConsumerWidget {
  final VoidCallback? onSuggestIntegration;

  const IntegrationsSettingsSection({
    super.key,
    this.onSuggestIntegration,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final integrations = ref.watch(integrationsProvider);
    final settings = ref.watch(appSettingsProvider).value;

    return AppSheetScaffold(
      header: AppSheetHeader(title: l10n.settingsIntegrations),
      actions: const AppSheetActionsBar(children: [AppCloseIconButton()]),
      children: [
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
        if (onSuggestIntegration != null) ...[
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.lightbulb_outline,
              color: theme.colorScheme.primary,
            ),
            title: Text(l10n.integrationsSuggest),
            subtitle: Text(l10n.integrationsSuggestHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: onSuggestIntegration,
          ),
        ],
      ],
    );
  }
}
