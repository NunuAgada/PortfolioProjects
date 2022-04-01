/*
Covid-19 Data Exploration

Skills used:
Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Converting Data Type
*/

SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4



--Selecting data to be used 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 

--Total Cases VS Total Deaths
--This shows the likelihood of dying; if an individual contracts Covid-19 in Nigeria

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Nigeria%' AND continent IS NOT NULL
ORDER BY 1,2 



--Total Cases VS Population
--This shows the percentage of population that got Covid-19

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Total_casesPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent IS NOT NULL
ORDER BY 1,2 



--Countries with the highest Infection rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestTotal_cases, MAX((total_cases/population))*100 AS Total_casesPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT NULL
GROUP BY location, population 
ORDER BY Total_casesPercentage DESC 

 

 --Countries with the highest Death rate compared to Population

 SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



 --Continents with the highest Death rate compared to population

 SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



--Global numbers grouped by date

SELECT date, SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS INT)) AS Total_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%' 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 



--Total Global number

SELECT SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS INT)) AS Total_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%' 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 




--Total Population VS Vaccination

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT))
 OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population) * 100
  FROM PortfolioProject..CovidDeaths dea
   JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date 
   WHERE dea.continent IS NOT NULL
    ORDER BY 1,2,3 



--Using CTE

WITH popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) 
 OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population) * 100
  from PortfolioProject..CovidDeaths dea
   join PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date 
   WHERE dea.continent IS NOT NULL
   --ORDER BY 1,2,3 
	)
	SELECT *, (RollingPeopleVaccinated/ population)* 100 
	FROM popvsvac 



	-- Using TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
	CREATE TABLE #PercentPopulationVaccinated
(
continent varchar(255),
location varchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
	INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) 
 OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population) * 100
  FROM PortfolioProject..CovidDeaths dea
   JOIN PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
   AND dea.date = vac.date 
   WHERE dea.continent IS NOT NULL
   -- ORDER BY 1,2,3 

  SELECT *, (RollingPeopleVaccinated/ population)* 100 
	FROM #PercentPopulationVaccinated


