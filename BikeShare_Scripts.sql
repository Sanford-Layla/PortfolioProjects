--Bike Share Capstone Project  for Google Data Analytics Certificate

--First, let's see how the member v casual riders vary month to month.

SELECT member_casual, month, COUNT(*)
FROM bikeshare..BikeShare1Year
GROUP BY member_casual, month
ORDER BY month

--Now that we know the amount of members and casual riders each month, let's see what bike types each party prefers!
SELECT member_casual, rideable_type, COUNT(*)
FROM BikeShare..BikeShare1Year
GROUP BY rideable_type, member_casual
ORDER BY member_casual

--How does the amount of rides vary month to month?
SELECT month, member_casual, COUNT(*) AS monthly_total
FROM BikeShare..BikeShare1Year
GROUP BY month, member_casual
ORDER BY month

--Let's get the data prepped for visualization!
CREATE VIEW [Monthly Bike Share Statistics] 
AS (
SELECT month, member_casual, COUNT(*) AS monthly_total
FROM BikeShare..BikeShare1Year
GROUP BY month, member_casual)

SELECT *
  FROM BikeShare..[Monthly Bike Share Statistics]
  ORDER BY month