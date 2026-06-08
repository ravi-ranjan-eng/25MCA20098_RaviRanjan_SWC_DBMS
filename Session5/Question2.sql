-- SELECT * FROM transactions;
WITH analyzed_transactions AS (
SELECT 
transaction_timestamp,
LAG(transaction_timestamp) OVER(
PARTITION BY merchant_id, credit_card_id, amount 
ORDER BY transaction_timestamp
) AS previous_transaction_timestamp
FROM transactions
)
SELECT COUNT(*) AS payment_count
FROM analyzed_transactions
WHERE transaction_timestamp - previous_transaction_timestamp <= INTERVAL '10 minutes';
