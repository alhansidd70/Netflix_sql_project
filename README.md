# Netflix Movies and TV Shows Data Analysis using SQL

![Netflix Logo](https://github.com/alhansidd70/Netflix_sql_project/blob/main/logo.png)

## Overview

This project contains a collection of SQL queries used to analyze the Netflix Titles Dataset. The goal of this analysis is to extract meaningful insights from the data, such as content trends, popular genres, director contributions, actor appearances, and release patterns across different years and countries.

The dataset includes information like title, type (Movie/TV Show), director, cast, country, release year, duration, and more. Using SQL, I performed various operations including filtering, aggregation, transformation, and grouping to answer specific questions about the content available on Netflix.

This project is useful for:

  > Practicing intermediate-to-advanced SQL concepts (e.g., GROUP BY, UNNEST, SPLIT_PART, CAST, subqueries)
 > Exploring real-world datasets
 > Building an analytics portfolio


## Objective
The primary objective of this project is to analyze Netflix's content catalog using SQL by answering a variety of real-world data-driven questions. This includes identifying patterns in content type, release years, genres, countries of production, durations, and key contributors such as directors and actors.

Through this analysis, the project aims to:

 Gain insights into Netflix’s content distribution across years and countries.

 Understand user engagement patterns based on content types and genres.

 Apply SQL functions and techniques on a real dataset to strengthen data analysis skills.

 Demonstrate the ability to solve analytical problems using efficient SQL queries.


 ## Dataset
 The data for this project is sourced from the Kaggle dataset:
 
  •Dataset link: [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

``` sql
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
```


## Business Problems and Solutions


 ### 1. Count the Number of Movies vs TV Shows

 ``` sql
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;
```
**Objective**: Determine the distribution of content types on Netflix.


### 2. Find the Most Common Rating for Movies and TV Shows
``` sql
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
```
**Objective**: Identify the most frequently occurring rating for each type of content.


### 3. List All Movies Released in a Specific Year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020;

**Objective**: Retrieve all movies released in a specific year.


### 4.Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;
```
**Objective**: Identify the top 5 countries with the highest number of content items.


### 5. Identify the Longest Movie

``` sql
SELECT 
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;
```
**Objective**: Find the movie with the longest duration.


### 6. Find Content Added in the Last 5 Years

``` sql
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```
**Objective**: Retrieve content added to Netflix in the last 5 years.


### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';
```
**Objective**: List all content directed by 'Rajiv Chilaka'.


### 8. List All TV Shows with More Than 5 Seasons

``` sql
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```
**Objective**: Identify TV shows with more than 5 seasons.


### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;
```
**Objective**: Count the number of content items in each genre.


### 10.Find each year and the average numbers of content release in India on netflix.return top 5 year with highest avg content release!

``` sql
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
```
**Objective**: Calculate and rank years by the average number of content releases by India.


### 11. List All Movies that are Documentaries

```sql
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';
```
**Objective**: Retrieve all movies classified as documentaries.


### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```
**Objective**: List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

``` sql
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```
**Objective**: Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;
```
**Objective**: Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```
**Objective**: Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.


## Finding and Conclusions

**Data Distribution**: The dataset includes a wide variety of content types, primarily Movies and TV Shows, with a higher volume of Movies.

**Genre Insights**: The most common genres include Dramas, Comedies, and Documentaries. Genre categorization often includes multiple values, requiring string splitting for analysis.

**Release Trends**: Most content was released between 2010 and 2020, showing Netflix's major growth phase in this period.

**Average Content Release (India)**: India shows a consistent content addition trend with notable spikes in specific years.

**Content Classification**: Content descriptions containing words like kill or violence were labeled as 'Bad', while others were labeled as 'Good', helping in basic sentiment filtering.

**TV Show Analysis**: TV Shows with more than 5 seasons are rare, indicating that most series on Netflix have shorter runs.

**Directors and Casts**: Many entries do not list directors or casts, suggesting incomplete metadata or lesser-known productions.

