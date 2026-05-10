-- QuickPay SQL Business Analysis
-- Table: cleaned_transactions (loaded from 01_data/processed/cleaned_transactions.csv)
-- Columns: transaction_id, transaction_date, merchant_id, merchant_name, merchant_category,
--          merchant_region, gateway_region, raw_amount, currency, amount_usd,
--          status, risk_score, payment_method, user_id, high_value_flag, high_risk_flag

-- Q1: Count transactions by status
SELECT
    status,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM cleaned_transactions
GROUP BY status
ORDER BY transaction_count DESC;

-- Q2: Calculate total captured GMV by merchant
SELECT
    merchant_id,
    merchant_name,
    merchant_region,
    ROUND(SUM(amount_usd), 2) AS captured_gmv_usd,
    COUNT(*) AS captured_count
FROM cleaned_transactions
WHERE status = 'captured'
GROUP BY merchant_id, merchant_name, merchant_region
ORDER BY captured_gmv_usd DESC;

-- Q3: Show top 10 merchants by captured GMV
SELECT
    merchant_id,
    merchant_name,
    ROUND(SUM(amount_usd), 2) AS captured_gmv_usd,
    COUNT(*) AS captured_txns
FROM cleaned_transactions
WHERE status = 'captured'
GROUP BY merchant_id, merchant_name
ORDER BY captured_gmv_usd DESC
LIMIT 10;

-- Q4: Show daily GMV and successful transaction count
SELECT
    transaction_date,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount_usd), 2) AS total_gmv_usd,
    SUM(CASE WHEN status = 'captured' THEN 1 ELSE 0 END) AS successful_count,
    ROUND(SUM(CASE WHEN status = 'captured' THEN amount_usd ELSE 0 END), 2) AS captured_gmv_usd
FROM cleaned_transactions
GROUP BY transaction_date
ORDER BY transaction_date;

-- Q5: Find merchants with chargeback ratio above 1%
SELECT
    merchant_id,
    merchant_name,
    COUNT(*) AS total_txns,
    SUM(CASE WHEN status = 'chargeback' THEN 1 ELSE 0 END) AS chargeback_count,
    ROUND(SUM(CASE WHEN status = 'chargeback' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS chargeback_rate_pct
FROM cleaned_transactions
GROUP BY merchant_id, merchant_name
HAVING chargeback_rate_pct > 1.0
ORDER BY chargeback_rate_pct DESC;

-- Q6: Find regions with average risk score above 50 and more than 20 transactions
SELECT
    gateway_region,
    COUNT(*) AS transaction_count,
    ROUND(AVG(risk_score), 2) AS avg_risk_score,
    SUM(high_risk_flag) AS high_risk_count
FROM cleaned_transactions
WHERE risk_score IS NOT NULL
GROUP BY gateway_region
HAVING avg_risk_score > 50 AND transaction_count > 20
ORDER BY avg_risk_score DESC;

-- Q7: Find users with 3 or more failed or chargeback transactions on the same day
SELECT
    user_id,
    transaction_date,
    COUNT(*) AS bad_txn_count,
    GROUP_CONCAT(transaction_id) AS transaction_ids
FROM cleaned_transactions
WHERE status IN ('failed', 'chargeback')
GROUP BY user_id, transaction_date
HAVING bad_txn_count >= 3
ORDER BY bad_txn_count DESC;

-- Q8: Show chargeback count, unique affected users, and chargeback amount by merchant
SELECT
    merchant_id,
    merchant_name,
    COUNT(*) AS chargeback_count,
    COUNT(DISTINCT user_id) AS unique_affected_users,
    ROUND(SUM(amount_usd), 2) AS total_chargeback_amount_usd
FROM cleaned_transactions
WHERE status = 'chargeback'
GROUP BY merchant_id, merchant_name
ORDER BY chargeback_count DESC;
