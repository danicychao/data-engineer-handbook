-- SELECT
-- player_id,
-- team_id,
-- game_id,
-- COUNT(1)
-- FROM game_details
-- GROUP BY player_id, team_id, game_id
-- ORDER BY COUNT(1) DESC


INSERT INTO fact_game_details
WITH row_num_cat AS (
SELECT
*,
ROW_NUMBER() OVER(PARTITION BY player_id, team_id, game_id) as row_num
FROM
game_details
),

deduped AS (
SELECT *
FROM row_num_cat
WHERE row_num = 1
),

join_game AS (
SELECT
g.game_date_est as game_date,
g.game_id as game_id,
g.home_team_id as home_team_id,
g.visitor_team_id as vistor_team_id,
g.season as season,
g.home_team_wins as home_team_win,
d.*
FROM deduped d JOIN games g ON d.game_id = g.game_id
)

SELECT
game_date as dim_game_date,
season as dim_season,
player_name as dim_player_name,
player_id as dim_player_id,
team_id as dim_team_id,
team_id = home_team_id as dim_play_home,
start_position as dim_position,
COALESCE(POSITION('DNP' IN "comment"), 0) > 0 as dim_did_not_play,
COALESCE(POSITION('DND' IN "comment"), 0) > 0 as dim_did_not_dress,
COALESCE(POSITION('NWT' IN "comment"), 0) > 0 as dim_not_with_team,
CAST(SPLIT_PART("min", ':', 1) AS REAL) + CAST(SPLIT_PART("min", ':', 2) AS REAL)/60 as m_play_time,
fgm as m_fgm,
fga as m_fga,
fg3m as m_fg3m,
fg3a as m_fg3a,
ftm as m_ftm,
fta as m_fta,
oreb as m_oreb,
dreb as m_dreb,
reb as m_reb,
ast as m_ast,
stl as m_stl,
blk as m_blk,
"TO" as m_turnover,
pf as m_pf,
pts as m_pts,
plus_minus as m_plus_minus
FROM join_game


-- CREATE TABLE fact_game_details (
-- 	dim_game_date DATE,
-- 	dim_season INTEGER,
-- 	dim_player_name TEXT,
-- 	dim_player_id INTEGER,
-- 	dim_team_id INTEGER,
-- 	dim_play_home BOOLEAN,
-- 	dim_position TEXT,
-- 	dim_did_not_play BOOLEAN,
-- 	dim_did_not_dress BOOLEAN,
-- 	dim_not_with_team BOOLEAN,
-- 	m_play_time REAL,
-- 	m_fgm REAL,
-- 	m_fga REAL,
-- 	m_fg3m REAL,
-- 	m_fg3a REAL,
-- 	m_ftm REAL,
-- 	m_fta REAL,
-- 	m_oreb REAL,
-- 	m_dreb REAL,
-- 	m_reb REAL,
-- 	m_ast REAL,
-- 	m_stl REAL,
-- 	m_blk REAL,
-- 	m_turnover REAL,
-- 	m_pf REAL,
-- 	m_pts REAL,
-- 	m_plus_minus REAL,
-- 	PRIMARY KEY(dim_game_date, dim_player_id)
-- )

SELECT
dim_player_name,
COUNT(CASE WHEN dim_did_not_dress THEN 1 END) not_dress_num,
COUNT(1),
CAST(COUNT(CASE WHEN dim_did_not_dress THEN 1 END) AS REAL)/COUNT(1) as not_dress_rate
FROM fact_game_details
GROUP BY dim_player_name
ORDER BY not_dress_rate DESC

