SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4
--SELECT *
--FROM PortfolioProject..CovidVaccination$
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2


--Shows death percentage of covid cases per day
--Total covid cases against total deaths 

SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%Philippines%'
	AND total_cases IS NOT NULL
ORDER BY 1,2;


--Shows infected percentage of covid cases per day
--Total covid cases against whole population 

SELECT location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 AS infection_rate
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%Philippines%'
	AND total_cases IS NOT NULL
ORDER BY 1,2;


--Each countries highest infection rate

SELECT location, MAX(total_cases) AS highest_infection_count, population, (CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, population), 0))*100 AS highest_infection_rate
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY highest_infection_rate DESC;


--Highest death rate for each country

SELECT location, MAX(total_cases) AS highest_infection_count, population, (CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, population), 0))*100 AS highest_death_rate
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highest_death_rate DESC;


--Highest death count from each country

SELECT location, CONVERT(float,MAX(total_deaths)) AS highest_death_count
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_count DESC;


--Highest death count of Philippines

SELECT location, CONVERT(float,MAX(total_deaths)) AS highest_death_count
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Philippines'
GROUP BY location;


--Highest death count from each continent

SELECT continent, CONVERT(float,MAX(total_deaths)) AS highest_death_count
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY highest_death_count DESC;


--Global Numbers Per Day

SELECT date, SUM(new_cases) AS infection_count, SUM(new_deaths) AS death_count, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 AS death_percentage_per_day
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;


--Total 

SELECT SUM(new_cases) AS infection_count, SUM(new_deaths) AS death_count, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL


--Joining on two tables

SELECT *
FROM PortfolioProject..CovidDeaths$ AS cd
INNER JOIN PortfolioProject..CovidVaccination$ AS cv
ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY cd.date;


--Looking at total population vs vaccinations

SELECT cd.continent, cd.location, cd.date, population, new_vaccinations,
	SUM(CONVERT(BIGINT, new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS total_new_vaccinations
FROM PortfolioProject..CovidDeaths$ AS cd
INNER JOIN PortfolioProject..CovidVaccination$ AS cv
ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 1,2,3;


--Looking at total population vs vaccinations (Filtering for Philippines)

SELECT cd.continent, cd.location, cd.date, population, new_vaccinations 
FROM PortfolioProject..CovidDeaths$ AS cd
INNER JOIN PortfolioProject..CovidVaccination$ AS cv
ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
	AND new_vaccinations IS NOT NULL
	AND cd.location = 'Philippines'
ORDER BY cd.date;


--Total of vaccinated in the Philippines

SELECT MAX(population) AS total_population, SUM(CONVERT(INT,new_vaccinations)) AS total_vaccinations, SUM(CONVERT(INT,new_vaccinations))/MAX(population) AS vaccination_percentage
FROM PortfolioProject..CovidDeaths$ AS cd
INNER JOIN PortfolioProject..CovidVaccination$ AS cv
ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
	AND new_vaccinations IS NOT NULL
	AND cd.location = 'Philippines';


--Use Common Table Expressions (CTE)
--CTE starts with a 'With', followed by an Expression Name

WITH Pop_vs_Vac (continent, location, date, population, new_vaccinations, total_new_vaccinations) AS	
(
SELECT cd.continent, cd.location, cd.date, population, new_vaccinations,
	SUM(CONVERT(BIGINT, new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS total_new_vaccinations
FROM PortfolioProject..CovidDeaths$ AS cd
INNER JOIN PortfolioProject..CovidVaccination$ AS cv
ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
	AND new_vaccinations IS NOT NULL
)
SELECT *, (total_new_vaccinations/population)*100 AS total_vaccination_percentage
FROM Pop_vs_Vac;


--Use Temporary SQL Table
--'CREATE TABLE' statement used to create, followed by name given to temporary table

DROP TABLE IF EXISTS temp_table
CREATE TABLE temp_table
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	total_new_vaccinations numeric
)
INSERT INTO temp_table
SELECT cd.continent, cd.location, cd.date, population, new_vaccinations,
	SUM(CONVERT(BIGINT, new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS total_new_vaccinations
FROM PortfolioProject..CovidDeaths$ AS cd
INNER JOIN PortfolioProject..CovidVaccination$ AS cv
ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 1,2,3;

SELECT *, (total_new_vaccinations/population)*100 AS total_vaccination_percentage
FROM temp_table;


--Create View

CREATE VIEW Percent_Population_Vaccinated AS
SELECT cd.continent, cd.location, cd.date, population, new_vaccinations,
	SUM(CONVERT(BIGINT, new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS total_new_vaccinations
FROM PortfolioProject..CovidDeaths$ AS cd
INNER JOIN PortfolioProject..CovidVaccination$ AS cv
ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;


--Query off of the created view

SELECT *
FROM Percent_Population_Vaccinated;