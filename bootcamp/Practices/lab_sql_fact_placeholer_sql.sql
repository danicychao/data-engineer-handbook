WITH series AS (
SELECT * FROM
generate_series(DATE('2023-01-01'), DATE('2023-01-31'), INTERVAL '1 DAY')
as date_series
),

users AS (
SELECT * FROM
users_cumulated
WHERE
date = '2023-01-31'
),

placeholder AS(
SELECT
u.user_id,
DATE(s.date_series),
u.date - DATE(s.date_series),
u.dates_active @> ARRAY[DATE(s.date_series)] as active_status,
CASE WHEN u.dates_active @> ARRAY[DATE(s.date_series)]
     THEN CAST(POW(2, 30 - (u.date - DATE(s.date_series))) AS BIGINT)
	 ELSE 0 END as placeholder_int_value
FROM users u CROSS JOIN series s
)

-- SELECT * FROM users
SELECT
user_id,
SUM(placeholder_int_value),
CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(31)) as m_active_days,
BIT_COUNT(CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(31))) > 0 as dim_monthly_active,
BIT_COUNT(CAST('1111111000000000000000000000000' AS BIT(31)) &
	CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(31))) > 0 as dim_weekly_active,
BIT_COUNT(CAST('1000000000000000000000000000000' AS BIT(31)) &
	CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(31))) > 0 as dim_daily_active
FROM placeholder
GROUP BY user_id