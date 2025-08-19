-- INSERT INTO vertices
-- SELECT
-- 	game_id as identifier,
-- 	'game'::vertex_type as type,
-- 	json_build_object(
-- 		'pts_home', pts_home,
-- 		'pts_away', pts_away,
-- 		'winning_team', CASE WHEN home_team_wins = 1 THEN home_team_id
-- 		                ELSE visitor_team_id END
-- 	) as properties
-- FROM games;

-- INSERT INTO vertices
-- WITH players_agg AS(
-- SELECT
-- 	MAX(player_name) as player_name,
-- 	player_id as player_id,
-- 	COUNT(1) as number_of_games,
-- 	SUM(pts) as total_points,
-- 	ARRAY_AGG(DISTINCT team_id) as teams
-- FROM game_details
-- GROUP BY player_id
-- )

-- SELECT
-- player_id as identifier,
-- 'player'::vertex_type as type,
-- json_build_object (
-- 	'player_name', player_name,
-- 	'number_of_games', number_of_games,
-- 	'total_points', total_points,
-- 	'teams', teams
-- )
-- FROM players_agg

INSERT INTO vertices
SELECT
	team_id as identifier,
	'team'::vertex_type as type,
	json_build_object (
		'abbrev', max(abbreviation),
		'nickname', min(nickname),
		'city', max(city),
		'arena', max(arena)
	)
FROM teams
GROUP BY team_id
