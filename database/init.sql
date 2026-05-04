-- Create Database
CREATE DATABASE IF NOT EXISTS sports_selection;
USE sports_selection;

-- Table: ROLE
CREATE TABLE IF NOT EXISTS ROLE (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL
);

-- Table: TEAM
CREATE TABLE IF NOT EXISTS TEAM (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL
);

-- Table: PLAYER
CREATE TABLE IF NOT EXISTS PLAYER (
    player_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    role_id INT,
    team_id INT,
    FOREIGN KEY (role_id) REFERENCES ROLE(role_id),
    FOREIGN KEY (team_id) REFERENCES TEAM(team_id)
);

-- Table: MATCH_DETAILS
CREATE TABLE IF NOT EXISTS MATCH_DETAILS (
    match_id INT AUTO_INCREMENT PRIMARY KEY,
    match_date DATE NOT NULL,
    opponent_team VARCHAR(100) NOT NULL,
    venue VARCHAR(150) NOT NULL
);

-- Table: PERFORMANCE
CREATE TABLE IF NOT EXISTS PERFORMANCE (
    player_id INT,
    match_id INT,
    runs_scored INT DEFAULT 0,
    wickets_taken INT DEFAULT 0,
    PRIMARY KEY (player_id, match_id),
    FOREIGN KEY (player_id) REFERENCES PLAYER(player_id),
    FOREIGN KEY (match_id) REFERENCES MATCH_DETAILS(match_id)
);

-- Table: FITNESS_RECORD
CREATE TABLE IF NOT EXISTS FITNESS_RECORD (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    player_id INT,
    stamina_score INT NOT NULL,
    speed_score INT NOT NULL,
    injury_status BOOLEAN NOT NULL DEFAULT FALSE,
    test_date DATE NOT NULL,
    FOREIGN KEY (player_id) REFERENCES PLAYER(player_id)
);

-- Table: SELECTION
CREATE TABLE IF NOT EXISTS SELECTION (
    player_id INT,
    match_id INT,
    selection_status ENUM('Selected', 'Not Selected', 'Pending') DEFAULT 'Pending',
    PRIMARY KEY (player_id, match_id),
    FOREIGN KEY (player_id) REFERENCES PLAYER(player_id),
    FOREIGN KEY (match_id) REFERENCES MATCH_DETAILS(match_id)
);

-- Insert Roles
INSERT INTO ROLE (role_name) VALUES 
('Forward/Striker'), 
('Batsman'), 
('Point Guard'), 
('Tennis Player'), 
('Badminton Player');

-- Insert Teams
INSERT INTO TEAM (team_name) VALUES 
('Argentina National Team'), 
('India National Cricket Team'), 
('Los Angeles Lakers'), 
('Switzerland National Tennis'), 
('China National Badminton');

-- Insert Top 10 International Players
-- 1. Lionel Messi (Football)
-- 2. Virat Kohli (Cricket)
-- 3. LeBron James (Basketball)
-- 4. Roger Federer (Tennis)
-- 5. Lin Dan (Badminton)
-- 6. Cristiano Ronaldo (Football)
-- 7. MS Dhoni (Cricket)
-- 8. Stephen Curry (Basketball)
-- 9. Rafael Nadal (Tennis)
-- 10. Lee Chong Wei (Badminton)

INSERT INTO PLAYER (name, age, role_id, team_id) VALUES 
('Lionel Messi', 36, 1, 1),
('Virat Kohli', 35, 2, 2),
('LeBron James', 39, 3, 3),
('Roger Federer', 42, 4, 4),
('Lin Dan', 40, 5, 5),
('Cristiano Ronaldo', 39, 1, 1),
('MS Dhoni', 42, 2, 2),
('Stephen Curry', 36, 3, 3),
('Rafael Nadal', 37, 4, 4),
('Lee Chong Wei', 41, 5, 5);

-- Insert Match Details
INSERT INTO MATCH_DETAILS (match_date, opponent_team, venue) VALUES 
('2024-06-01', 'Global All-Stars', 'Wembley Stadium'),
('2024-06-15', 'World Legends', 'Lords Cricket Ground');

-- Insert Performance Records
-- runs_scored is mapped generically to "goals/points/runs"
-- wickets_taken is mapped generically to "assists/blocks/wickets"
INSERT INTO PERFORMANCE (player_id, match_id, runs_scored, wickets_taken) VALUES 
(1, 1, 2, 1),   -- Messi: 2 goals, 1 assist
(2, 1, 82, 0),  -- Kohli: 82 runs
(3, 1, 27, 7),  -- LeBron: 27 points, 7 assists
(4, 1, 3, 0),   -- Federer: 3 sets won
(5, 1, 2, 0),   -- Lin Dan: 2 sets won
(6, 1, 1, 0),   -- Ronaldo: 1 goal
(7, 2, 45, 2),  -- Dhoni: 45 runs, 2 catches
(8, 2, 31, 5),  -- Curry: 31 points, 5 assists
(9, 2, 3, 0),   -- Nadal: 3 sets won
(10, 2, 2, 0);  -- Lee Chong Wei: 2 sets won

-- Insert Fitness Records
INSERT INTO FITNESS_RECORD (player_id, stamina_score, speed_score, injury_status, test_date) VALUES 
(1, 85, 80, FALSE, '2024-05-10'),
(2, 95, 88, FALSE, '2024-05-11'),
(3, 90, 85, FALSE, '2024-05-12'),
(4, 75, 70, TRUE, '2024-05-13'), -- Injured
(5, 88, 92, FALSE, '2024-05-14'),
(6, 92, 89, FALSE, '2024-05-10'),
(7, 80, 75, FALSE, '2024-05-11'),
(8, 85, 90, FALSE, '2024-05-12'),
(9, 65, 60, TRUE, '2024-05-13'), -- Injured, Low stamina
(10, 89, 95, FALSE, '2024-05-14');

-- Insert Selection
INSERT INTO SELECTION (player_id, match_id, selection_status) VALUES 
(1, 1, 'Selected'),
(2, 1, 'Selected'),
(3, 1, 'Selected'),
(4, 1, 'Not Selected'),
(5, 1, 'Pending'),
(6, 2, 'Selected'),
(7, 2, 'Selected'),
(8, 2, 'Pending'),
(9, 2, 'Not Selected'),
(10, 2, 'Pending');
