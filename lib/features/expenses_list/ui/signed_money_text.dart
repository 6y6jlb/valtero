import 'package:flutter/material.dart';
import 'package:valtero/widgets/money_text.dart';

/// Money with an explicit `+` / `−` sign and a direction tint, used across the
/// cash-flow list (rows, group net column, summary net line) where a single
/// column mixes inflows and outflows.
class SignedMoneyText extends StatelessWidget {
  /// Positive = inflow (income), negative = outflow (expense).
  final int signedAmountMinor;
  final String currencyCode;
  final TextStyle? style;

  /// When false the amount keeps the ambient text color (sign only).
  final bool tinted;

  const SignedMoneyText({
    super.key,
    required this.signedAmountMinor,
    required this.currencyCode,
    this.style,
    this.tinted = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isOutflow = signedAmountMinor < 0;
    final color = !tinted || signedAmountMinor == 0
        ? null
        : (isOutflow ? scheme.error : scheme.tertiary);
    final effectiveStyle = style?.copyWith(color: color) ??
        (color == null ? null : TextStyle(color: color));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (signedAmountMinor != 0)
          Text(isOutflow ? '−' : '+', style: effectiveStyle),
        Flexible(
          child: MoneyText(
            amountMinor: signedAmountMinor.abs(),
            currencyCode: currencyCode,
            style: effectiveStyle,
          ),
        ),
      ],
    );
  }
}
