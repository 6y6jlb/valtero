import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/money.dart';
import 'package:valtero/widgets/amount_calculator_sheet.dart';

/// Amount field used on add/edit expense and income forms.
///
/// When [showCalculator] is true (edit mode), a calculator suffix icon opens
/// [showAmountCalculatorSheet] and writes the result back via [onCalculated].
class AmountTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool autofocus;
  final bool showCalculator;
  final String currencyCode;
  final ValueChanged<int>? onCalculated;

  const AmountTextField({
    super.key,
    required this.controller,
    this.autofocus = false,
    this.showCalculator = false,
    required this.currencyCode,
    this.onCalculated,
  });

  Future<void> _openCalculator(BuildContext context) async {
    final baseMinor = Money.parseMajorToMinor(controller.text);
    final result = await showAmountCalculatorSheet(
      context,
      baseMinor: baseMinor > 0 ? baseMinor : 0,
      currencyCode: currencyCode,
    );
    if (result == null) return;
    onCalculated?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(
        labelText: l10n.amount,
        suffixIcon: showCalculator
            ? IconButton(
                tooltip: l10n.amountCalculatorTooltip,
                icon: const Icon(Icons.calculate_outlined),
                onPressed: () => _openCalculator(context),
              )
            : null,
      ),
    );
  }
}
