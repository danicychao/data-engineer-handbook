
INSERT INTO edges
WITH player_game_dedup AS (
SELECT
*,
ROW_NUMBER () OVER (PARTITION BY game_id, player_id) as row_num
FROM game_details
)

SELECT
player_id as subject_identifier,
'player'::vertex_type as subject_type,
game_id as object_identifier,
'game'::vertex_type as object_type,
'play_in'::edge_type as edge_type,
json_build_object(
	'team', team_abbreviation,
	'start_pos', start_position,
	'min', min,
	'pts', pts
)
FROM player_game_dedup
WHERE row_num = 1

-- SELECT
-- v.properties->>'player_name' AS player_name,
-- MAX(CAST(e.properties->>'pts' AS INTEGER)) AS pts,
-- ARRAY_AGG(DISTINCT v.properties->>'teams') AS teams,
-- ARRAY_AGG(DISTINCT e.properties->>'team') AS team
-- FROM vertices v JOIN edges e
-- ON v.identifier = e.subject_identifier
-- AND v.type = e.subject_type
-- GROUP BY player_name
-- ORDER BY pts DESC



