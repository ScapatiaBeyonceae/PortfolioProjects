
--dbo.population ──┐
--                 ├── Region + Year ── dbo.temperature
--dbo.migration  ──┘


--Do regions with high net immigration show higher temperature increases?

--Do emigration-heavy countries cool or stabilize?

--Is temperature change sharper in migration “destination” countries?


-- A. Is warming happening equally across hemispheres?

SELECT
    Region,
    Year,
    Average_Temperature
FROM dbo.temperature
WHERE Region IN ('Northern Hemisphere', 'Southern Hemisphere', 'World')
ORDER BY Year;

-- B. Which hemisphere warms faster?

SELECT
    Region,
    AVG(TRY_CAST(Average_Temperature AS FLOAT)) AS Avg_Temperature
FROM dbo.temperature
GROUP BY Region;

-- C. Rate of change

SELECT
    Region,
    Year,
    TRY_CAST(Average_Temperature AS FLOAT) AS Avg_Temp,
    TRY_CAST(Average_Temperature AS FLOAT)
      - LAG(TRY_CAST(Average_Temperature AS FLOAT))
        OVER (PARTITION BY Region ORDER BY Year) AS Temp_Change
FROM dbo.temperature;

--As global population increases, does the Northern Hemisphere warm faster than the Southern Hemisphere?

--STEP 1: Global population by year
SELECT
    Year,
    SUM(Population) AS World_Population
FROM dbo.population
GROUP BY Year;

--STEP 2: Compare with hemispheric temperature
SELECT
    t.Region,
    t.Year,
    t.Average_Temperature,
    p.World_Population
FROM dbo.temperature t
JOIN (
    SELECT Year, SUM(Population) AS World_Population
    FROM dbo.population
    GROUP BY Year
) p
    ON t.Year = p.Year
WHERE t.Region IN ('Northern Hemisphere', 'Southern Hemisphere');

--Results: population growth aligns more closely with Northern Hemisphere warming.
--
--
--Does migration intensify warming where population is already concentrated?

SELECT
    Year,
    SUM(Net_Migration) AS Global_Net_Migration
FROM dbo.migration
GROUP BY Year;

--Then link to hemispheric temperature:

SELECT
    t.Region,
    t.Year,
    t.Average_Temperature,
    m.Global_Net_Migration
FROM dbo.temperature t
JOIN (
    SELECT Year, SUM(Net_Migration) AS Global_Net_Migration
    FROM dbo.migration
    GROUP BY Year
) m
    ON t.Year = m.Year
WHERE t.Region = 'Northern Hemisphere';

--Results Interpretation: migration amplifies existing population pressure.