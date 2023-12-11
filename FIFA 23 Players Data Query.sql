SELECT *
FROM PortfolioProject..FIFA23PlayersData;

---------------------------------CREATE THE BEST TEAM------------------------------
-------------------------TOP PERFORMANCE AND COST EFFICIENT------------------------

SELECT KnownAs, FullName, Overall, Value, BestPosition
FROM PortfolioProject..FIFA23PlayersData
ORDER BY BestPosition, Overall DESC;

--CREATE A TEMPORARY TABLE FOR EACH POSITION'S HIGHEST OVR

DROP TABLE IF EXISTS temp_table
CREATE TABLE temp_table
	(Overall numeric,
	BestPosition nvarchar(255))
INSERT INTO temp_table
SELECT MAX(Overall) As Overall, BestPosition
FROM PortfolioProject..FIFA23PlayersData
GROUP BY BestPosition;

--USE CTE Table 1 for taking all players with the same BestPosition and OVR from the first query using a LEFT JOIN 
--USE CTE Table 2 for determining which players are the most high performing in his BestPosition but has lesser value over a rival for the position
--Lastly, perform a LEFT JOIN to filter all the needed results

WITH CTE_Table_1 (KnownAs, BestPosition, Overall, Value) AS 
(
SELECT KnownAs, FIFA23_2.BestPosition, FIFA23_2.Overall, Value
FROM temp_table AS FIFA23_1 
LEFT JOIN PortfolioProject..FIFA23PlayersData AS FIFA23_2
ON FIFA23_1.Overall = FIFA23_2.Overall
	AND FIFA23_1.BestPosition = FIFA23_2.BestPosition 
--ORDER BY 2,3
),
CTE_table_2 (BestPosition, Overall, Value) AS
(
	SELECT BestPosition, Overall, MIN(Value) AS Value
	FROM CTE_Table_1
	GROUP BY BestPosition, Overall
)
SELECT FIFA23_4.KnownAs, FIFA23_4.FullName, FIFA23_4.BestPosition, FIFA23_4.Overall, FIFA23_4.Value
FROM CTE_table_2 AS FIFA23_3
LEFT JOIN PortfolioProject..FIFA23PlayersData AS FIFA23_4
ON FIFA23_3.Overall = FIFA23_4.Overall
	AND FIFA23_3.BestPosition = FIFA23_4.BestPosition 
	AND FIFA23_3.Value = FIFA23_4.Value;


-------------------------Creating a Scatter Plot-------------------------
----------------OVR vs Value for Different Positions---------------------

SELECT COUNT(BestPosition) AS Total_Players, AVG(Overall) AS Average_Overall, SUM(Value) AS Total_Value, Nationality
FROM PortfolioProject..FIFA23PlayersData
GROUP BY Nationality 
ORDER BY Nationality, Average_Overall DESC;

UPDATE PortfolioProject..FIFA23PlayersData
SET Nationality = 'China'
WHERE Nationality LIKE 'China%'


SELECT BestPosition, COUNT(BestPosition) AS Total_Players, AVG(Overall) AS Average_Overall, SUM(Value) AS Total_Value, Nationality
FROM PortfolioProject..FIFA23PlayersData
GROUP BY Nationality, BestPosition 
ORDER BY Nationality, Average_Overall DESC;

--Checking Purposes

SELECT *
FROM PortfolioProject..FIFA23PlayersData
WHERE Nationality LIKE 'Philippines%'



--------------------------Radar Chart Between The Highest OVR and Highest Value Players-------------------

SELECT TOP(2) [Full Name], [Best Position], Nationality, Overall, Value, Age, [Height(in cm)], [Weight(in kg)], [Attacking Work Rate], [Defensive Work Rate],
			  [Club Name]
FROM PortfolioProject..FIFA23PlayersData
ORDER BY Value DESC;
