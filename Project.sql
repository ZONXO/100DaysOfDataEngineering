select * 
from CovidDeaths
where continent is not null
order by 3,4


select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
-- show likelihood of dying if you contract covid in thailand
select location,date,total_cases,total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
from CovidDeaths
where location = 'thailand'
order by 1,2

--looking at Total cases vs Population
--show what percentage population got covid
select location,date,population ,total_cases, (total_cases/population)*100 as InfectedPercentage
from CovidDeaths
where location = 'thailand'
order by 1,2

-- Looking at Countries with highest infection rate compared to population
select location,population ,max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectedPercentage
from CovidDeaths
--where location = 'thailand'
group by location,population
order by 4 desc

-- showing continents with highest death count per population
select continent,max(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'thailand'
where continent is not null
group by continent
order by totalDeathCount desc

-- Global numbers
 select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases) * 100) as DeathPercentage
 from PortfolioProject..CovidDeaths
 --where location = 'thailand'
 where continent is not null

-- looking at total population vs vacinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use cte
with PopVsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/population) * 100
from PopVsVac
order by 2,3

-- temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * , (RollingPeopleVaccinated/population) * 100
from #PercentPopulationVaccinated
order by 2,3

-- creating view to store data for visualizations
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated