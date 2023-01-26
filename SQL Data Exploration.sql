SELECT *
FROM dbo.CovidDeaths
ORDER BY 3, 4

SELECT Location, date, population, total_cases, new_cases, total_deaths
FROM dbo.CovidDeaths
ORDER BY 1, 2

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
FROM dbo.CovidDeaths
WHERE Location like '%India%'
ORDER BY 1, 2

SELECT Location, population, date, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE Location  like '%India%'
ORDER BY 1, 2

SELECT continent, location, population,  MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE location like '%India%'
GROUP BY location, population, continent
ORDER BY PercentPopulationInfected desc

SELECT location, MAX(cast(total_Deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location like '%India%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
 SUM(cast(new_deaths as int))/SUM(New_cases)*100 as  Deaths_Cases_Percentage
FROM dbo.CovidDeaths
--WHERE Location like '%India%' 
WHERE continent is not null
ORDER BY 1, 2

SELECT *
FROM dbo.CovidDeaths as dea
join dbo.CovidVaccinations as vacc
ON dea.location = vacc.location
AND dea.date = vacc.date

select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
from dbo.CovidDeaths as dea
join dbo.CovidVaccinations as vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent is not null
order by 2, 3

select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(CONVERT( bigint, vacc.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
from dbo.CovidDeaths as dea
join dbo.CovidVaccinations as vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent is not null
order by 2, 3

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
PeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(CONVERT( bigint, vacc.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
from dbo.CovidDeaths as dea
join dbo.CovidVaccinations as vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
--WHERE dea.continent is not null
order by 2, 3

SELECT *, (PeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


CREATE VIEW TotalDeathCount as
SELECT location, MAX(cast(total_Deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location like '%India%'
WHERE continent is not null
GROUP BY location
--ORDER BY TotalDeathCount desc


CREATE VIEW PeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(CONVERT( bigint, vacc.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
from dbo.CovidDeaths as dea
join dbo.CovidVaccinations as vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent is not null
--order by 2, 3


CREATE VIEW  DeathsandCasesPercentage as
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
 SUM(cast(new_deaths as int))/SUM(New_cases)*100 as  Deaths_Cases_Percentage
FROM dbo.CovidDeaths
--WHERE Location like '%India%' 
WHERE continent is not null
--ORDER BY 1, 2











