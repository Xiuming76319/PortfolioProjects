
Select *
From ProfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From ProfolioProject..CovidVaccinations
--order by 3,4

-- Select data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From ProfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths at Canada
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProfolioProject..CovidDeaths
--Where Location like 'Canada'
Where continent is not null
order by 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
From ProfolioProject..CovidDeaths
Where Location like 'Canada'
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
From ProfolioProject..CovidDeaths
-- Where Location like 'Canada'
Group by Location, population
order by InfectionPercentage


-- Showing Countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProfolioProject..CovidDeaths
-- Where Location like 'Canada'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Break by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProfolioProject..CovidDeaths
-- Where Location like 'Canada'
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select date, SUM(new_cases)as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int)) / SUM(new_cases) *100 as DeathPercentage--total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProfolioProject..CovidDeaths
--Where Location like 'Canada'
Where continent is not null
group by date
order by 1,2


-- GlOBAL SUMS

Select SUM(new_cases)as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int)) / SUM(new_cases) *100 as DeathPercentage--total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProfolioProject..CovidDeaths
--Where Location like 'Canada'
Where continent is not null
--group by date
order by 1,2



-- Looking at Total population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea. Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From ProfolioProject..CovidDeaths dea
Join ProfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea. date = vac.date
Where dea.continent is not null
Order by 2,3



-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea. Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From ProfolioProject..CovidDeaths dea
Join ProfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea. date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea. Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From ProfolioProject..CovidDeaths dea
Join ProfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea. date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea. Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From ProfolioProject..CovidDeaths dea
Join ProfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea. date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated