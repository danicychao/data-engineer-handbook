INSERT INTO edges
WITH player_game_dedup AS (
SELECT
*,
ROW_NUMBER () OVER (PARTITION BY game_id, player_id) as row_num
FROM game_details
),

	filtered AS (
		SELECT
		team_id, team_abbreviation, player_id, player_name, pts
		FROM player_game_dedup
		WHERE row_num = 1
	)

SELECT
player_id as subject_identifier,
'player'::vertex_type as subject_type,
team_id as object_identifier,
'team'::vertex_type as object_type,
'play_on'::edge_type as edge_type,
json_build_object (
	'player', max(player_name),
	'team', max(team_abbreviation),
	'num_games', count(1),
	'pts', sum(pts)
)
FROM filtered
GROUP BY player_id, team_id
