-- CREATE TABLE user_devices_cumulated (
--     user_id NUMERIC,
-- 	device_activity_datelist JSON,
-- 	PRIMARY KEY (user_id)
-- );

INSERT INTO user_devices_cumulated
WITH user_row AS (
SELECT
user_id,
device_id,
event_time,
ROW_NUMBER() OVER (PARTITION BY user_id, device_id, event_time ORDER BY event_time) as row_num
FROM events
WHERE user_id IS NOT NULL
AND device_id IS NOT NULL
),

user_device_browser AS (
SELECT
u.user_id as user_id,
d.device_id as device_id,
d.browser_type as browser_type,
DATE(u.event_time) as act_date
FROM user_row u JOIN devices d ON u.device_id = d.device_id
WHERE u.row_num = 1
),

user_device_browser_pre AS (
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY user_id, device_id, browser_type, act_date ORDER BY act_date)
as row_num
FROM user_device_browser
),

user_device_browser_dedup AS (
SELECT
user_id,
browser_type,
act_date
FROM user_device_browser_pre
WHERE row_num = 1
),

user_id_multi AS (
SELECT
user_id,
browser_type,
ARRAY_AGG(DISTINCT act_date) dates
FROM user_device_browser_dedup
GROUP BY 1, 2
)


SELECT
user_id,
JSONB_OBJECT_AGG(browser_type, dates)
FROM user_id_multi
GROUP BY 1

SELECT * FROM user_devices_cumulated

