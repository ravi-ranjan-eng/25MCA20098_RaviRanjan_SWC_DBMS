WITH RECURSIVE date_series AS (
    SELECT '2025-04-15'::DATE AS transaction_date
    UNION ALL
    SELECT (transaction_date + INTERVAL '1 day')::DATE
    FROM date_series
    WHERE transaction_date < '2025-04-28'
),
valid_purchases AS (
    SELECT 
        transaction_id,
        transaction_date,
        amount
    FROM product_sales
    WHERE product_id = 'PROD-2891'
      AND country = 'US'
      AND transaction_date BETWEEN '2025-04-15' AND '2025-04-28'
      AND original_transaction_id IS NULL 
),
linked_refunds AS (
    
    SELECT 
        p.transaction_date, 
        SUM(r.amount) AS total_refunded
    FROM valid_purchases p
    JOIN product_sales r ON p.transaction_id = r.original_transaction_id
    GROUP BY p.transaction_date
),
daily_calc AS (
    SELECT 
        p.transaction_date,
        SUM(p.amount) - COALESCE((SELECT total_refunded FROM linked_refunds l WHERE l.transaction_date = p.transaction_date), 0) AS net_rev
    FROM valid_purchases p
    GROUP BY p.transaction_date
)

SELECT 
    ds.transaction_date,
    COALESCE(dc.net_rev, 0) AS daily_net_revenue
FROM date_series ds
LEFT JOIN daily_calc dc ON ds.transaction_date = dc.transaction_date
ORDER BY ds.transaction_date;
