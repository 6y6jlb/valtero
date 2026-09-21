import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/amount_calculator.dart';
import 'package:valtero/shared/utils/money.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';
import 'package:valtero/widgets/money_text.dart';

/// Opens the amount calculator sheet.
///
/// Returns the resulting amount in minor units, or `null` if cancelled.
Future<int?> showAmountCalculatorSheet(
  BuildContext context, {
  required int baseMinor,
  required String currencyCode,
}) {
  return showAppModalSheet<int>(
    context: context,
    initialChildSize: 0.55,
    minChildSize: 0.35,
    maxChildSize: 0.92,
    child: _AmountCalculatorBody(
      baseMinor: baseMinor,
      currencyCode: currencyCode,
    ),
  );
}

class _AmountCalculatorBody extends StatefulWidget {
  final int baseMinor;
  final String currencyCode;

  const _AmountCalculatorBody({
    required this.baseMinor,
    required this.currencyCode,
  });

  @override
  State<_AmountCalculatorBody> createState() => _AmountCalculatorBodyState();
}

class _AmountCalculatorBodyState extends State<_AmountCalculatorBody> {
  late final TextEditingController _operandController;
  AmountCalculatorOp _op = AmountCalculatorOp.add;

  @override
  void initState() {
    super.initState();
    _operandController = TextEditingController();
    _operandController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _operandController.dispose();
    super.dispose();
  }

  int? get _result => AmountCalculator.apply(
        baseMinor: widget.baseMinor,
        op: _op,
        operand: _operandController.text,
      );

  String? _helperText(AppLocalizations l10n) {
    final trimmed = _operandController.text.trim();
    if (trimmed.isEmpty) return null;

    final result = _result;
    if (result != null) return null;

    if (_op == AmountCalculatorOp.divide &&
        Money.parseMajorToMinor(trimmed) == 0 &&
        RegExp(r'^-?[0.,]+$').hasMatch(trimmed)) {
      return l10n.amountCalculatorErrorDivideByZero;
    }

    final looksNumeric =
        RegExp(r'^-?\d+([.,]\d*)?$|^-?[.,]\d+$').hasMatch(trimmed);
    if (!looksNumeric) return l10n.amountCalculatorErrorEmpty;

    // Parsed but non-positive (or otherwise rejected).
    return l10n.amountCalculatorErrorNonPositive;
  }

  String _opLabel(AppLocalizations l10n, AmountCalculatorOp op) {
    return switch (op) {
      AmountCalculatorOp.add => l10n.amountCalculatorOpAdd,
      AmountCalculatorOp.subtract => l10n.amountCalculatorOpSubtract,
      AmountCalculatorOp.multiply => l10n.amountCalculatorOpMultiply,
      AmountCalculatorOp.divide => l10n.amountCalculatorOpDivide,
      AmountCalculatorOp.percentOf => l10n.amountCalculatorOpPercentOf,
    };
  }

  void _apply() {
    final result = _result;
    if (result == null) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final result = _result;
    final helper = _helperText(l10n);

    return AppSheetScaffold(
      header: AppSheetHeader(title: l10n.amountCalculatorTitle),
      actions: AppSheetActionsBar(
        children: [
          const AppCloseIconButton(),
          AppFilledButton(
            label: l10n.amountCalculatorApply,
            icon: Icons.check,
            onPressed: result == null ? null : _apply,
          ),
        ],
      ),
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.amountCalculatorOriginal),
          trailing: MoneyText(
            amountMinor: widget.baseMinor,
            currencyCode: widget.currencyCode,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _operandController,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          decoration: InputDecoration(
            labelText: l10n.amountCalculatorOperand,
            helperText: helper,
            helperMaxLines: 2,
          ),
          onSubmitted: (_) => _apply(),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AmountCalculatorOp.values.map((op) {
            return ChoiceChip(
              label: Text(_opLabel(l10n, op)),
              selected: _op == op,
              onSelected: (_) => setState(() => _op = op),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.amountCalculatorResult),
          trailing: result == null
              ? Text(
                  '—',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              : MoneyText(
                  amountMinor: result,
                  currencyCode: widget.currencyCode,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}
