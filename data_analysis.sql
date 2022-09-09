-- 1. Size of neighbourhoods in 2021

-- 1-1. Join dbo.pro_historical_res with dbo.neighbourhoods to get geospatial data
-- Tableau chart #1 ("Number of Properties" in "Size & Value" tab): neighbourhood "Oliver" has the highest number of properties
-- Tableau chart #4 ("Interactive Map" tab)

SELECT		pro.Neighbourhood
			    , COUNT(pro.[Account Number]) AS [Number of Properties]
			    , nbh.[Geometry_Multipolygon]
FROM		  yeg_property.dbo.pro_historical_res AS pro
LEFT JOIN	yeg_property.dbo.neighbourhoods AS nbh
			ON	pro.Neighbourhood = nbh.[Descriptive_Name]
WHERE		  [Assessment Year] = 2021
GROUP BY	pro.Neighbourhood
			    , nbh.[Geometry_Multipolygon]
ORDER BY	2 DESC;

-- we see null values in the column [Geometry_Multipolygon]
-- count the nulls

WITH neighbourhood_geom AS(
SELECT		pro.Neighbourhood
			    , COUNT(pro.[Account Number]) AS [Number of Properties]
			    , nbh.[Geometry_Multipolygon]
FROM		  yeg_property.dbo.pro_historical_res AS pro
LEFT JOIN	yeg_property.dbo.neighbourhoods AS nbh
			ON	pro.Neighbourhood = nbh.[Descriptive_Name]
WHERE		  [Assessment Year] = 2021
GROUP BY	pro.Neighbourhood
			  , nbh.[Geometry_Multipolygon])

SELECT		*
FROM		neighbourhood_geom
WHERE		[Geometry_Multipolygon] IS NULL;

-- 8 nulls in [Geometry_Multipolygon] are found
-- from comparing dbo.pro_historical_res.[Neighbourhood] and dbo.neighbourhoods.[Descriptive_Name], 
-- we can tell these nulls are due to typos or different variations of the same neighbourhood -> back to cleaning


-- 1-2. Clean the data and get the complete joined table of dbo.pro_historical_res and dbo.neighbourhoods

-- 1-2-1. Fix the typos

-- 9281 rows affected
UPDATE	yeg_property.dbo.pro_historical_res 
SET			Neighbourhood = 'Rapperswill'
WHERE		Neighbourhood = 'Rapperswil';

-- 3355 rows affected
UPDATE	yeg_property.dbo.pro_historical_res 
SET			Neighbourhood = 'Westbrook Estates'
WHERE		Neighbourhood = 'Westbrook Estate';

-- 49 rows affected
UPDATE	yeg_property.dbo.pro_historical_res 
SET			Neighbourhood = 'River Valley Windermere'
WHERE		Neighbourhood = 'River Valley Windemere';


-- 1-2-2. Unify the spelling (remove variations of the same neighbourhood)

-- 314 rows affected
UPDATE	yeg_property.dbo.pro_historical_res
SET			Neighbourhood = 'Anthony Henday South East'
WHERE		Neighbourhood = 'Anthony Henday Southeast';

-- 124 rows affected
UPDATE	yeg_property.dbo.pro_historical_res
SET			Neighbourhood = 'Southeast Industrial'
WHERE		Neighbourhood = 'Southeast (Annexed) Industrial';

-- 1 row affected
UPDATE	yeg_property.dbo.neighbourhoods
SET			[Descriptive_Name] = 'Keswick Area'
WHERE		[Descriptive_Name] = 'Keswick';

-- 1 row affected
UPDATE	yeg_property.dbo.neighbourhoods
SET			[Descriptive_Name] = 'Mcconachie Area'
WHERE		[Descriptive_Name] = 'Mcconachie';


-- 1-2-3. Drop the rows where no valid data is available
-- 'Rural West Big Lake' is present in dbo.pro_historical_res only, and no geospatial data is available at the moment: 481 rows affected

DELETE 
FROM	  yeg_property.dbo.pro_historical_res
WHERE	  Neighbourhood = 'Rural West Big Lake';


-- 1-2-4. Confirm that there are no more nulls in the joined table

WITH neighbourhood_geom AS(
SELECT		pro.Neighbourhood
			    , COUNT(pro.[Account Number]) AS [Number of Properties]
			    , nbh.[Geometry_Multipolygon]
FROM		  yeg_property.dbo.pro_historical_res AS pro
LEFT JOIN	yeg_property.dbo.neighbourhoods AS nbh
			ON	pro.Neighbourhood = nbh.[Descriptive_Name]
WHERE		  [Assessment Year] = 2021
GROUP BY	pro.Neighbourhood
			    , nbh.[Geometry_Multipolygon])

SELECT	*
FROM		neighbourhood_geom
WHERE		[Geometry_Multipolygon] IS NULL;


-- 2. Average & median assessed property values in the top 20 largest neighbourhoods
-- Tableau chart #2 ("Property Values" in the "Size & Value" tab): Windermere has the highest average value, and Secord has the highest median value

-- average values
-- this returns 19, not 20 rows

SELECT		Neighbourhood
			    , ROUND(AVG([Assessed Value]), -2) AS [Average Assessed Value]
FROM		  yeg_property.dbo.pro_historical_res
WHERE		  [Assessment Year] = 2021 
			    AND Neighbourhood IN (SELECT TOP 20(Neighbourhood) 
                                FROM yeg_property.dbo.pro_historical_res 
                                GROUP BY Neighbourhood 
                                ORDER BY COUNT(DISTINCT([Account Number])) DESC)
GROUP BY	Neighbourhood
ORDER BY	2 DESC;

-- it turns out that I missed removing a different variation of "South Terwillegar" from the table in the previous cleaning step

WITH largest AS(
SELECT    TOP 20(Neighbourhood) 
FROM      yeg_property.dbo.pro_historical_res 
GROUP BY  Neighbourhood 
ORDER BY  COUNT(DISTINCT([Account Number])) DESC)
     , mean_value AS(
SELECT		Neighbourhood
			    , ROUND(AVG([Assessed Value]), -2) AS [Average Assessed Value]
FROM		  yeg_property.dbo.pro_historical_res
WHERE		  [Assessment Year] = 2021 
GROUP BY	Neighbourhood)

SELECT    *
FROM      largest
LEFT JOIN mean_value
      ON  largest.Neighbourhood = mean_value.Neighbourhood

-- update the table dbo.pro_historical_res with "South Terwillegar" as the name of the neighbourhood
-- 4515 rows affected

UPDATE	yeg_property.dbo.pro_historical_res
SET			Neighbourhood = 'South Terwillegar'
WHERE		Neighbourhood = 'Terwillegar South';

-- get both average and median assessed values for the top 20 largest neighbourhoods in the updated table

SELECT		DISTINCT(Neighbourhood)
			    , ROUND((AVG([Assessed Value]) OVER(PARTITION BY Neighbourhood)), -2) AS [Average Assessed Value]
			    , PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY [Assessed Value] DESC)
									               OVER(PARTITION BY Neighbourhood) AS [Median Assessed Value]
FROM		yeg_property.dbo.pro_historical_res
WHERE		[Assessment Year] = 2021
			  AND Neighbourhood IN (SELECT TOP 20(Neighbourhood) 
									            FROM yeg_property.dbo.pro_historical_res 
									            GROUP BY Neighbourhood 
									            ORDER BY COUNT(DISTINCT([Account Number])) DESC)
ORDER BY	3 DESC;

-- average & median for all neighbourhoods in the city

SELECT		DISTINCT(Neighbourhood)
			    , ROUND((AVG([Assessed Value]) OVER(PARTITION BY Neighbourhood)), -2) AS [Average Assessed Value]
			    , PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY [Assessed Value] DESC)
					                			 OVER(PARTITION BY Neighbourhood) AS [Median Assessed Value]
FROM		  yeg_property.dbo.pro_historical_res
WHERE		  [Assessment Year] = 2021
ORDER BY	3 DESC;

-- put everything together for the map in Tableau: Number of properties, Geometry_Multipolygon, Average Values, and Median Values

WITH	neighbourhood_geom AS(
SELECT		pro.Neighbourhood
			    , COUNT(pro.[Account Number]) AS [Number of Properties]
			    , nbh.[Geometry_Multipolygon]
FROM		  yeg_property.dbo.pro_historical_res AS pro
LEFT JOIN	yeg_property.dbo.neighbourhoods AS nbh
			ON	pro.Neighbourhood = nbh.[Descriptive_Name]
WHERE		  [Assessment Year] = 2021
GROUP BY	pro.Neighbourhood
			    , nbh.[Geometry_Multipolygon])
		, mean_median_values AS(
SELECT		DISTINCT(Neighbourhood)
			    , ROUND((AVG([Assessed Value]) OVER(PARTITION BY Neighbourhood)), -2) AS [Average Assessed Value]
			    , PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY [Assessed Value] DESC)
									               OVER(PARTITION BY Neighbourhood) AS [Median Assessed Value]
FROM		  yeg_property.dbo.pro_historical_res
WHERE		  [Assessment Year] = 2021)


SELECT		       *
FROM		         neighbourhood_geom AS ng
FULL OUTER JOIN	 mean_median_values AS mmv
			       ON	 ng.Neighbourhood = mmv.Neighbourhood
ORDER BY         2 DESC;


-- 3. Changes in value over the last 10 years (median value in each neighbourhood)
-- Tableau chart #3 ("Changes in Value" tab)

SELECT		DISTINCT(Neighbourhood)
			    , [Assessment Year] 
			    , PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY [Assessed Value] DESC)
									               OVER(PARTITION BY Neighbourhood, [Assessment Year]) AS [Median Assessed Value]
FROM		  yeg_property.dbo.pro_historical_res
WHERE		  Neighbourhood IN (SELECT TOP 20(Neighbourhood) 
									          FROM yeg_property.dbo.pro_historical_res 
									          GROUP BY Neighbourhood 
									          ORDER BY COUNT(DISTINCT([Account Number])) DESC)
ORDER BY	1, 2;
