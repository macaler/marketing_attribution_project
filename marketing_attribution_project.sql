--Selecting the first timestamp of the simulated data 
--and the last timestamp of the simulated data, to include
--in the Microsoft PowerPoint presentation:
SELECT MIN(timestamp), MAX(timestamp) FROM page_visits;

--Determining how many campaigns there were, what they
--were called, and what their source was:
SELECT DISTINCT utm_campaign AS 'Campaign', utm_source AS 'Source'  FROM page_visits;

--Determining how many pages there were on the 
--CoolTShirts website:
SELECT DISTINCT page_name FROM page_visits;

--Getting the total number of users:
SELECT COUNT(DISTINCT user_id) FROM page_visits;

--Getting users' first touch attribution:
WITH first_touch AS (
    SELECT user_id,
        MIN(timestamp) as first_touch_at
    FROM page_visits
    GROUP BY user_id),
ft_table AS (
SELECT ft.user_id,
    ft.first_touch_at,
    pv.utm_source,
    pv.utm_campaign
FROM first_touch ft
JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_at = pv.timestamp )
SELECT ft_table.utm_source AS 'Source', 
ft_table.utm_campaign AS 'Campaign', 
COUNT(*) AS 'FT Count' 
FROM ft_table GROUP BY 1, 2 ORDER BY 3 DESC;

--Getting users' last touch attribution:
WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    GROUP BY user_id),
lt_table AS (
SELECT lt.user_id,
    lt.last_touch_at,
    pv.utm_source,
    pv.utm_campaign
FROM last_touch lt
JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp )
SELECT lt_table.utm_source AS 'Source', 
lt_table.utm_campaign AS 'Campaign', 
COUNT(*) AS 'LT Count' 
FROM lt_table GROUP BY 1, 2 ORDER BY 3 DESC;

--Getting the number of users who made a purchase:
SELECT COUNT(DISTINCT user_id) FROM page_visits WHERE page_name = '4 - purchase';

--Getting the number of last touches on the purchase page
--each campaign is responsible for:
WITH last_touch AS(
  SELECT user_id, MAX(timestamp) AS last_touch_at
  FROM page_visits
  WHERE page_name = '4 - purchase'
  GROUP BY user_id
),
lt_table AS (
SELECT lt.user_id,
    lt.last_touch_at,
    pv.utm_source,
    pv.utm_campaign
FROM last_touch lt
JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp )
SELECT lt_table.utm_source AS 'Source', 
lt_table.utm_campaign AS 'Campaign', 
COUNT(*) AS 'LT Sale count' 
FROM lt_table GROUP BY 1, 2 ORDER BY 3 DESC;

--Getting the number of users whose first 
--touch was their last touch:
WITH ftlt AS (
  SELECT user_id, MIN(timestamp) as first_touch_at, MAX(timestamp) as last_touch_at,
  page_name FROM page_visits GROUP BY user_id)
SELECT COUNT(*) FROM ftlt WHERE first_touch_at == last_touch_at 
AND page_name = '1 - landing_page';