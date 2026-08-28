/// Seeded payment-method stable keys (localized at display time).
const List<String> paymentMethodSeedKeys = [
  'cash',
  'card',
  'crypto',
  'transfer',
  'ewallet',
];

bool isPaymentMethodStableKey(String? key) =>
    key != null && paymentMethodSeedKeys.contains(key);
