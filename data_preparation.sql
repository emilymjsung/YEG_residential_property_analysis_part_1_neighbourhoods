-- [Table 1: dbo.pro_historical]

-- 1. Data check

-- 1-1. Import data from 6 split CSV files and join them as a new table (data doesn't show correctly when uploaded as a whole in SQL Server v18.11.1)
-- function (to split a CSV file into multiple smaller files) code source: 
-- https://python.plainenglish.io/split-a-large-csv-file-randomly-or-equally-into-smaller-files-76f7bb734459

SELECT  *
INTO		yeg_property.dbo.pro_historical
FROM		yeg_property.dbo.pro_historical_1 
UNION ALL	
SELECT	*
FROM		yeg_property.dbo.pro_historical_2
UNION ALL
SELECT	*
FROM		yeg_property.dbo.pro_historical_3 
UNION ALL
SELECT	*
FROM		yeg_property.dbo.pro_historical_4
UNION ALL
SELECT	*
FROM		yeg_property.dbo.pro_historical_5
UNION ALL
SELECT	*
FROM		yeg_property.dbo.pro_historical_6

-- 1-2. Total row count vs. Unique row count: 3,798,629 vs. 423,114

SELECT	COUNT([Account Number]) AS property_count
	, COUNT(DISTINCT([Account Number])) AS unique_property_count
FROM	yeg_property.dbo.pro_historical;

-- 1-3. Check duplicates in 2 ways

-- 1-3-1. Check with HAVING: each account should have 10 records for each year, 2012-2021 / no duplicates found

SELECT		[Account Number]
		, COUNT(*) AS count
FROM		yeg_property.dbo.pro_historical
GROUP BY	[Account Number]
HAVING		COUNT(*) > 10
ORDER BY	COUNT(*) DESC;

-- 1-3-2. Check with DISTINCT: 337,298 accounts in 2012 and 413,809 accounts in 2021 / no duplicates found

SELECT	COUNT([Account Number]) AS pro_count_2012
	, COUNT(DISTINCT([Account Number])) AS unique_pro_count_2012
FROM	yeg_property.dbo.pro_historical
WHERE	[Assessment Year] = 2012;
GO
SELECT	COUNT([Account Number]) AS pro_count_2021
	, COUNT(DISTINCT([Account Number])) AS unique_pro_count_2021
FROM	yeg_property.dbo.pro_historical
WHERE	[Assessment Year] = 2021;

-- 2. Data Preparation

-- 2-1. Create a new table "pro_historical_res" that only contains residential properties and selected columns for the analysis 

SELECT	[Account Number]
	, [Assessment Year]
	, [House Number]
	, [Street Name] 
	, Latitude
	, Longitude
	, Neighbourhood
	, [Actual Year Built] 
	, Garage
	, Zoning
	, [Lot Size]
	, [Assessed Value] 
INTO	yeg_property.dbo.pro_historical_res 
FROM	yeg_property.dbo.pro_historical
WHERE	[Assessed Value] IS NOT NULL 
	AND [Assessed Value] <> 0
	AND (([Assessment Class 1] = 'RESIDENTIAL' AND [Assessment Class % 1] > 50)
	OR ([Assessment Class 2] = 'RESIDENTIAL' AND [Assessment Class % 2] > 50)
	OR ([Assessment Class 3] = 'RESIDENTIAL' AND [Assessment Class % 3] > 50));

-- count the rows: 3,541,140 rows / 395,355 unique rows

SELECT	COUNT([Account Number]) AS pro_res_count
    	, COUNT(DISTINCT([Account Number])) AS unique_pro_res_count
FROM	yeg_property.dbo.pro_historical_res;

-- 2-2. Change “Y/N” to “Yes/No” in the Garage column
-- 3,541,140 rows affected. No null values in the Garage column.

UPDATE  yeg_property.dbo.pro_historical_res
SET     Garage = CASE	WHEN Garage = 'Y' THEN 'Yes'
			WHEN Garage = 'N' THEN 'No' END;

-- 2-3. Build InitCap function, change and update the string format of the columns, [Neighbourhood] and [Street Name]

-- 2-3-1. Build InitCap function
-- function code source: http://www.sql-server-helper.com/functions/initcap.aspx

CREATE FUNCTION [dbo].[InitCap] ( @InputString varchar(4000) ) 
RETURNS VARCHAR(4000)
AS
BEGIN

DECLARE @Index          INT
DECLARE @Char           CHAR(1)
DECLARE @PrevChar       CHAR(1)
DECLARE @OutputString   VARCHAR(250)

SET @OutputString = LOWER(@InputString)
SET @Index = 1

WHILE @Index <= LEN(@InputString)
BEGIN
    SET @Char     = SUBSTRING(@InputString, @Index, 1)
    SET @PrevChar = CASE WHEN @Index = 1 THEN ' '
                         ELSE SUBSTRING(@InputString, @Index - 1, 1)
                    END

    IF @PrevChar IN (' ', ';', ':', '!', '?', ',', '.', '_', '-', '/', '&', '''', '(')
    BEGIN
        IF @PrevChar != '''' OR UPPER(@Char) != 'S'
            SET @OutputString = STUFF(@OutputString, @Index, 1, UPPER(@Char))
    END

    SET @Index = @Index + 1
END

RETURN @OutputString

END
GO

-- 2-3-2. Change the format of the column [Neighbourhood] and update the table (e.g., TWIN BROOKS -> Twin Brooks)

UPDATE  yeg_property.dbo.pro_historical_res
SET     [Neighbourhood] = dbo.InitCap([Neighbourhood]);

-- 2-3-3. Change the format of the column [Street Name] and update the table (e.g., 111 AVENUE NW -> 111 Avenue NW)

UPDATE  yeg_property.dbo.pro_historical_res
SET     [Street Name] = dbo.InitCap(LEFT([Street Name], LEN([Street Name]) - 3)) + ' ' + UPPER(RIGHT([Street Name], 2))

------------------------------------------------------------------------------------------------------------------------------------------

-- [Table 2: dbo.neighbourhoods]

-- 1. Data check

-- original file from the link (in README.md) has 7 columns and we only need 2 of them – “Descriptive Name” and “Geometry Multipolygon”
-- some of the cells in the “Geometry Multipolygon” column have over 70K characters and get truncated and/or don’t show correctly when read in Microsoft Excel
-- read the file in Python, subset the data with the 2 columns we need, export the data frame as a CSV file, and import it into SQL Server 
-- (TIPS: make sure the data type of the “Geometry Multipolygon” column is set to “NVARCHAR(MAX)” which has a max size of 536,870,912 characters)
-- the Python code for this is in “importing_neighbourhood_csv.py” in this repository

-- 1-1. Total row count vs. Unique row count: 402

SELECT		COUNT([Descriptive_Name]) AS nbh_count
			, COUNT(DISTINCT([Descriptive_Name])) AS unique_nbh_count
FROM		[yeg_property].[dbo].[neighbourhoods];

-- 1-2. Check nulls: no null values found

SELECT		*
FROM		[yeg_property].[dbo].[neighbourhoods]
WHERE		[Descriptive_Name] IS NULL OR [Geometry_Multipolygon] IS NULL;
