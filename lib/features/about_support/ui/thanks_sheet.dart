import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:valtero/shared/consts/developer_contact.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_ok_button.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';
import 'package:valtero/widgets/app_toast.dart';

Future<void> showThanksSheet(BuildContext context) {
  return showAppModalSheet<void>(
    context: context,
    initialChildSize: 0.58,
    minChildSize: 0.35,
    maxChildSize: 0.85,
    child: const _ThanksSheetBody(),
  );
}

class _ThanksSheetBody extends StatelessWidget {
  const _ThanksSheetBody();

  Future<void> _copy(BuildContext context, String value) async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    showAppToast(context, l10n.copiedToClipboard);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final mono = theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace');

    return AppSheetScaffold(
      header: AppSheetHeader(
        title: l10n.thanksTitle,
        description: l10n.thanksDescription,
      ),
      actions: const AppSheetActionsBar(children: [AppOkButton()]),
      children: [
        Text(l10n.thanksEthLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SelectableText(DeveloperContact.ethAddress, style: mono),
        const SizedBox(height: 8),
        AppFilledButton(
          label: l10n.thanksCopyEthAddress,
          icon: Icons.copy_outlined,
          onPressed: () => _copy(context, DeveloperContact.ethAddress),
        ),
        const SizedBox(height: 20),
        Text(l10n.thanksBtcLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SelectableText(DeveloperContact.btcAddress, style: mono),
        const SizedBox(height: 8),
        AppFilledButton(
          label: l10n.thanksCopyBtcAddress,
          icon: Icons.copy_outlined,
          onPressed: () => _copy(context, DeveloperContact.btcAddress),
        ),
      ],
    );
  }
}
