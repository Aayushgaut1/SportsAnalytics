USE multi_sport_selection;

INSERT INTO PLAYER (name, age, team_id, nationality, height, weight, bio)
VALUES ('MS Dhoni', 42, 10, 'Indian', 175, 78, 'Legendary Indian Captain and elite finisher.');

SET @new_player_id = LAST_INSERT_ID();

INSERT INTO FITNESS_RECORD (player_id, stamina_score, speed_score, injury_status, test_date)
VALUES (@new_player_id, 98, 85, FALSE, '2024-05-01');

INSERT INTO SELECTION (player_id, match_id, selection_status)
VALUES (@new_player_id, 1, 'Selected');

INSERT INTO STATS_CRICKET (player_id, match_id, runs_scored, wickets_taken, catches, balls_faced)
VALUES (@new_player_id, 1, 91, 0, 5, 79);
