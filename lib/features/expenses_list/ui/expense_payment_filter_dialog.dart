import 'package:flutter/material.dart';
import 'package:valtero/entities/payment_method/ui/payment_method_chip.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';

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

class _ExpensePaymentFilterSheetState extends State<_ExpensePaymentFilterSheet> {
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelection};
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Text(
          l10n.filterPayment,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => setState(() => _selected.clear()),
              child: Text(l10n.clearFilters),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => Navigator.pop(context, Set<int>.from(_selected)),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        ),
      ],
    );
  }
}
