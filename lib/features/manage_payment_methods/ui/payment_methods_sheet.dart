import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valtero/entities/payment_method/model/payment_methods_provider.dart';
import 'package:valtero/features/manage_payment_methods/model/manage_payment_methods_controller.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/settings/app_settings_provider.dart';
import 'package:valtero/shared/utils/payment_method_label.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';
import 'package:valtero/widgets/tag_color_picker.dart';

Future<void> showPaymentMethodsSheet(BuildContext context) {
  return showAppModalSheet(
    context: context,
    child: const PaymentMethodsSheetBody(),
  );
}

class PaymentMethodsSheetBody extends ConsumerWidget {
  const PaymentMethodsSheetBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final methods = ref.watch(paymentMethodsStreamProvider).value ?? const [];
    final settings = ref.watch(appSettingsProvider).value;
    final defaultId = settings?.defaultPaymentMethodId;

    return AppSheetScaffold(
      header: AppSheetHeader(
        title: l10n.paymentMethodsTitle,
        description: l10n.paymentMethodsHint,
      ),
      actions: AppSheetActionsBar(
        children: [
          const AppCloseIconButton(),
          AppFilledButton.tonal(
            onPressed: () async {
              final result = await showTagEditDialog(
                context,
                title: l10n.paymentMethodNew,
                confirmLabel: l10n.add,
              );
              if (result == null) return;
              await ref
                  .read(managePaymentMethodsControllerProvider)
                  .addCustom(name: result.name, colorValue: result.colorValue);
            },
            icon: Icons.add,
            label: l10n.paymentMethodAdd,
          ),
        ],
      ),
      children: [
        const SizedBox(height: 4),
        for (final method in methods)
          ListTile(
            leading: CircleAvatar(
              backgroundColor: method.colorValue != null
                  ? Color(method.colorValue!)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              radius: 12,
            ),
            title: Text(localizedPaymentMethodLabel(context, method)),
            subtitle: method.isDefault ? Text(l10n.paymentMethodBuiltIn) : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<int?>(
                  value: method.id,
                  // ignore: deprecated_member_use
                  groupValue: defaultId,
                  // ignore: deprecated_member_use
                  onChanged: (v) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setDefaultPaymentMethodId(v);
                  },
                ),
                if (!method.isDefault)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      ref
                          .read(managePaymentMethodsControllerProvider)
                          .delete(method.id);
                    },
                  ),
              ],
            ),
            onTap: () async {
              final currentLabel = localizedPaymentMethodLabel(context, method);
              final result = await showTagEditDialog(
                context,
                title: l10n.paymentMethodEdit,
                initialName: currentLabel,
                initialColor: method.colorValue,
                confirmLabel: l10n.save,
              );
              if (result == null) return;
              final controller = ref.read(
                managePaymentMethodsControllerProvider,
              );
              await controller.setColor(method, result.colorValue);
              if (result.name != currentLabel) {
                await controller.rename(method, result.name);
              }
            },
          ),
        if (defaultId != null)
          TextButton(
            onPressed: () {
              ref
                  .read(appSettingsProvider.notifier)
                  .setDefaultPaymentMethodId(null);
            },
            child: Text(l10n.paymentMethodClearDefault),
          ),
      ],
    );
  }
}
