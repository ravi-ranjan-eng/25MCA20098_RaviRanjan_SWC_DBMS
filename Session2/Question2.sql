WITH dataset_cutoff AS (
    SELECT MAX(registration_date) - INTERVAL '30 days' AS cutoff_date
    FROM accounts
),

user_segments AS (
    SELECT 
        user_id,
        CASE 
            WHEN registration_date >= (SELECT cutoff_date FROM dataset_cutoff) THEN 'new'
            ELSE 'existing'
        END AS user_segment
    FROM accounts
),

search_clicks AS (
    SELECT 
        s.user_id,
        s.event_id AS search_event_id,
        s.event_timestamp AS search_time,
        MIN(c.event_timestamp) AS first_click_time
    FROM search_events s
    LEFT JOIN search_events c 
        ON s.session_id = c.session_id 
        AND c.event_type = 'click' 
        AND c.event_timestamp > s.event_timestamp
    WHERE s.event_type = 'search'
    GROUP BY s.user_id, s.event_id, s.event_timestamp
)

SELECT 
    u.user_segment,
    COUNT(sc.search_event_id) AS total_searches,
    SUM(CASE WHEN sc.first_click_time <= sc.search_time + INTERVAL '30 seconds' THEN 1 ELSE 0 END) AS successful_searches,
    SUM(CASE WHEN sc.first_click_time <= sc.search_time + INTERVAL '30 seconds' THEN 1 ELSE 0 END)::float / COUNT(sc.search_event_id) AS success_rate
FROM search_clicks sc
JOIN user_segments u ON sc.user_id = u.user_id
GROUP BY u.user_segment;
