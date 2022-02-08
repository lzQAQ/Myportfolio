-- select data that will be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent <> ''
ORDER BY location, date
;

-- Total Cases VS Tital Deaths

SELECT location, date, total_cases, total_deaths,(total_deaths/ total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE location LIKE "%state%"
-- Look at specific United Sate Value
ORDER BY location, date;

-- Looking a Total Cases VS Population(population got Covid)

SELECT location, date, total_cases, population,(total_cases/ population)*100 AS PercentPopulationInfected
FROM coviddeaths
WHERE location LIKE "%state%"
ORDER BY location, date;

-- Looking at Countries with Hightest Infection Rate compare to Population

SELECT location, MAX(total_cases) AS HightestInfectionCount, population,MAX((total_cases/ population)*100 )AS PercentPopulationInfected
FROM coviddeaths
GROUP BY population, location
ORDER BY PercentPopulationInfected DESC;

-- Showing Countries with Hightest Death Count per Population

SELECT location, MAX(CAST(Total_deaths AS UNSIGNED))AS TotalDeathCount
FROM coviddeaths
WHERE continent <>""
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Bresking out by continent
-- Showing continent with the highest death count

SELECT continent, MAX(cast(Total_deaths as UNSIGNED)) as TotalDeathCount
FROM CovidDeaths
WHERE continent <> ''
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers Daily information

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS DOUBLE)) AS total_deaths, SUM(cast(new_deaths AS DOUBLE))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent <> ''
GROUP BY date
ORDER BY date, total_cases;


-- Joing coviddeaths table and covidvaccine table
-- look at total_population VS VAccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS DOUBLE)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent <> ''
ORDER BY dea.location, dea.date;


With PopvsVac (continent, location, date,population, New_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS DOUBLE)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent <> ''
ORDER BY dea.location, dea.date
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS DOUBLE)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date;


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS DOUBLE)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
