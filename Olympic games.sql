-- DB Has two tables, athlete_events contains columns ID, Sex, Age, Team, NOC, Games, Sport and Medal. noc_regions containes columns NOC and region

-- 1. How many olympic games have been held?
SELECT COUNT(DISTINCT Games) AS Total_Games
FROM athlete_events;

-- 2. List down all Olympics games held so far.
SELECT Games
FROM athlete_events
GROUP BY Games
ORDER BY Games ASC
;
-- 3. Mention the total no of nations who participated in each olympics game?
SELECT table1.Games, COUNT(DISTINCT table1.NOC) AS No_of_Countries
FROM athlete_events AS table1
JOIN noc_regions AS table2
	ON table1.NOC=table2.NOC
GROUP BY Games
ORDER BY Games ASC
;

-- 4. Which year saw the highest and lowest no of countries participating in olympics?
WITH CTE0 AS(
SELECT table1.Games AS Games2, COUNT(DISTINCT table1.NOC) AS No_of_Countries
FROM athlete_events AS table1
JOIN noc_regions AS table2
	ON table1.NOC=table2.NOC
GROUP BY Games
ORDER BY No_of_Countries ASC
LIMIT 1
),
CTE1 AS(
SELECT table1.Games AS Games2, COUNT(DISTINCT table1.NOC) AS No_of_Countries
FROM athlete_events AS table1
JOIN noc_regions AS table2
	ON table1.NOC=table2.NOC
GROUP BY Games
ORDER BY No_of_Countries DESC
LIMIT 1
)
SELECT CONCAT(CTE0.Games2, ' - ', CTE0.No_of_Countries) AS `Lowest_Countries`, CONCAT(CTE1.Games2, ' - ', CTE1.No_of_Countries) AS 'Highest_Countries'
FROM CTE0, CTE1
;

-- 5. Which nation has participated in all of the olympic games?
WITH CTE1 AS(
SELECT table1.Team, table1.NOC, COUNT(DISTINCT table1.Games) AS Games_attended
FROM athlete_events AS table1
JOIN noc_regions AS table2
	ON table1.NOC=table2.NOC
GROUP BY NOC, Team
)
SELECT Team, Games_attended
FROM CTE1
WHERE Games_attended IN(
	SELECT COUNT(DISTINCT Games) AS Total_Games
	FROM athlete_events
)
;

-- 6. Identify the sport which was played in all summer olympics.
WITH CTE1 AS(
-- Games played in Summer
SELECT Sport
FROM athlete_events
WHERE Games LIKE '%Summer'
),
CTE2 AS(
-- Number of games played
SELECT COUNT(Sport) AS No_Games_Played
FROM CTE1
GROUP BY Sport
),
CTE3 AS(
SELECT COUNT(DISTINCT Games) AS Total_games
FROM athlete_events
WHERE Games LIKE '%Summer%'
)
SELECT CTE1.Sport AS Sport_Played, CTE2.No_Games_Played AS No_Games_Played  
FROM CTE1, CTE2
JOIN CTE3 ON CTE2.No_Games_Played = CTE3.Total_games
;

-- 7. Which Sports were just played only once in the olympics?
WITH CTE1 AS(
-- Select all the distinct sports held at one olympic game
SELECT DISTINCT Games as Games, Sport 
FROM athlete_events
),
CTE2 AS(
-- Count How many times Sport appears in cte1
SELECT Sport, COUNT(Sport) AS Total
FROM CTE1
GROUP BY SPORT
)
SELECT CTE2.*, CTE1.Games
FROM CTE2
JOIN CTE1 ON CTE1.Sport=CTE2.Sport
WHERE CTE2.Total = 1
ORDER BY CTE2.Sport
;

-- 8. Fetch the total no of sports played in each olympic game.
WITH CTE1 AS(
-- Select all the distinct sports held at a particular game
SELECT DISTINCT Games as Games, Sport 
FROM athlete_events
),
CTE2 AS(
-- Count How many distinct sports at a particular game
SELECT Games, COUNT(Sport) AS Total
FROM CTE1
GROUP BY Games
)
SELECT *
FROM CTE2
ORDER BY Total desc
;

-- 9. Fetch details of the oldest athletes to win a gold medal.
SELECT MAX(Age) FROM athlete_events WHERE Medal='Gold';
SELECT *
FROM athlete_events
WHERE Medal = 'Gold' AND Age=57
ORDER BY Age DESC
;

-- 10. Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.
SELECT Team, Sport, Games, COUNT(Medal)
FROM athlete_events
WHERE Sport = 'Hockey' AND Team ='India'
GROUP BY Games
;