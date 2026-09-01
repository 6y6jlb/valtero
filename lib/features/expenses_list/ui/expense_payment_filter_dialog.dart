import 'package:flutter/material.dart';
import 'package:valtero/entities/payment_method/ui/payment_method_chip.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';

Future<Set<int>?> showExpensePaymentFilterDialog(
  BuildContext context, {
  required List<PaymentMethod> methods,
  required Set<int> initialSelection,
}) {
  return showAppModalSheet<Set<int>>(
    context: context,
    initialChildSize: 0.55,
    minChildSize: 0.35,
    maxChildSize: 0.85,
    child: _ExpensePaymentFilterSheet(
      methods: methods,
      initialSelection: initialSelection,
    ),
  );
}

class _ExpensePaymentFilterSheet extends StatefulWidget {
  final List<PaymentMethod> methods;
  final Set<int> initialSelection;

  const _ExpensePaymentFilterSheet({
    required this.methods,
    required this.initialSelection,
  });

  @override
  State<_ExpensePaymentFilterSheet> createState() =>
      _ExpensePaymentFilterSheetState();
}

class _ExpensePaymentFilterSheetState
    extends State<_ExpensePaymentFilterSheet> {
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelection};
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppSheetScaffold(
      header: AppSheetHeader(title: l10n.filterPayment),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: AppSheetActionsBar(
        children: [
          AppTextButton(
            onPressed: () => setState(() => _selected.clear()),
            label: l10n.clearFilters,
          ),
          AppCloseIconButton(onPressed: () => Navigator.pop(context)),
          AppFilledButton(
            onPressed: () => Navigator.pop(context, Set<int>.from(_selected)),
            icon: Icons.check,
            label: l10n.ok,
          ),
        ],
      ),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final method in widget.methods)
              PaymentMethodChip(
                method: method,
                selected: _selected.contains(method.id),
                onTap: () {
                  setState(() {
                    if (_selected.contains(method.id)) {
                      _selected.remove(method.id);
                    } else {
                      _selected.add(method.id);
                    }
                  });
                },
              ),
          ],
        ),
      ],
    );
  }
}
