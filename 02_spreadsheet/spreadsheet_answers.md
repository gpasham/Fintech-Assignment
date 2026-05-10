# Spreadsheet Answers

## Cleaning Steps

1. **Merchant Names**: Stripped leading/trailing whitespace, collapsed multiple internal spaces, converted to Title Case, then mapped to canonical names from `merchant_master.csv`.
2. **Date Formats**: Parsed with `pd.to_datetime()` and standardized to `YYYY-MM-DD` ISO format.
3. **Status Values**: Lowercased and stripped; `captured*` → `captured`; `*chargeback*` → `chargeback`; `*failed*` or `*e05*` → `failed`.
4. **Risk Scores**: Extracted numeric digits from messy strings (`score:62` → 62, `risk-83` → 83, `59 ` → 59). Empty → NaN.
5. **Gateway Region**: Stripped and uppercased. Empty values backfilled from `merchant_master.default_region`.
6. **Currencies to USD**: Left-joined `exchange_rates.csv` on `(transaction_date, currency)`; multiplied `raw_amount × usd_rate`.

## Standardization Rules

| Field | Input Examples | Standardized |
|---|---|---|
| merchant_name | ` alpha mart `, `ALPHA MART`, `Alpha  Mart` | `Alpha Mart` |
| status | `Captured `, ` CAPTURED`, `captured` | `captured` |
| status | `failed e05 timeout`, `Failed E05 Timeout` | `failed` |
| status | ` chargeback ` | `chargeback` |
| risk_score | `score:62`, `risk-83`, `59 ` | 62, 83, 59 |
| gateway_region | ` APAC `, `apac` | `APAC` |

## Lookup and Enrichment Logic

- **merchant_id, merchant_category, merchant_region**: `VLOOKUP`-style merge on `merchant_name` against `merchant_master.csv`.
- **amount_usd**: Matched on `(transaction_date, currency)` from `exchange_rates.csv` and applied rate.
- **high_value_flag = 1** when: APAC & amount_usd > 5000 | EU & amount_usd > 6000 | US & amount_usd > 7000; else 0.
- **high_risk_flag = 1** when: risk_score ≥ 70 OR status = 'chargeback'; else 0.

## Final Answers

- **Total raw rows**: 30
- **Total cleaned rows**: 30
- **Invalid/missing rows handled**: 0 dropped (all rows retained; missing risk scores left as NaN)
- **Top region by GMV**: APAC (22 transactions, ~$116,080 USD)
- **Number of high value transactions**: 7
- **Number of high risk transactions**: 8
- **Top merchant by captured GMV**: Beta Stores ($33,431 USD)

## Formula Samples

```excel
# Amount USD conversion (Excel VLOOKUP equivalent):
=VLOOKUP(A2&C2, exchange_rates!$A:$C, 3, 0) * D2

# high_value_flag:
=IF(AND(G2="APAC", J2>5000), 1, IF(AND(G2="EU", J2>6000), 1, IF(AND(G2="US", J2>7000), 1, 0)))

# high_risk_flag:
=IF(OR(L2>=70, K2="chargeback"), 1, 0)

# Merchant risk summary - captured GMV:
=SUMIFS(cleaned_transactions!J:J, cleaned_transactions!C:C, A2, cleaned_transactions!K:K, "captured")
```
