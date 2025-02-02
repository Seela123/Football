/*1.Create Relationships:

    Define and implement the foreign key relationships between tables using ALTER TAB

Define Foreign Key Relationships:

    Link appearances to games, players, and competitions.
    Link club_game to games, clubs, and opponents.
    Link game_events to games, clubs, and players.
    Link game_lineups to games, players, and clubs.
    Link games to competitions, home_club, and away_club.
    Link player_valuations to players and clubs.*/

	--    Link appearances to games, players, and competitions.

	ALTER TABLE games
	ADD CONSTRAINT PK_games PRIMARY KEY (game_id)

	ALTER TABLE appearances
	ADD CONSTRAINT FK_appearances_games
	FOREIGN KEY (game_id) REFERENCES games(game_id)
	 
    ALTER TABLE players 
	ADD CONSTRAINT PK_players PRIMARY KEY (player_id)

	ALTER TABLE appearances 
	ADD CONSTRAINT FK_appearances_players
	FOREIGN KEY(player_id) REFERENCES players(player_id)

 
	ALTER TABLE competitions
	ADD CONSTRAINT PK_competitions PRIMARY KEY(competition_id)

	ALTER TABLE appearances 
    ADD CONSTRAINT FK_appearances_competitions
   FOREIGN KEY (competition_id) REFERENCES competitions(competition_id);

   --  Link club_game to games, clubs, and opponents.

   SELECT * FROM club_games
   SELECT * FROM clubs

   ALTER TABLE club_games
   ADD CONSTRAINT FK_clubGames_games
   FOREIGN KEY (game_id) REFERENCES games(game_id)

    SELECT * FROM club_games
	SELECT * FROM players

	ALTER TABLE clubs
	ADD CONSTRAINT PK_clubID
	PRIMARY KEY (club_id)

	ALTER TABLE club_games
	ADD CONSTRAINT FK_clubGames_clubs
	FOREIGN KEY (club_id) REFERENCES clubs(club_id)


	ALTER TABLE club_games
	ADD CONSTRAINT FK_club_game_opponents
    FOREIGN KEY (opponent_id) REFERENCES clubs(club_id);

	--Link game_events to games, clubs, and players.

	SELECT * FROM game_events
	SELECT * FROM games

	ALTER TABLE game_events
	ADD CONSTRAINT FK_GameEvents_games
	FOREIGN KEY (game_id) REFERENCES games (game_id)

	SELECT * FROM game_events
	SELECT * FROM clubs

	ALTER TABLE game_events
	ADD CONSTRAINT FK_GameEvents_clubs
	FOREIGN KEY (club_id) REFERENCES clubs (club_id)

	SELECT * FROM game_events
	SELECT * FROM players

	ALTER TABLE game_events 
	ADD CONSTRAINT FK_GameEvents_players
	FOREIGN KEY (player_id) REFERENCES players (player_id)

	--Link game_lineups to games, players, and clubs.

	SELECT * FROM game_lineups
	SELECT * FROM games

	ALTER TABLE game_lineups
	ADD CONSTRAINT FK_GameLineips_games
	FOREIGN KEY (game_id) REFERENCES games (game_id)

	SELECT * FROM game_lineups
	SELECT * FROM players

	ALTER TABLE game_lineups
	ADD CONSTRAINT FK_gameLineups_players
	FOREIGN KEY (player_id) REFERENCES players(player_id)

	SELECT * FROM game_lineups
	SELECT * FROM clubs

	ALTER TABLE game_lineups
	ADD CONSTRAINT FK_GameLineups
	FOREIGN KEY (club_id) REFERENCES clubs (club_id)

	-- Link games to competitions, home_club, and away_club.

	
	ALTER TABLE games
	ADD CONSTRAINT FK_games_conpetitions
	FOREIGN KEY (competition_id) REFERENCES conpetitions(competition_id)

	ALTER TABLE games
    ADD CONSTRAINT FK_games_home_club
    FOREIGN KEY (home_club_id) REFERENCES clubs(club_id);

    ALTER TABLE games
    ADD CONSTRAINT FK_games_away_club 
    FOREIGN KEY (away_club_id) REFERENCES clubs(club_id)

	--Link player_valuations to players and clubs.

	SELECT * FROM player_valuations
	SELECT * FROM players

	ALTER TABLE player_valuations
	ADD CONSTRAINT FK_PlayerValuations_players
	FOREIGN KEY (player_id) REFERENCES players(player_id)

	SELECT * FROM player_valuations
	SELECT * FROM clubs

	ALTER TABLE player_valuations
	ADD CONSTRAINT FK_PlayerValutions_clubs
	FOREIGN KEY (current_club_id) REFERENCES clubs (club_id)

	/*
2.Basic Queries:

    Write SQL queries to retrieve basic information such as:
        All games played by a specific club.
        All players who have received a yellow card in a specific competition.*/

	--    All games played by a specific club.

	select * from club_games
	SELECT * FROM clubs

	SELECT DISTINCT(c.club_id),name,hosting,COUNT (c.club_id) AS total_GamePlay 
	FROM club_games cb
	LEFT JOIN clubs c 
	ON cb.club_id = c.club_id
	WHERE NAME IS NOT NULL
	GROUP BY c.club_id,name,hosting
	ORDER BY name
	
	--All players who have received a yellow card in a specific competition.
	
	SELECT * FROM players
	SELECT * FROM game_events
	SELECT * FROM competitions


	SELECT  p.first_name,last_name, c.name AS league_name,c.type,gv.description
	FROM players P
	LEFT JOIN game_events gv
	ON p.player_id = gv.player_id
    LEFT JOIN competitions C
	ON competition_id = current_club_domestic_competition_id
	WHERE gv.description LIKE '%YELLOW%'
	

	-- All players have yellow cards in all competition

	SELECT  p.first_name,last_name, c.name AS league_name,c.type,
	COUNT(p.name) AS nr_card
	FROM players P
	LEFT JOIN game_events gv
	ON p.player_id = gv.player_id
    LEFT JOIN competitions C
	ON competition_id = current_club_domestic_competition_id
	WHERE gv.description LIKE '%YELLOW%'
    GROUP BY p.name , p.player_id , p.first_name,last_name, c.name,c.type
	ORDER BY nr_card DESC


	/*3.Complex Queries:

    Write complex SQL queries to analyze data. For example:
        List the top 5 players with the most assists in a given season.
        Calculate the average number of goals scored by each club per game.*/

		--List the top 5 players with the most assists in a given season.

SELECT * FROM players
SELECT * FROM appearances
SELECT * FROM games

DECLARE @seson_year INT = 2022;
SELECT  TOP 5 name,SUM(assists) AS assists_seasone,season 
FROM players p
LEFT JOIN appearances a
ON p.player_id = a.player_id
LEFT JOIN games g 
ON a.game_id = g.game_id
WHERE g.season = @seson_year
GROUP BY name,season,assists
ORDER BY assists DESC

  -- Calculate the average number of goals scored by each club per game.*/

  SELECT *  FROM clubs 
  SELECT * FROM club_games 
  
  
  SELECT name AS club_name,
  AVG(own_goals) AS HOME_GOAL ,
  AVG(opponent_goals)  AS OPPONENT_GOALS
  FROM clubs c
  LEFT JOIN club_games cg
  ON c.club_id = cg.club_id
  GROUP BY name
 
 

 /*4.Data Aggregation and Reporting:

    Generate reports using SQL. For example:
        Total number of goals scored in each competition.
        Total market value of all players in a specific club.*/

SELECT * FROM games
SELECT * FROM club_games


SELECT competition_id,SUM(own_goals) AS own_goals,SUM(opponent_goals) AS opponent_goals 
FROM games G
LEFT JOIN club_games CG
ON g.game_id = cg.game_id
GROUP BY competition_id

--OR

SELECT competition_id, 
CAST(CASE WHEN SUM(own_goals) IS NOT NULL THEN SUM(own_goals) ELSE 0 END AS INT) AS own_goals,
CAST(CASE WHEN SUM(opponent_goals) IS NOT NULL THEN SUM(opponent_goals) ELSE 0 END AS INT) AS opponent_goals
FROM 
games G
LEFT JOIN 
club_games CG ON G.game_id = CG.game_id
GROUP BY competition_id

--ChatGpt

SELECT 
    g.competition_id,
    COALESCE(SUM(cg.own_goals), 0) AS total_own_goals,
    COALESCE(SUM(cg.opponent_goals), 0) AS total_opponent_goals
FROM 
    games g
    LEFT JOIN club_games cg ON g.game_id = cg.game_id
GROUP BY 
    g.competition_id;


--Total market value of all players in a specific club.


SELECT * FROM players
SELECT * FROM player_valuations
select * from clubs

-- player value 'USE INDEX'

SELECT C.club_id,p.name AS player_name   ,c.name AS team_name, SUM (CAST (pv.market_value_in_eur AS  bigint)) AS market_value
FROM players P
LEFT JOIN player_valuations pv
ON p.player_id = pv.player_id
LEFT JOIN clubs c
on pv.current_club_id = c.club_id
WHERE c.name IS NOT NULL 
AND P.name IS NOT NULL
GROUP BY c.club_id,p.name,c.name
ORDER BY market_value DESC

--team value

SELECT 
c.club_id,
c.name AS team_name,
SUM(CAST(pv.market_value_in_eur AS BIGINT)) AS total_market_value
FROM 
players p
LEFT JOIN 
player_valuations pv ON p.player_id = pv.player_id
LEFT JOIN 
clubs c ON pv.current_club_id = c.club_id
WHERE 
c.name IS NOT NULL 
AND p.name IS NOT NULL
GROUP BY 
c.club_id, c.name
ORDER BY 
total_market_value DESC;


/*5.Stored Procedures:

    Create stored procedures for common tasks, such as updating player valuations.
    Write a stored procedure to retrieve player statistics for a given season.*/

	-- Create stored procedures for common tasks, such as updating player valuations.

	SELECT * FROM player_valuations

	CREATE PROCEDURE upPlayer_valuations
	@player_id INT,
	@date DATE,
	@market_value INT,
	@current_club_id INT,
	@player_club NVARCHAR(50)
	AS
	BEGIN
	UPDATE player_valuations
	SET date = @date,
	market_value_in_eur = @market_value,
	current_club_id = @current_club_id,
	player_club_domestic_competition_id = @player_club
	WHERE player_id = @player_id
    END


	EXEC upPlayer_valuations 

	--Write a stored procedure to retrieve player statistics for a given season.

     SELECT name,last_season FROM players
	 SELECT home_club_goals,away_club_goals FROM games
	 SELECT yellow_cards,red_cards,goals,assists FROM appearances

	 
	 CREATE PROCEDURE player_statistics
	 @last_season INT
	 AS
	 SELECT p.name,p.last_season,a.yellow_cards,a.red_cards,a.goals,a.assists,g.home_club_goals,g.away_club_goals
	 FROM players p
	 LEFT JOIN appearances a
	 ON p.player_id = a.player_id
	 LEFT JOIN games G
	 ON A.game_id = G.game_id
	 WHERE p.last_season = @last_season
	 GO

	 EXEC player_statistics 2016

	 /*6.Functions:

    Write user-defined functions to calculate statistics like a player's average minutes played per game.
    Create a scalar function to convert a player's market value from euros to another currency.*/

   --Write user-defined functions to calculate statistics like a player's average minutes played per game.	
	
	SELECT * FROM players
	SELECT * FROM game_events

	CREATE FUNCTION avg_minFor_game
	(@name NVARCHAR(100))
	RETURNS TABLE 
	AS
	RETURN
    (SELECT P.name,AVG(ge.minute) AS avg_minute
	FROM players P
	LEFT JOIN game_events GE
	ON P.player_id = GE.player_id
	WHERE p.name = @name
	GROUP BY p.name
	)

	SELECT * FROM avg_minFor_game ('Lionel Messi')


	--Create a scalar function to convert a player's market value from euros to another currency.

SELECT p.name AS player_name,pv.date,
CAST (pv.market_value_in_eur AS money) AS euro_value,
FORMAT(CEILING(pv.market_value_in_eur * 1.08), 'N2') as dollars_value,
FORMAT(CEILING(pv.market_value_in_eur * 0.84), 'N2') as pound,
FORMAT(CEILING(pv.market_value_in_eur * 0.96), 'N2') as swiss_franc
FROM players P
LEFT JOIN player_valuations pv
ON p.player_id = pv.player_id
LEFT JOIN clubs c
on pv.current_club_id = c.club_id
WHERE c.name IS NOT NULL 
AND P.name IS NOT NULL
GROUP BY p.name,PV.market_value_in_eur,pv.date
ORDER BY euro_value DESC	



	DROP FUNCTION IF EXISTS value_players

	CREATE FUNCTION value_players (@name NVARCHAR (100))
	RETURNS TABLE
	AS
	RETURN (
	
SELECT p.name AS player_name,pv.date,
CAST (pv.market_value_in_eur AS money) AS euro_value,
FORMAT(CEILING(pv.market_value_in_eur * 1.08), 'N2') as dollars_value,
FORMAT(CEILING(pv.market_value_in_eur * 0.84), 'N2') as pound,
FORMAT(CEILING(pv.market_value_in_eur * 0.96), 'N2') as swiss_franc
FROM players P
LEFT JOIN player_valuations pv
ON p.player_id = pv.player_id
LEFT JOIN clubs c
on pv.current_club_id = c.club_id
WHERE P.name = @name
GROUP BY p.name,PV.market_value_in_eur,pv.date
)

	SELECT * FROM value_players ('Lionel Messi')

	/*8.Performance Optimization:

    Analyze and optimize the performance of your SQL queries. Implement indexing where necessary to improve query speed.
    Use SQL Server Profiler and Execution Plans to identify and resolve pe*/
	
	SELECT * FROM players
	SELECT * FROM player_valuations
	SELECT * FROM clubs

	CREATE INDEX plIndex
	ON players (player_id)

	CREATE INDEX pvIndex
	ON player_valuations (player_id)

	CREATE INDEX clIndex
	ON clubs (club_id)
	
	










