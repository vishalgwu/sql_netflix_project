-- netflix postgress project 
-- project 1st
-- 
drop table if exists netflix;
create  table netflix 
(	show_id varchar (10),
	type varchar(10),	
	title varchar(200),
	director varchar(250),
	casting  varchar(1000),	
	country varchar (200),
	date_added varchar(70),
	release_year int,
	rating varchar(15),
	duration varchar(20),
	listed_in varchar(180),
	description varchar(300)
);


select * from netflix;

select count(*) as total_movies from netflix;

select type from netflix;
select distinct type from netflix;
-- 15 problems to solves from netflix dataset 
-- 1) count no of movie vs  tv shows from netflix 

select   count(distinct type ) as netflix_type_count_no from netflix ;
select type as movie_tvshow_count , count(*) from netflix group by type;

-- 2) find the most common rating fro tvshow as well as movie 
select * from netflix;
select type , rating from netflix;
-- check count for all type 
select type, rating,
count(*)
from netflix

 group by 1,2 
 order by count desc ;
-- most rating for type - movie 
select type, rating,
--max(rating)
count(*)
from netflix
where type = 'Movie'
 group by 1,2 
 order by count desc limit 1;
select type , rating from netflix;
-- most time rating for tv show 
select type, rating,
count(*)
from netflix
where type = 'TV Show'
 group by 1,2 
 order by count desc limit 1;

-- rank by

select type, rating,
count(*), rank() over(partition by type 
      order by count(*) desc) as ranking
from netflix
where type = 'TV Show'
 group by 1,2 
 --order by count desc ;

 -- 
select type, rating from 
(
	 select
	 	type, rating,
		count(*), rank() over(partition by type 
      	order by count(*) desc) as ranking
		from netflix
		
 		group by 1,2  )
as t1 where ranking =1 ;

-- Q3) list all the movie  realeased in
-- in year 2020

select * from netflix 
	where release_year =2020 and type='Movie';

--- find the top 5 countries with 
-- the most content on netflix;

select * from netflix;
SELECT 
    UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country, 
    COUNT(show_id) AS total_count
FROM netflix
WHERE country IS NOT NULL
GROUP BY new_country
ORDER BY total_count desc limit 5 ;

---  with the use of view with option 
WITH new_countries AS (
    SELECT 
        show_id, 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country
    FROM netflix
    WHERE country IS NOT NULL
)
SELECT 
    new_country,
    COUNT(*) AS country_count,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
FROM new_countries
GROUP BY new_country
ORDER BY country_count DESC
LIMIT 5;

---- find out the longest movie 
select * from netflix;
select distinct duration from netflix ;

select title, duration from netflix 
where type= 'Movie' and duration is not null
 
order by duration desc limit 1 ;

---- find the contect added in the last 5 year 
select * from netflix;

select distinct date_added from netflix;

SELECT title, type, date_added
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') 
    >= CURRENT_DATE - INTERVAL '5 years';

--- find out the movie?tvshows directiored by 'Rajiv Chilaka'

select * from netflix 
where director like '%Rajiv Chilaka%'


-- list all tv shows with season more than 5 seasons 

SELECT *
FROM netflix
WHERE type = 'TV Show'
AND SPLIT_PART(duration, ' ', 1)::numeric > 5;

--- count the no of content item in genre  

select * from netflix;

SELECT 
    TRIM(SPLIT_PART(listed_in, ',', genre_index)) AS genre, 
    COUNT(*) AS content_count
FROM (
    SELECT listed_in, generate_series(1, array_length(string_to_array(listed_in, ','), 1)) AS genre_index
    FROM netflix
) AS genre_data
GROUP BY genre
ORDER BY content_count DESC;

---- find each year and the avg no of content realeased by india on netflix 
-- return top 5 year with highest avg content realease 

select * from netflix;


SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS release_year,
    COUNT(*) AS content_count
FROM netflix
WHERE POSITION('India' IN country) > 0
AND date_added IS NOT NULL
GROUP BY EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY'))
ORDER BY content_count DESC
LIMIT 5;


--- list the movie which are documentries 

select * from netflix;

select type , listed_in from netflix where listed_in ilike '%Documentaries%';

--- find the content without the director 

select * from netflix where director is null;

--- FIND MOVIE WHERE ACTOR WAS SALMAN KHAN IN LAST 10 YEAR ;

SELECT * 
FROM netflix 
WHERE casting ILIKE '%Salman Khan%' and release_year>= extract(Year from current_DATE)-10;

-- find top 10 actor who appered in the highsest no of movie produe in india 
select * from netflix

select actor, count(*) as movie_count from (
	
	select unnest(string_to_array(casting,', ')) as actor from netflix            
	where type ='Movie'  and casting is not null and  country ilike '%India%')
	as actor_movie

group by actor 
order by movie_count desc 
limit 10;

