import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/integrations/exchange_rate_api/model/exchange_rate_api_integration.dart';
import 'package:valtero/entities/integrations/model/app_integration.dart';
import 'package:valtero/entities/integrations/telegram/model/telegram_integration.dart';
import 'package:valtero/features/integrations/model/integration_ui_meta.dart';
import 'package:valtero/features/integrations/ui/forms/exchange_rate_api_config_form.dart';
import 'package:valtero/features/integrations/ui/forms/telegram_config_form.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';

Future<void> showIntegrationConfigSheet(
  BuildContext context, {
  required AppIntegration integration,
}) {
  return showAppModalSheet(
    context: context,
    child: IntegrationConfigModal(integration: integration),
  );
}

class IntegrationConfigModal extends ConsumerWidget {
  final AppIntegration integration;

  const IntegrationConfigModal({super.key, required this.integration});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final meta = integrationUiMeta(integration.id);
    final scrollController = PrimaryScrollController.maybeOf(context);
    final theme = Theme.of(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Row(
          children: [
            Icon(meta.icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                meta.title(l10n),
                style: theme.textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          meta.description(l10n),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        switch (integration.id) {
          kTelegramIntegrationId => const TelegramConfigForm(),
          kExchangeRateApiIntegrationId => const ExchangeRateApiConfigForm(),
          _ => Text(integration.id),
        },
      ],
    );
  }
}
