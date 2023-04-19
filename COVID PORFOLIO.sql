SELECT *
FROM CovidDeaths$
ORDER BY 3,4

SELECT *
FROM CovidVaccinations$
ORDER BY 3,4

--SELECT DATA 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER bY 1,2

-- The likelihood of dying with covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage_deaths
FROM CovidDeaths$
WHERE location like 'Canada'
ORDER bY 1,2


-- Total Cases vs Population
--Porcentage of population that got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as Percentage_Covid
FROM CovidDeaths$
---WHERE location like 'Canada'
ORDER bY 1,2

--Countries with Hightes infection rate 
SELECT location, population, Max(total_cases) as Higehts_Inf_Rate, MAX((total_cases/population))*100 as Percentage_PopulationInf
FROM CovidDeaths$
GROUP BY location, population
ORDER BY Percentage_PopulationInf DESC

--Countries with Hightes death count per population 
SELECT location, population, Max(cast(total_deaths as int)) as Total_death_count
FROM CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY Total_death_count DESC

--Continentes with Hightes death count 
SELECT continent, Max(cast(total_deaths as int)) as Total_death_count
FROM CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY Total_death_count DESC



--Global numbers
SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Percentage_deaths
FROM CovidDeaths$
WHERE continent is not null
ORDER bY 1,2

---TOTAL POPULATION VS VACCINATION

SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CONVERT(int, V.new_vaccinations)) OVER 
(PARTITION BY D.location ORDER BY D.LOCATION, D.DATE) AS Countvaccinatepeople
FROM CovidDeaths$ AS D
JOIN CovidVaccinations$ AS V
ON D.location = V.location
AND D.date = V.date
WHERE D.continent IS NOT NULL
ORDER BY 2,3


--(USE CTE)

with PopvsVac(continent, location, date, population, new_vaccinations, Countvaccinatepeople)
as
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CONVERT(int, V.new_vaccinations)) OVER 
(PARTITION BY D.location ORDER BY D.LOCATION, D.DATE) AS Countvaccinatepeople
FROM CovidDeaths$ AS D
JOIN CovidVaccinations$ AS V
ON D.location = V.location
AND D.date = V.date
WHERE D.continent IS NOT NULL
)
SELECT *, (Countvaccinatepeople/population)*100 AS Porcentage_Vac
FROM PopvsVac





--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVac
CREATE TABLE #PercentPopulationVac 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Countvaccinatepeople numeric
)

INSERT INTO #PercentPopulationVac
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CONVERT(int, V.new_vaccinations)) OVER 
(PARTITION BY D.location ORDER BY D.LOCATION, D.DATE) AS Countvaccinatepeople
FROM CovidDeaths$ AS D
JOIN CovidVaccinations$ AS V
ON D.location = V.location
AND D.date = V.date
WHERE D.continent IS NOT NULL

SELECT *, (Countvaccinatepeople/population)*100 AS Porcentage_Vac
FROM #PercentPopulationVac


--Creting views for visualazations
CREATE View PercentPopulationVac as
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CONVERT(int, V.new_vaccinations)) OVER 
(PARTITION BY D.location ORDER BY D.LOCATION, D.DATE) AS Countvaccinatepeople
FROM CovidDeaths$ AS D
JOIN CovidVaccinations$ AS V
ON D.location = V.location
AND D.date = V.date
WHERE D.continent IS NOT NULL


SELECT * FROM
PercentPopulationVac
WHERE location = 'Canada'



