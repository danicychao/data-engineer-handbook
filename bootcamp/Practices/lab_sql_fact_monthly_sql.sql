-- CREATE TABLE array_metrices (
-- 	user_id NUMERIC,
-- 	month_start DATE,
-- 	metric_name TEXT,
-- 	metric_array REAL[],
-- 	PRIMARY KEY (user_id, month_start, metric_name)
-- )


WITH daily_aggregate AS (
SELECT
user_id,
DATE(event_time) as cur_date,
COUNT(1) as num_site_hits
FROM events
WHERE DATE(event_time) = DATE('2023-01-01')
AND user_id IS NOT NULL
GROUP BY user_id, cur_date
),

yesterday_array AS (
SELECT * FROM array_metrices
WHERE month_start = DATE('2023-01-01')
)


SELECT
COALESCE(da.user_id, y.user_id) as user_id,
COALESCE(y.month_start, DATE(DATE_TRUNC('month', DATE(da.cur_date)))) as month_start,
'site_hits' as metric_name,
CASE WHEN y.metric_array IS NULL THEN ARRAY[da.num_site_hits]
     WHEN y.metric_array IS NOT NULL THEN y.metric_array || COALESCE(da.num_site_hits, 0)
	 END as metric_array
FROM daily_aggregate da FULL OUTER JOIN yesterday_array y
ON da.user_id = y.user_id

-- SELECT * FROM events