# Money and currency

## Amounts

- Store and compute money as **integer minor units** (e.g. cents / kopecks).
- Never use `double` as the source of truth for an amount.
- **UI display** goes through [formatMoneyDisplay] / [MoneyText] (`intl` + user
  setting `moneyDisplayFormat`: `localeSymbol` | `localeCode` | `plain`).
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

1. Active keyed provider (ExchangeRate-API) cache/fresh fetch  
2. Frankfurter (no key)  
3. Manual row in `ExchangeRates`  
4. `null` → UI asks the user to enter a rate manually

## Expense persistence

Always persist:

- `originalAmountMinor` + `originalCurrencyCode`
- `storedAmountMinor` + `storedCurrencyCode`
- `rateUsed` (`null` when saved as-is / same currency)
