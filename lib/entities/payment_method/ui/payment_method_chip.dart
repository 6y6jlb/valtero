import 'package:flutter/material.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/utils/payment_method_label.dart';

class PaymentMethodChip extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final VoidCallback? onTap;

  const PaymentMethodChip({
    super.key,
    required this.method,
    this.selected = false,
    this.onTap,
  });

  IconData? get _icon => switch (method.stableKey) {
        'cash' => Icons.payments_outlined,
        'card' => Icons.credit_card,
        'crypto' => Icons.currency_bitcoin,
        'transfer' => Icons.account_balance_outlined,
        'ewallet' => Icons.account_balance_wallet_outlined,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final color =
        method.colorValue != null ? Color(method.colorValue!) : null;
    final label = localizedPaymentMethodLabel(context, method);
    final icon = _icon;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
      selectedColor: color?.withValues(alpha: 0.35),
      avatar: icon != null
          ? Icon(icon, size: 18)
          : (color != null
              ? CircleAvatar(backgroundColor: color, radius: 8)
              : null),
    );
  }
}
