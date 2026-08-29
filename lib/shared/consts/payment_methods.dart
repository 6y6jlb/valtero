/// Seeded payment-method stable keys (localized at display time).
const List<String> paymentMethodSeedKeys = [
  'cash',
  'card',
  'crypto',
  'transfer',
  'ewallet',
];

/// Default payment method for new expenses when the user has not chosen one.
const String kDefaultPaymentMethodStableKey = 'card';

bool isPaymentMethodStableKey(String? key) =>
    key != null && paymentMethodSeedKeys.contains(key);
