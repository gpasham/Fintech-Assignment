# SQL Answers

## Q1
### Query
Count transactions by status.
```sql
SELECT status, COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cleaned_transactions), 2) AS pct_of_total
FROM cleaned_transactions GROUP BY status ORDER BY transaction_count DESC;
```
### Result Summary
| status | transaction_count | pct_of_total |
|---|---|---|
| captured | 19 | 63.33% |
| failed | 7 | 23.33% |
| chargeback | 4 | 13.33% |

---

## Q2
### Query
Calculate total captured GMV by merchant.
```sql
SELECT merchant_id, merchant_name, ROUND(SUM(amount_usd),2) AS captured_gmv_usd, COUNT(*) AS captured_count
FROM cleaned_transactions WHERE status='captured'
GROUP BY merchant_id, merchant_name ORDER BY captured_gmv_usd DESC;
```
### Result Summary
| merchant | captured_gmv_usd | captured_count |
|---|---|---|
| Beta Stores | $33,431.00 | 7 |
| Alpha Mart | $29,984.50 | 8 |
| Delta Travels | $10,300.00 | 2 |
| City Pharma | $8,640.00 | 2 |

---

## Q3
### Query
Top 10 merchants by captured GMV.
```sql
SELECT merchant_id, merchant_name, ROUND(SUM(amount_usd),2) AS captured_gmv_usd
FROM cleaned_transactions WHERE status='captured'
GROUP BY merchant_id ORDER BY captured_gmv_usd DESC LIMIT 10;
```
### Result Summary
Only 4 merchants in dataset. Beta Stores leads at $33,431 captured GMV.

---

## Q4
### Query
Daily GMV and successful transaction count.
```sql
SELECT transaction_date, COUNT(*) AS total_txns, ROUND(SUM(amount_usd),2) AS total_gmv,
    SUM(CASE WHEN status='captured' THEN 1 ELSE 0 END) AS success_count,
    ROUND(SUM(CASE WHEN status='captured' THEN amount_usd ELSE 0 END),2) AS captured_gmv
FROM cleaned_transactions GROUP BY transaction_date ORDER BY transaction_date;
```
### Result Summary
| date | total_txns | total_gmv | success_count | captured_gmv |
|---|---|---|---|---|
| 2026-03-01 | 5 | $26,382 | 5 | $26,382 |
| 2026-03-02 | 6 | $25,049 | 3 | $11,080 |
| 2026-03-03 | 5 | $18,391 | 4 | $16,032 |
| 2026-03-04 | 5 | $16,420 | 4 | $13,920 |
| 2026-03-05 | 6 | $19,232 | 1 | $6,136 |
| 2026-03-06 | 3 | $10,606 | 2 | $8,806 |

---

## Q5
### Query
Merchants with chargeback ratio above 1%.
```sql
SELECT merchant_id, merchant_name, COUNT(*) AS total_txns,
    SUM(CASE WHEN status='chargeback' THEN 1 ELSE 0 END) AS cb_count,
    ROUND(SUM(CASE WHEN status='chargeback' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS cb_rate_pct
FROM cleaned_transactions GROUP BY merchant_id
HAVING cb_rate_pct > 1.0 ORDER BY cb_rate_pct DESC;
```
### Result Summary
All 5 merchants exceed 1% chargeback rate. Eco Home is highest at 50% (1/2 txns). Delta Travels 25%, Beta Stores and Alpha Mart both at 9.09%.

---

## Q6
### Query
Regions with average risk score above 50 and more than 20 transactions.
```sql
SELECT gateway_region, COUNT(*) AS txn_count, ROUND(AVG(risk_score),2) AS avg_risk
FROM cleaned_transactions WHERE risk_score IS NOT NULL
GROUP BY gateway_region HAVING avg_risk > 50 AND txn_count > 20;
```
### Result Summary
Only **APAC** qualifies: 21 transactions with avg risk score of 65.48. EU (4 txns) and US (4 txns) don't meet the count threshold.

---

## Q7
### Query
Users with 3 or more failed or chargeback transactions on the same day.
```sql
SELECT user_id, transaction_date, COUNT(*) AS bad_count
FROM cleaned_transactions WHERE status IN ('failed','chargeback')
GROUP BY user_id, transaction_date HAVING bad_count >= 3;
```
### Result Summary
**U008 (Ishaan Verma)** had 4 failed/chargeback transactions on 2026-03-05 — a significant fraud/abuse signal. This user already has a `high` risk tier in the users table.

---

## Q8
### Query
Chargeback count, unique affected users, and chargeback amount by merchant.
```sql
SELECT merchant_id, merchant_name, COUNT(*) AS cb_count,
    COUNT(DISTINCT user_id) AS unique_users,
    ROUND(SUM(amount_usd),2) AS total_cb_usd
FROM cleaned_transactions WHERE status='chargeback'
GROUP BY merchant_id ORDER BY cb_count DESC;
```
### Result Summary
| merchant | cb_count | unique_users | total_cb_usd |
|---|---|---|---|
| Eco Home | 1 | 1 | $6,649.00 |
| Alpha Mart | 1 | 1 | $5,400.00 |
| Delta Travels | 1 | 1 | $2,500.00 |
| Beta Stores | 1 | 1 | $1,711.00 |

Each merchant has exactly 1 chargeback from 1 unique user. Total chargeback exposure: $16,260.
