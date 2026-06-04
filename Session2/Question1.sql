WITH unique_dates AS (
    SELECT DISTINCT 
        user_id, 
        created_at::date AS purchase_date
    FROM amazon_transactions
),
ranked_purchases AS (
    SELECT 
        user_id, 
        purchase_date,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY purchase_date) as purchase_rank
    FROM unique_dates
)
SELECT DISTINCT 
    r1.user_id
FROM ranked_purchases r1
JOIN ranked_purchases r2 ON r1.user_id = r2.user_id
WHERE r1.purchase_rank = 1 
  AND r2.purchase_rank = 2
  AND r2.purchase_date - r1.purchase_date BETWEEN 1 AND 7;
