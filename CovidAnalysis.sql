select * from portfolio_project.dbo.CovidDeaths
order by 3,4

select * from portfolio_project.dbo.CovidVaccinations
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from portfolio_project.dbo.CovidDeaths

-- Looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from portfolio_project.dbo.CovidDeaths
where location like '%India%'
order by 1,2

--Looking at Total cases vs population
select location, date, total_cases, population, (total_cases/population)*100 as Casepercentage
from portfolio_project.dbo.CovidDeaths
where location like '%India%'
order by 1,2

-- Looking for Countries with highest infection rate
select location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as PercentPopulationInfected
from portfolio_project.dbo.CovidDeaths
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with max deathcount per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from portfolio_project.dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Showing the above result by continents
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from portfolio_project.dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
select continent, SUM(new_cases) as TotalCases,SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as TotalDeathPercentage
from portfolio_project.dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathPercentage desc

select date, SUM(new_cases) as TotalCases,SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as TotalDeathPercentage
from portfolio_project.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2

Select *
from portfolio_project.dbo.CovidDeaths dea
join portfolio_project.dbo.CovidVaccinations  vac
on dea.location = vac.location
and dea.date = vac.date

--Looking at total population vs Vaccinations
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over(partition by dea.location order by 
dea.location,dea.date) as RollingPeopleVaccinated
from portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
where dea.continent is not null
)
--order by 2,3
select * ,(RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table
drop table if exists #PercentPeopleVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over(partition by dea.location order by 
dea.location,dea.date) as RollingPeopleVaccinated
from portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select * ,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

	-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio_project..CovidDeaths dea
Join portfolio_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

create view PercentagePeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio_project..CovidDeaths dea
Join portfolio_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentagePeopleVaccinated