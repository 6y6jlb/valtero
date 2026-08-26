import 'package:flutter/material.dart';
import 'package:valtero/shared/utils/money.dart';

class MoneyText extends StatelessWidget {
  final int amountMinor;
  final String currencyCode;
  final TextStyle? style;

  const MoneyText({
    super.key,
    required this.amountMinor,
    required this.currencyCode,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '${Money.formatMinor(amountMinor)} $currencyCode',
      style: style,
    );
  }
}
