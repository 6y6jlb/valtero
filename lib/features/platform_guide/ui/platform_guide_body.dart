import 'package:flutter/material.dart';
import 'package:valtero/features/platform_guide/ui/platform_guide_section.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

/// Shared platform capabilities guide (empty dashboard + Settings entry).
class PlatformGuideBody extends StatelessWidget {
  final bool showHeader;
  final EdgeInsetsGeometry padding;
  final ScrollController? controller;

  const PlatformGuideBody({
    super.key,
    this.showHeader = true,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 96),
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListView(
      controller: controller,
      padding: padding,
      children: [
        if (showHeader) ...[
          Text(l10n.guideTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            l10n.guideSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
        ],
        PlatformGuideSection(
          icon: Icons.play_circle_outline,
          title: l10n.guideSectionGettingStartedTitle,
          body: l10n.guideSectionGettingStartedBody,
        ),
        PlatformGuideSection(
          icon: Icons.receipt_long_outlined,
          title: l10n.guideSectionExpenseTrackingTitle,
          body: l10n.guideSectionExpenseTrackingBody,
        ),
        PlatformGuideSection(
          icon: Icons.label_outline,
          title: l10n.guideSectionTagsTitle,
          body: l10n.guideSectionTagsBody,
        ),
        PlatformGuideSection(
          icon: Icons.pie_chart_outline,
          title: l10n.guideSectionChartsTitle,
          body: l10n.guideSectionChartsBody,
        ),
        PlatformGuideSection(
          icon: Icons.currency_exchange,
          title: l10n.guideSectionExchangeRatesTitle,
          body: l10n.guideSectionExchangeRatesBody,
        ),
        PlatformGuideSection(
          icon: Icons.ios_share_outlined,
          title: l10n.guideSectionExportTitle,
          body: l10n.guideSectionExportBody,
        ),
        PlatformGuideSection(
          icon: Icons.sync_outlined,
          title: l10n.guideSectionDataSyncTitle,
          body: l10n.guideSectionDataSyncBody,
        ),
        PlatformGuideSection(
          icon: Icons.send_outlined,
          title: l10n.guideSectionTelegramTitle,
          body: l10n.guideSectionTelegramBody,
        ),
        PlatformGuideSection(
          icon: Icons.extension_outlined,
          title: l10n.guideSectionIntegrationsTitle,
          body: l10n.guideSectionIntegrationsBody,
        ),
        PlatformGuideSection(
          icon: Icons.bug_report_outlined,
          title: l10n.guideSectionDebugTitle,
          body: l10n.guideSectionDebugBody,
        ),
        PlatformGuideSection(
          icon: Icons.filter_list,
          title: l10n.guideSectionFiltersTitle,
          body: l10n.guideSectionFiltersBody,
        ),
        PlatformGuideSection(
          icon: Icons.mic_outlined,
          title: l10n.guideSectionVoiceExpenseTitle,
          body: l10n.guideSectionVoiceExpenseBody,
        ),
      ],
    );
  }
}
