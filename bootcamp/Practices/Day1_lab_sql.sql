-- SELECT * FROM player_seasons;

-- Create structures
-- CREATE TYPE season_stats AS (
-- 	season INTEGER,
-- 	gp INTEGER,
-- 	pts REAL,
-- 	reb REAL,
-- 	ast REAL
-- )

-- CREATE TYPE scoring_class AS
-- 	ENUM('bad', 'average', 'good', 'star')


-- Create a table with newly created structures
-- CREATE TABLE players (
-- 	player_name TEXT,
-- 	height TEXT,
-- 	college TEXT,
-- 	country TEXT,
-- 	draft_year TEXT,
-- 	draft_round TEXT,
-- 	draft_number TEXT,
-- 	seasons season_stats[],
-- 	scoring_class scoring_class,
-- 	current_season INTEGER,
-- 	PRIMARY KEY (player_name, current_season)
-- )

-- INSERT INTO players
-- WITH last_season AS (
-- 	SELECT * FROM players
-- 	WHERE current_season = 2001
-- ),
-- 	this_season AS (
-- 	SELECT * FROM player_seasons
-- 	WHERE season = 2002
-- 	)

-- SELECT
-- 	COALESCE(ls.player_name, ts.player_name) as player_name,
-- 	COALESCE(ls.height, ts.height) as height,
-- 	COALESCE(ls.college, ts.college) as college,
-- 	COALESCE(ls.country, ts.country) as country,
-- 	COALESCE(ls.draft_year, ts.draft_year) as draft_year,
-- 	COALESCE(ls.draft_round, ts.draft_round) as draft_round,
-- 	COALESCE(ls.draft_number, ts.draft_number) as draft_number,
-- 	COALESCE(ls.seasons, ARRAY[]::season_stats[]) ||
-- 		CASE WHEN ts.season IS NOT NULL THEN
-- 			ARRAY[ROW(
-- 				ts.season,
-- 				ts.gp,
-- 				ts.pts,
-- 				ts.reb,
-- 				ts.ast
-- 			)::season_stats
-- 			]
-- 			ELSE ARRAY[]::season_stats[] END as seasons,
-- 	CASE WHEN ts.season IS NOT NULL THEN
-- 		(CASE WHEN ts.pts > 20 THEN 'star'
-- 			  WHEN ts.pts > 15 THEN 'good'
-- 			  WHEN ts.pts > 10 THEN 'average'
-- 			  ELSE 'bad' END)::scoring_class
-- 		ELSE ls.scoring_class
-- 		END as scoring_class,
-- 	COALESCE(ts.season, ls.current_season+1) as current_season

-- FROM last_season ls
-- FULL OUTER JOIN this_season ts
-- ON ls.player_name = ts.player_name

-- WITH unnested AS (
-- SELECT
-- 	player_name,
-- 	UNNEST(seasons) as season_stats
-- FROM players
-- WHERE
--       current_season = 2002
-- )

-- SELECT player_name,
-- 	   (season_stats::season_stats).*
-- FROM unnested

-- DROP TABLE players

-- CREATE TABLE players (
-- 	player_name TEXT,
-- 	height TEXT,
-- 	college TEXT,
-- 	country TEXT,
-- 	draft_year TEXT,
-- 	draft_round TEXT,
-- 	draft_number TEXT,
-- 	seasons season_stats[],
-- 	scoring_class scoring_class,
-- 	years_since_last_active INTEGER,
-- 	current_season INTEGER,
-- 	PRIMARY KEY (player_name, current_season)
-- )

INSERT INTO players
WITH last_season AS (
	SELECT * FROM players
	WHERE current_season = 2001
),
	this_season AS (
	SELECT * FROM player_seasons
	WHERE season = 2002
	)

SELECT
	COALESCE(ls.player_name, ts.player_name) as player_name,
	COALESCE(ls.height, ts.height) as height,
	COALESCE(ls.college, ts.college) as college,
	COALESCE(ls.country, ts.country) as country,
	COALESCE(ls.draft_year, ts.draft_year) as draft_year,
	COALESCE(ls.draft_round, ts.draft_round) as draft_round,
	COALESCE(ls.draft_number, ts.draft_number) as draft_number,
	COALESCE(ls.seasons, ARRAY[]::season_stats[]) ||
		CASE WHEN ts.season IS NOT NULL THEN
			ARRAY[ROW(
				ts.season,
				ts.gp,
				ts.pts,
				ts.reb,
				ts.ast
			)::season_stats
			]
			ELSE ARRAY[]::season_stats[] END as seasons,
	CASE WHEN ts.season IS NOT NULL THEN
		(CASE WHEN ts.pts > 20 THEN 'star'
			  WHEN ts.pts > 15 THEN 'good'
			  WHEN ts.pts > 10 THEN 'average'
			  ELSE 'bad' END)::scoring_class
		ELSE ls.scoring_class
		END as scoring_class,
	CASE WHEN ts.season IS NOT NULL THEN 0
		 ELSE ls.years_since_last_active+1
		 END as years_since_last_active,
	COALESCE(ts.season, ls.current_season+1) as current_season

FROM last_season ls
FULL OUTER JOIN this_season ts
ON ls.player_name = ts.player_name



SELECT
	player_name,
	seasons[1].pts,
	seasons[CARDINALITY(seasons)].pts /
	CASE WHEN seasons[1].pts = 0 THEN 1 ELSE seasons[1].pts END AS improvement,
	seasons[CARDINALITY(seasons)].pts
FROM players
WHERE
      current_season = 2001
ORDER BY improvement DESC

SELECT * FROM player_seasons
WHERE player_name = 'Don MacLean'
