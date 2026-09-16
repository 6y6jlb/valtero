import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:valtero/shared/consts/developer_contact.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';
import 'package:valtero/widgets/app_toast.dart';

final Uri _developerMailtoUri = Uri(
  scheme: 'mailto',
  path: DeveloperContact.email,
);

Future<void> showContactDeveloperSheet(BuildContext context) {
  return showAppModalSheet<void>(
    context: context,
    initialChildSize: 0.48,
    minChildSize: 0.35,
    maxChildSize: 0.7,
    child: const _ContactDeveloperSheetBody(),
  );
}

class _ContactDeveloperSheetBody extends StatelessWidget {
  const _ContactDeveloperSheetBody();

  Future<void> _copyEmail(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(
      const ClipboardData(text: DeveloperContact.email),
    );
    if (!context.mounted) return;
    showAppToast(context, l10n.copiedToClipboard);
  }

  Future<void> _sendEmail(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final launched = await launchUrl(
        _developerMailtoUri,
        mode: LaunchMode.externalApplication,
      );
      if (!context.mounted) return;
      if (!launched) {
        showAppToast(context, l10n.contactDeveloperSendFailed);
      }
    } catch (_) {
      if (!context.mounted) return;
      showAppToast(context, l10n.contactDeveloperSendFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AppSheetScaffold(
      header: AppSheetHeader(
        title: l10n.contactDeveloperTitle,
        description: l10n.contactDeveloperDescription,
      ),
      actions: AppSheetActionsBar(
        children: [
          const AppCloseIconButton(),
          AppOutlinedButton(
            label: l10n.contactDeveloperCopyEmail,
            icon: Icons.copy_outlined,
            onPressed: () => _copyEmail(context),
          ),
          AppFilledButton(
            label: l10n.contactDeveloperSendEmail,
            icon: Icons.send_outlined,
            onPressed: () => _sendEmail(context),
          ),
        ],
      ),
      children: [
        Text(
          l10n.contactDeveloperEmailLabel,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SelectableText(
          DeveloperContact.email,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
