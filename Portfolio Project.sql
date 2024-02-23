--- -- Look at Results for highest GDP recorded in Developed countries only

SELECT *
FROM [Portfolio Project].[dbo].[Coutry_data]
WHERE Status = 'Developed'
ORDER BY GDP DESC;

--- Look at Results for Death Percentage in Developing countries only

SELECT *, (TRY_CAST(AdultMortality AS FLOAT) / NULLIF(TRY_CAST(Population AS BIGINT), 0)) * 100 AS death_rate
FROM [Portfolio Project].[dbo].[Coutry_data]
WHERE Status = 'Developing' AND TRY_CAST(AdultMortality AS FLOAT) IS NOT NULL AND TRY_CAST(Population AS BIGINT) IS NOT NULL AND TRY_CAST(Population AS BIGINT) > 0
ORDER BY death_rate DESC;

--- Look at the Results for Lowest Infant Death's percentage in Developed Countries only in 2015

SELECT *, (TRY_CAST(infantdeaths AS FLOAT) / NULLIF(TRY_CAST(Population AS BIGINT), 0)) * 100 AS infantdeath_rate
FROM [Portfolio Project].[dbo].[Coutry_data] 
WHERE Status = 'Developed'
AND Year = 2015
    AND TRY_CAST(infantdeaths AS FLOAT) IS NOT NULL
    AND TRY_CAST(Population AS BIGINT) IS NOT NULL
    AND TRY_CAST(Population AS BIGINT) > 0
    AND TRY_CAST(infantdeaths AS FLOAT) > 0
ORDER BY infantdeath_rate;

--- Look at the Results of Lowest Infant Deaath's percentage by countries in the year 2010

SELECT Country, Year, (TRY_CAST(infantdeaths AS FLOAT) / NULLIF(TRY_CAST(Population AS BIGINT), 0)) * 100 AS infantdeath_rate
FROM [Portfolio Project].[dbo].[Coutry_data]
WHERE Year = 2010 AND
    TRY_CAST(infantdeaths AS FLOAT) IS NOT NULL 
    AND TRY_CAST(Population AS BIGINT) IS NOT NULL 
    AND TRY_CAST(Population AS BIGINT) > 0 
    AND TRY_CAST(infantdeaths AS FLOAT) > 0
ORDER BY  infantdeath_rate DESC;

--- Look at the ratio between BMI and thinness between 5-9 years old of each Developed countries in 2015


SELECT Country, Year, Status, (CAST(BMI AS FLOAT) / NULLIF(CAST([thinness5-9years] AS FLOAT), 0)) AS BodyMass_ratio
FROM [Portfolio Project].[dbo].[Desease_data]
WHERE 
    Year = 2015 
    AND Status = 'Developed' 
    AND BMI IS NOT NULL 
    AND [thinness5-9years] IS NOT NULL
ORDER BY BodyMass_ratio DESC;


--- Look at the Maximum incoume composition of resources

SELECT MAX(TRY_CAST(Incomecompositionofresources AS DECIMAL(10, 2))) AS MaxIncome
FROM [Portfolio Project].[dbo].[Desease_data]
WHERE Year = 2015;

--- Look at the total percentage of people who had Hepatitis B in all countries in 2015

SELECT  SUM(TRY_CAST(cd.Population AS BIGINT)) AS TotalWorldPopulation, SUM(TRY_CAST(dd.HepatitisB AS INT)) AS TotalHepatitisBCases, 
    (SUM(TRY_CAST(dd.HepatitisB AS FLOAT)) * 1.0 / SUM(TRY_CAST(cd.Population AS BIGINT))) * 100 AS PercentageOfHepatitisBB
FROM [Portfolio Project].[dbo].[Desease_data] dd
INNER JOIN [Portfolio Project].[dbo].[Coutry_data] cd 
ON dd.Country = cd.Country AND dd.Year = cd.Year
WHERE dd.Year = 2015
GROUP BY dd.Year;

---- CTE to calculate the highest cumulative number of HepatitisB cases by countries in the year 2015

WITH CumulativeCases AS (
    SELECT dd.Country, dd.Year, TRY_CAST(dd.HepatitisB AS INT) AS HepatitisB, SUM(TRY_CAST(dd.HepatitisB AS INT)) OVER (PARTITION BY dd.Country ORDER BY dd.Year) AS RollingHepatitisBCases
    FROM [Portfolio Project].[dbo].[Desease_data] dd 
    WHERE dd.Year = 2015 AND dd.HepatitisB IS NOT NULL )
SELECT 
    cc.Country, cc.Year, cc.HepatitisB, cc.RollingHepatitisBCases, 
    TRY_CAST(cd.Population AS BIGINT) AS Population, 
    TRY_CAST(cd.GDP AS DECIMAL(18,2)) AS GDP, 
    TRY_CAST(cd.Lifeexpectancy AS DECIMAL(5,2)) AS Lifeexpectancy,
    (cc.RollingHepatitisBCases * 1.0 / NULLIF(TRY_CAST(cd.Population AS BIGINT), 0)) * 100 AS CumulativeHepatitisBPercentage
FROM CumulativeCases cc
JOIN [Portfolio Project].[dbo].[Coutry_data] cd ON cc.Country = cd.Country AND cc.Year = cd.Year
ORDER BY  CumulativeHepatitisBPercentage DESC;

--- Look at the cumulative number of Measles cases for the year 2015 and the percentage of population.

WITH CumulativeMeasles AS (
    SELECT d.Country, d.Year, TRY_CAST(d.Measles AS BIGINT) AS Measles, TRY_CAST(c.Population AS BIGINT) AS Population 
    FROM [Portfolio Project]. [dbo].[Desease_data] d
    JOIN [Portfolio Project].[dbo].[Coutry_data]  c ON d.Country = c.Country AND d.Year = c.Year
    WHERE d.Year = 2015 AND d.Measles IS NOT NULL AND c.Population IS NOT NULL)
SELECT cm.Country, cm.Year, cm.Measles, cm.Population,(cm.Measles * 1.0 / NULLIF(cm.Population, 0)) * 100 AS PercentPopulationAffected
FROM CumulativeMeasles cm
ORDER BY PercentPopulationAffected DESC;

--- Creating View to store data for later visualizations

CREATE VIEW [dbo].[PercentPopulationAffected2015] AS
SELECT 
    dd.Country, 
    dd.Year, 
    dd.Measles, 
    dd.HepatitisB, 
    cd.Population, 
    (dd.Measles * 1.0 / NULLIF(cd.Population, 0)) * 100 AS PercentPopulationAffectedByMeasles, 
    (dd.HepatitisB * 1.0 / NULLIF(cd.Population, 0)) * 100 AS PercentPopulationAffectedByHepatitisB
FROM 
    [dbo].[Desease_data] dd
JOIN 
    [dbo].[Coutry_data] cd ON dd.Country = cd.Country AND dd.Year = cd.Year
WHERE 
    dd.Year = 2015;

