WITH cleaned_tasks AS (
    SELECT DISTINCT 
        task_id,
        start_time, 
        end_time
    FROM task_schedule
    WHERE start_time IS NOT NULL 
      AND end_time IS NOT NULL
),
time_events AS (
    SELECT start_time AS event_time, 1 AS cpu_delta
    FROM cleaned_tasks
    UNION ALL
    SELECT end_time AS event_time, -1 AS cpu_delta
    FROM cleaned_tasks
),
running_totals AS (
    SELECT 
        SUM(cpu_delta) OVER(
            ORDER BY event_time ASC, 
                     cpu_delta ASC
        ) AS concurrent_cpus
    FROM time_events
)
SELECT MAX(concurrent_cpus) AS min_cpus
FROM running_totals;
