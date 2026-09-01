import 'package:flutter/material.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';
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

class _ExpenseCurrencyFilterSheet extends StatefulWidget {
  final List<String> currencyOptions;
  final String? initialSelection;

  const _ExpenseCurrencyFilterSheet({
    required this.currencyOptions,
    required this.initialSelection,
  });

  @override
  State<_ExpenseCurrencyFilterSheet> createState() =>
      _ExpenseCurrencyFilterSheetState();
}

class _ExpenseCurrencyFilterSheetState extends State<_ExpenseCurrencyFilterSheet> {
  late String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return AppSheetScaffold(
      header: AppSheetHeader(title: l10n.filterCurrency),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: AppSheetActionsBar(
        children: [
          AppTextButton(
            onPressed: () => setState(() => _selected = null),
            label: l10n.clearFilters,
          ),
          AppCloseIconButton(onPressed: () => Navigator.pop(context)),
          AppFilledButton(
            onPressed: () =>
                Navigator.pop(context, ExpenseCurrencyFilterPick(_selected)),
            icon: Icons.check,
            label: l10n.ok,
          ),
        ],
      ),
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.all),
          trailing: _selected == null
              ? Icon(Icons.check, color: theme.colorScheme.primary)
              : null,
          onTap: () => setState(() => _selected = null),
        ),
        for (final code in widget.currencyOptions)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: FlagIcon.currency(code, size: 28),
            title: Text(code),
            trailing: _selected == code
                ? Icon(Icons.check, color: theme.colorScheme.primary)
                : null,
            onTap: () => setState(() => _selected = code),
          ),
      ],
    );
  }
}
