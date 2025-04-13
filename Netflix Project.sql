--NETFLIX PROJECT

Create table Netflix
(
	show_id	Varchar(6),
	type varchar(10),
	title varchar (150),
	director varchar (280),
	casts varchar(1000),
	country	varchar(125),
	date_added 	varchar(50),
	release_year int,
	rating varchar(10),	
	duration varchar(15),
	listed_in varchar(80),
	description varchar(300)
);

select*from Netflix;

select count(*) as total_content 
from netflix;

select Distinct type from
netflix;

select count(show_id)
from netflix;

--15 Business Problems 


--1-Count the number of Movies vs TV Shows.

select type,
count(show_id) as total_content
from netflix
group by type;


--OR

select type,
count(*) as total_content
from netflix
group by type;



--2-Find the most common rating for movies and TV shows

select type,
rating 
from
 (
	 select 
		type,
		rating,
		count(show_id),
		rank()over(Partition by type Order by count(show_id)Desc)as ranking
	 from netflix
	 group by 1,2
	)as t1
	where 
	ranking=1;
 



--3-List all movies released in a specific year (e.g., 2020)

select* 
from netflix
where
type='Movie'
AND
release_year=2020 ;



--4-Find the top 5 countries with the most content on Netflix

select
	Unnest(STRING_TO_ARRAY(country,','))as new_country,
	count(show_id)
from netflix
group by 1
order by 2 DESC
Limit 5;



--5-Identify the longest movie 

select*from Netflix
where
	type='Movie'
	AND
	duration= (Select max(duration)from netflix);



6-Find content added in the last 5 years

select
	*
                     --TO_DATE(date_added,'Month DD,YYYY') --->convert from string to Date format
from netflix
where
	TO_DATE(date_added,'Month,DD,YYYY')>= current_date-interval '5 years';
 
select Current_date-interval '5 years'  -- returns 5  years old date



7-Find all the movies/TV shows by director 'Rajiv Chilaka'

select *
from netflix
where director ILIKE '%Rajiv Chilaka%';     --or we can use 'LIKE' function also instead of ILIKE,  also ILIKE works with the case sensitive also 



8-List all TV shows with more than 5 seasons

SELECT
	*
FROM netflix
WHERE 
  type = 'TV Show'
  AND duration ILIKE '%Season%'
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5; --The CAST function is used to convert a value from one data type to another


--SPLIT_PART function is a string function that allows you to split a string into parts using a delimiter and then pick one of those parts.
--eg

SELECT 
	SPLIT_PART('Apple Banana Mango',' ',1);  --Here 1(arguments) means it gives value="Apple".



--9-Count the number of content items in each genre

--STRING_TO_ARRAY():Split a string into an array using a delimiter.

select
	 UNNEST(STRING_TO_ARRAY(listed_in,','))as genre,
	--listed_in,
	COUNT (show_id)
from NETFLIX
group by 1
order by 2 DESC;




--10-Find the average release year for content produced in a specific country release by India on Netflix.
   return top 5 years with highest average content release.

select 
	Extract(Year from TO_DATE(date_added,'Month DD,YYYY')),
	count(show_id) as yearly_content,
	ROUND
	(count(show_id)::numeric/(Select count(*)from netflix WHERE country='India')::numeric*100,2) as avg_content_per_year
from netflix
where country='India'
Group by 1



--11-List all movies that are documentaries

select 
	*
from netflix
where
listed_in Ilike '%documentaries%'



--12-Find all content without a director

SELECT * from
netflix 
where 
	director IS NULL

	

--13-Find how many movies actor 'Salman Khan' appeared in last 10 years

SELECT
	*
FROM netflix 
WHERE
	casts ILIKE '%Salman Khan%'
	AND
	release_year> EXTRACT(YEAR FROM CURRENT_DATE)-10;



--14-Find the top 10 actors who have appeared in the highest number of movies produced in India

select 
	--show_id,
	--casts,
	UNNEST(STRING_TO_ARRAY(casts,','))as actors,
	count(*) as total_content
from netflix
where 
	country ILIKE '%India%'
group by 1
order by 2 DESC
LIMIT 10;
	

	

--15-Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. 
   --Label content containing these keywords as 'Bad' and all other content as 'Good'. 
   --Count how many items fall into each category.



WITH new_table
AS
(
 SELECT
 *,
 CASE
 WHEN
 	description ILIKE '%kill%' OR
	description ILIKE '%violence%' THEN 'Bad Content'
	ELSE 'Good Content'
END category
FROM netflix
)
SELECT
	category,
	COUNT(*) AS Total_content
FROM  new_table
GROUP BY 1;

