import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/flag_icon.dart';

/// Result of currency filter sheet. [code] null means “all currencies”.
class ExpenseCurrencyFilterPick {
  final String? code;

  const ExpenseCurrencyFilterPick(this.code);
}

Future<ExpenseCurrencyFilterPick?> showExpenseCurrencyFilterDialog(
  BuildContext context, {
  required List<String> currencyOptions,
  required String? initialSelection,
}) {
  return showAppModalSheet<ExpenseCurrencyFilterPick>(
    context: context,
    initialChildSize: 0.55,
    minChildSize: 0.35,
    maxChildSize: 0.85,
    child: _ExpenseCurrencyFilterSheet(
      currencyOptions: currencyOptions,
      initialSelection: initialSelection,
    ),
  );
}

class _ExpenseCurrencyFilterSheet extends StatelessWidget {
  final List<String> currencyOptions;
  final String? initialSelection;

  const _ExpenseCurrencyFilterSheet({
    required this.currencyOptions,
    required this.initialSelection,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListView(
      padding: appModalScrollPadding(
        context,
        base: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      ),
      children: [
        Text(
          l10n.filterCurrency,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.all),
          trailing: initialSelection == null
              ? Icon(Icons.check, color: theme.colorScheme.primary)
              : null,
          onTap: () => Navigator.pop(
            context,
            const ExpenseCurrencyFilterPick(null),
          ),
        ),
        for (final code in currencyOptions)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: FlagIcon.currency(code, size: 28),
            title: Text(code),
            trailing: initialSelection == code
                ? Icon(Icons.check, color: theme.colorScheme.primary)
                : null,
            onTap: () => Navigator.pop(
              context,
              ExpenseCurrencyFilterPick(code),
            ),
          ),
      ],
    );
  }
}
