INSERT INTO edges
WITH player_game_dedup AS (
SELECT
*,
ROW_NUMBER () OVER (PARTITION BY game_id, player_id) as row_num
FROM game_details
),

	filtered AS (
		SELECT
		*
		FROM player_game_dedup
		WHERE row_num = 1
	),

	aggregated_1 AS (
		SELECT
		f1.player_id as left_id,
		f1.player_name as left_player,
		f1.start_position as left_st_position,
		f1.pts as left_pts,
		f1.team_abbreviation as left_team,
		f2.player_id as right_id,
		f2.player_name as right_player,
		f2.start_position as right_st_position,
		f2.pts as right_pts,
		f2.team_abbreviation as right_team
		FROM filtered f1 JOIN filtered f2
		ON f1.game_id = f2.game_id
		AND f1.player_id <> f2.player_id
		),

		aggregated_2 AS (
			SELECT *,
			CASE WHEN left_team = right_team THEN 'share_team'::edge_type
				ELSE 'play_against'::edge_type END as edge_type
			FROM aggregated_1
			WHERE left_id < right_id
		)

-- SELECT
-- left_id as subject_identifier,
-- 'player'::vertex_type as subject_type,
-- right_id as object_identifier,
-- 'player'::vertex_type as object_type,
-- edge_type as edge_type,
-- json_build_object (
-- 	'left_player_name', left_player,
-- 	'left_points', SUM(left_pts),
-- 	'left_positions', ARRAY_AGG(DISTINCT left_st_position),
-- 	'right_player_name', right_player,
-- 	'right_points', SUM(right_pts),
-- 	'right_positions', ARRAY_AGG(DISTINCT right_st_position),
-- 	'num_games', COUNT(1)
-- )
-- FROM aggregated_2
-- GROUP BY left_id, left_player,  right_id, right_player, edge_type


SELECT
left_id as subject_identifier,
'player'::vertex_type as subject_type,
right_id as object_identifier,
'player'::vertex_type as object_type,
edge_type as edge_type,
json_build_object (
	'left_player_name', ARRAY_AGG(DISTINCT left_player),
	'left_points', SUM(left_pts),
	'left_positions', ARRAY_AGG(DISTINCT left_st_position),
	'right_player_name', ARRAY_AGG(DISTINCT right_player),
	'right_points', SUM(right_pts),
	'right_positions', ARRAY_AGG(DISTINCT right_st_position),
	'num_games', COUNT(1)
)
FROM aggregated_2
GROUP BY left_id,   right_id,  edge_type

SELECT * FROM edges
WHERE edge_type <> 'play_in'