WITH monthly_stats AS (
    SELECT 
        product_name,
        month_start,
        monthly_active_users,
        LAG(monthly_active_users, 1) OVER (PARTITION BY product_name ORDER BY month_start) AS prev_1,
        LAG(monthly_active_users, 2) OVER (PARTITION BY product_name ORDER BY month_start) AS prev_2,
        LAG(monthly_active_users, 3) OVER (PARTITION BY product_name ORDER BY month_start) AS prev_3,
        LEAD(monthly_active_users, 1) OVER (PARTITION BY product_name ORDER BY month_start) AS next_1,
        LEAD(monthly_active_users, 2) OVER (PARTITION BY product_name ORDER BY month_start) AS next_2,
        LEAD(monthly_active_users, 3) OVER (PARTITION BY product_name ORDER BY month_start) AS next_3,
        LAG(month_start, 3) OVER (PARTITION BY product_name ORDER BY month_start) AS decline_start,
        LEAD(month_start, 1) OVER (PARTITION BY product_name ORDER BY month_start) AS growth_resumed
    FROM product_engagement
),
turnaround_matches AS (
    SELECT 
        product_name,
        decline_start,
        growth_resumed AS growth_resumed_month,
        monthly_active_users AS lowest_users,
        next_3 AS peak_users
    FROM monthly_stats
    WHERE 
        prev_3 > prev_2 AND prev_2 > prev_1 AND prev_1 > monthly_active_users
        AND 
        monthly_active_users < next_1 AND next_1 < next_2 AND next_2 < next_3
)
SELECT 
    product_name,
    decline_start,
    growth_resumed_month,
    ROUND(((peak_users - lowest_users)::numeric / lowest_users), 2) AS growth_ratio
FROM turnaround_matches;
