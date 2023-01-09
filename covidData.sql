SELECT * 
FROM dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM dbo.CovidVaccinations
--ORDER BY 3,4


-- Select the Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE location like 'Lebanon' AND continent is not null
ORDER BY 1,2


-- Looking at the Total Cases vs the Population
-- Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
FROM dbo.CovidDeaths
-- WHERE location like 'Lebanon'
WHERE continent is not null
ORDER BY 1,2


-- Looking at Countries with highest infection rate compared to population
-- without date

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100)
as PercentPopulationInfected
FROM dbo.CovidDeaths
--WHERE location like 'Lebanon'
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 DESC

-- with date
SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100)
as PercentPopulationInfected
FROM dbo.CovidDeaths
--WHERE continent is not null
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC

-- Countries with highest death percentage

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Lets break this down by continent
-- continents with highest death count

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is null
and location not in ('World', 'Lower middle income', 'Low income', 'International', 'High income', 'Upper Middle income'
, 'European Union')
GROUP BY location
ORDER BY TotalDeathCount DESC



--Global Numbers
-- by date

SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Percentage
FROM dbo.CovidDeaths
-- WHERE location like 'Lebanon' 
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--total cases ever
SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Percentage
FROM dbo.CovidDeaths
WHERE continent is not null



--Looking at total population vs vaccinations
-- I used "bigint" cuz the number was too large

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent Is NOT NULL
ORDER BY 2,3


-- Use CTE to look at total population vs vaccination

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent Is NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 as PopvsVac
FROM PopvsVac



-- Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
--WHERE dea.continent Is NOT NULL
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 as PopvsVac
FROM #PercentPopulationVaccinated




-- Creating View to Store Data for Later Visualizations


CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent Is NOT NULL
--ORDER BY 2,3

