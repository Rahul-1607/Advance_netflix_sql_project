DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

select * from netflix;
select count(*) from netflix;

copy netflix
FROM 'C:\Program Files\PostgreSQL\17\netflix_titless.csv'
DELIMITER ','
CSV HEADER;

-- CREATE TABLE enter
-- (
--     show_id      VARCHAR(5),
--     type         VARCHAR(10),
--     title        VARCHAR(250),
--     director     VARCHAR(550),
--     casts        VARCHAR(1050),
--     country      VARCHAR(550),
--     date_added   VARCHAR(55),
--     release_year INT,
--     rating       VARCHAR(15),
--     duration     VARCHAR(15),
--     listed_in    VARCHAR(250),
--     description  VARCHAR(550)
-- );

-- select * from enter;
-- select count(*) from enter;


select * from netflix;


-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

select type, count(*) as total_content 
from netflix
Group By type;

select * from netflix;



-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT type, title,count(*)
FROM netflix
WHERE release_year = 2020
  AND type = 'Movie'
 group by type,title;


-- 4. Find the top 5 countries with the most content on Netflix


SELECT country,COUNT(*) AS content_count
FROM netflix
GROUP BY country
ORDER BY content_count DESC
LIMIT 5;

-- 5. Identify the longest movie

select max(duration) as longest_movie from netflix;


-- 6. Find content added in the last 5 years

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';



-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT title,director,type
FROM netflix
WHERE director ILIKE 'rajiv chilaka'
group by title,director,type;


-- 8. List all TV shows with more than 5 seasons

select type, duration,title
   from netflix 
 where type = 'TV Show' and
 CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5
 group by type,duration,title
 ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER);


-- 9. Count the number of content items in each genre

select 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	count(show_id) as total_content
from netflix
GROUP BY 1; 




-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;


-- 11. List all movies that are documentaries

select title
from netflix
where type = 'MOVIE' 
AND 
listed_in ILIKE '%documentaries%'
GROUP BY title;


select * from netflix;
 

-- 12. Find all content without a director

select title,
(show_id) as content
from netflix
where director IS null;


select 
count(*) total_count
from netflix
where director IS null;


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

 select *
 from netflix
 where casts ILIKE '%SALMAN KHAN%'
 and
 release_year > Extract(Year from current_date) - 10;




-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.


select 
UNNEST (STRING_TO_ARRAY(casts, ',')) AS actor,
count(*) as total_count
from netflix
where country ILIKE '%INDIA%'
Group by 1
order by 2 desc;




-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.


SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;






