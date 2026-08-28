import 'package:flutter/material.dart';
import 'package:valtero/entities/payment_method/ui/payment_method_chip.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';

Future<Set<int>?> showExpensePaymentFilterDialog(
  BuildContext context, {
  required List<PaymentMethod> methods,
  required Set<int> initialSelection,
}) {
  final l10n = AppLocalizations.of(context)!;
  final selected = {...initialSelection};
  return showDialog<Set<int>>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setLocal) {
          return AlertDialog(
            title: Text(l10n.filterPayment),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final method in methods)
                      PaymentMethodChip(
                        method: method,
                        selected: selected.contains(method.id),
                        onTap: () {
                          setLocal(() {
                            if (selected.contains(method.id)) {
                              selected.remove(method.id);
                            } else {
                              selected.add(method.id);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => setLocal(() => selected.clear()),
                child: Text(l10n.clearFilters),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, Set<int>.from(selected)),
                child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
              ),
            ],
          );
        },
      );
    },
  );
}
