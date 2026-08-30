# Money and currency

## Amounts

- Store and compute money as **integer minor units** (e.g. cents / kopecks).
- Never use `double` as the source of truth for an amount.
- **UI display** goes through [formatMoneyDisplay] / [MoneyText] (`intl` + user
  setting `moneyDisplayFormat`: `localeSymbol` | `localeCode` | `isoBefore` |
  `plain` | `compactSymbol`). Appearance dropdown shows **live examples** of each
  format (not long labels).
- **Export / interchange** keeps [Money.formatMinor] (dot decimals, no grouping)
  so files stay locale-stable.

```dart
// ❌ BAD
final total = 10.5 * rate;
Text('${Money.formatMinor(minor)} $code'); // in UI — bypasses display prefs

// ✅ GOOD
final storedMinor = Money.convertMinor(
  originalMinor: 1050,
  rate: rate,
);
MoneyText(amountMinor: storedMinor, currencyCode: 'USD');
```

## Rate resolution (`RateResolver.getRate`)

1. Active keyed provider (ExchangeRate-API) cache/fresh fetch — only when the ExchangeRate-API **integration** is connected (API key in Settings → Integrations)
2. Frankfurter (no key; always listed under Integrations as a built-in connected source)  
3. Manual row in `ExchangeRates`  
4. `null` → UI asks the user to enter a rate manually

## Expense persistence

Always persist:

- `originalAmountMinor` + `originalCurrencyCode`
- `storedAmountMinor` + `storedCurrencyCode`
- `rateUsed` (`null` when saved as-is / same currency)
- optional `countryCode` (ISO 3166-1 alpha-2) and `paymentMethodId`
