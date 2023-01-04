SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations
--WHERE continent is not null
--order by 3,4

--Select the data needed

SELECT 
Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
order by 1,2

--Total cases Vs total deaths 
--The likehood of dying if you contat covid19
SELECT 
Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE Location like '%nigeria%'
WHERE continent is not null
order by 1,2

--Total cases VS Population
--Shows what percentage of population is affected by covid

SELECT 
Location, date, population, total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--WHERE Location like '%germany%'
WHERE continent is not null
order by 1,2

--Countries with the highest infection rate compared to the population

SELECT 
Location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--WHERE Location like '%germany%'
WHERE continent is not null
group by Location, population 
order by PercentPopulationInfected desc


--Country with the highest death count per population

SELECT 
Location, MAX(cast(Total_deaths as int)) AS TotaldeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE Location like '%germany%'
WHERE continent is not null
group by Location
order by TotaldeathCount desc



--Grouping by continent

SELECT location, MAX(cast(Total_deaths as int)) AS TotaldeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE Location like '%germany%'
WHERE continent is not null
group by location
order by TotaldeathCount desc


--Continents where the highest death count per continent

SELECT continent, MAX(cast(Total_deaths as int)) AS TotaldeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE Location like '%germany%'
WHERE continent is not null
group by continent
order by TotaldeathCount desc



--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) AS total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE Location like '%nigeria%'
WHERE continent is not null
--Group by date
order by 1,2


--Total population Vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date)
 as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3


--USING CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date)
 as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac



--Temporary Table ###

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--order by 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for visualization


Create View PopVsVac AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date)
 as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3


SELECT *
FROM PopVsVac


