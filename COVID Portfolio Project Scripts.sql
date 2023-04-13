SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY location, date

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY location, date

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
ORDER BY location, date

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract Covid in your counrty, Example shown is South Korea.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%South Korea%'
ORDER BY location, date

--Looking at the Total Cases vs Population
--Shows what percentage of population for Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Percentage_of_Population_Infected
FROM PortfolioProject..CovidDeaths
WHERE location like '%South Korea%'
ORDER BY location, date

--Looking at countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as Highest_Infection_count, MAX((total_cases/population))*100 AS Percentage_of_Population_Infected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY location,population
ORDER by Percentage_of_Population_Infected desc

--Showing Countries with the Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY location
ORDER BY Total_Death_Count desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing Continents with the highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent IS null
GROUP BY location
ORDER BY Total_Death_Count desc

--GLOBAL NUMBERS

SELECT date,SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

--Looking at Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccination_count
--, (rolling_vaccination_count/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date

-- Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_vaccination_count)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccination_count
--, (rolling_vaccination_count/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY location, date
)
SELECT *, (Rolling_vaccination_count/Population)*100 AS Vaccination_Percentage
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_Vaccinations bigint,
Rolling_Vaccination_Count bigint
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccination_count
--, (rolling_vaccination_count/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY location, date

SELECT *, (Rolling_Vaccination_Count/Population)*100 AS Vaccination_Percentage
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations

CREATE VIEW #PercentPopulationVaccinated 
AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccination_count
--, (rolling_vaccination_count/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date

SELECT *
FROM PercentPopulationVaccinated