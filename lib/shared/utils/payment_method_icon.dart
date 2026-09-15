import 'package:flutter/material.dart';

/// Material icon for a seeded payment-method [stableKey], if known.
IconData? iconDataForPaymentStableKey(String? stableKey) {
  if (stableKey == null || stableKey.isEmpty) return null;
  return switch (stableKey) {
    'cash' => Icons.payments_outlined,
    'card' => Icons.credit_card,
    'crypto' => Icons.currency_bitcoin,
    'transfer' => Icons.account_balance_outlined,
    'ewallet' => Icons.account_balance_wallet_outlined,
    _ => null,
  };
}
