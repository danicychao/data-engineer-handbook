
-- INSERT INTO array_metrices
-- WITH daily_aggregate AS (
-- SELECT
-- user_id,
-- DATE(event_time) as cur_date,
-- COUNT(1) as num_site_hits
-- FROM events
-- WHERE DATE(event_time) = DATE('2023-01-03')
-- AND user_id IS NOT NULL
-- GROUP BY user_id, cur_date
-- ),


-- yesterday_array AS (
-- SELECT * FROM array_metrices
-- WHERE month_start = DATE('2023-01-01')
-- )


-- SELECT
-- COALESCE(da.user_id, y.user_id) as user_id,
-- COALESCE(y.month_start, DATE(DATE_TRUNC('month', DATE(da.cur_date)))) as month_start,
-- 'site_hits' as metric_name,
-- CASE
-- 	 WHEN y.metric_array IS NULL THEN
-- 	 	ARRAY_FILL(0, ARRAY[da.cur_date-DATE(DATE_TRUNC('month', DATE(da.cur_date)))]) || ARRAY[da.num_site_hits]
--      WHEN y.metric_array IS NOT NULL THEN y.metric_array || COALESCE(da.num_site_hits, 0)
-- 	 END as metric_array
-- FROM daily_aggregate da FULL OUTER JOIN yesterday_array y
-- ON da.user_id = y.user_id

-- ON CONFLICT(user_id, month_start, metric_name)
-- DO UPDATE SET metric_array = EXCLUDED.metric_array

WITH agg AS (
SELECT
metric_name,
ARRAY[SUM(metric_array[1]), SUM(metric_array[2]), SUM(metric_array[3])] as summed_array,
month_start
FROM array_metrices
GROUP BY metric_name, month_start
)

SELECT
metric_name, month_start + CAST(index-1 || ' day' AS INTERVAL),
elem
FROM agg
CROSS JOIN UNNEST(agg.summed_array) WITH ORDINALITY AS a(elem, index)
