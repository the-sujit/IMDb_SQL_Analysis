--Total number of Motion Pictures avaialable on IMDb
SELECT COUNT(DISTINCT(title_id)) AS total_motion_pic FROM titles;


---------------------------------------------------------------------------------------------


--Distinct types of Motion Pictures and corresponding titles available on IMDb
SELECT DISTINCT(type) AS motion_pic_types, COUNT(*) AS category_count FROM titles
GROUP BY type
ORDER BY type ASC;


---------------------------------------------------------------------------------------------


--Oldest Motion Picture available on IMDb
SELECT primary_title, type, premiered, genres FROM titles
WHERE premiered IS NOT NULL
ORDER BY premiered LIMIT 1;


---------------------------------------------------------------------------------------------


--Number of Motion Pictures premiered in each decade
SELECT CAST(premiered/10*10 AS TEXT) || 's' AS decades, COUNT(premiered) AS premiered_motion_pic
FROM titles
WHERE decades IS NOT NULL
GROUP BY decades
ORDER BY decades ASC;


---------------------------------------------------------------------------------------------


--Number of co-workers of an person eg. Sean Connery Born (1930)

--Create a CTE which has all title_ids of the person of interest
WITH Person_Works AS
(
	SELECT DISTINCT(c.title_id)
	FROM people AS p
	JOIN crew AS c
	ON c.person_id == p.person_id 
	--put the name and birth year of the person here
	AND p.name == "Sean Connery" AND p.born == 1930
)
--Find the person_id for which title_id is in above CTE
SELECT
--Use COUNT DISTINCT for just the number and DISTINCT for the list
COUNT(DISTINCT(person_id))
FROM crew
--put the type of crew you want to enlist eg. actor, producer, director etc.
WHERE (category = "actor" OR category = "actress") AND title_id IN Person_Works


---------------------------------------------------------------------------------------------


--Top 250 Motion Pictures of a specified type eg. movies, tvSeries etc

--Create CTEs for weighted average ratings and minimum number of votes
WITH av(average_rating) AS
(
	SELECT SUM(rating * votes) / SUM(votes)
    FROM ratings
	JOIN titles
	ON titles.title_id == ratings.title_id 
	--put the Motion Picture type you want eg. movie, tvSeries etc
	AND titles.type == "movie" 
),
mn(min_rating) AS (SELECT 25000.0)
SELECT
primary_title,
(votes / (votes + min_rating)) * rating + (min_rating / (votes + min_rating)) * average_rating as weighed_rating
FROM ratings, av, mn
JOIN titles
ON titles.title_id == ratings.title_id 
--put the Motion Picture type you want eg. movie, tvSeries etc
AND titles.type == "movie"
ORDER BY weighed_rating DESC
--put the number XYZ of top Motion Pictures you want to enlist eg. TOP 50, TOP 100 etc
LIMIT 250;


---------------------------------------------------------------------------------------------


--List of Motion Pictures of your Favourite Actor/ Actress/ Director/ Producer etc
WITH Person_Works AS
(
	SELECT DISTINCT(c.title_id)
	FROM people AS p
	JOIN crew AS c
	ON c.person_id == p.person_id 
	--put the name and birth year of the person here
	AND p.name == "Sean Connery" AND p.born == 1930
)
SELECT DISTINCT(primary_title) AS motion_pic, premiered
FROM titles
WHERE title_id in Person_Works
ORDER BY premiered ASC;


---------------------------------------------------------------------------------------------


--List of Crew of your favorite movie, tvSeries etc
WITH movie_people AS
(
	SELECT DISTINCT(c.person_id)
	FROM crew AS c
	JOIN titles AS t
	ON c.title_id == t.title_id 
	--put the name and birth year of the person here
	AND t.primary_title == "Skyfall: Modern Day Bond"
)
SELECT DISTINCT(p.name) AS Names, c.category AS Job
FROM people AS p
JOIN crew AS c
ON p.person_id = c.person_id
WHERE p.person_id IN movie_people;


---------------------------------------------------------------------------------------------


--List of different genres and corresponding count

--Create a recursive CTE which will convert comma seperated genres into seperate rows
WITH RECURSIVE split(genre, rest) AS 
(
	--this select statement has first row for any genres with multiple values
	SELECT 
	--put '' in genre column
	'',
	--put the entry from genres column (after adding a leading comma) in the rest column
	genres || ',' FROM titles WHERE genres != "\N"
	UNION ALL
	--this select statement starts adding single genre from genres column into seperate rows
	SELECT 
	--put the string before first comma from rest column into the genre column
	substr(rest, 0, instr(rest, ',')),
	--put rest of the string after first comma into rest column
	substr(rest, instr(rest, ',')+1)
	FROM split
	--the recursion should loop the process until string in the rest column is ''
	WHERE rest != ''
)
--Select the genre and corresponding count of Motion Picture in each genre
SELECT genre, COUNT(*) as motion_pic_count
FROM split
WHERE genre != ''
GROUP BY genre
ORDER by genre ASC;