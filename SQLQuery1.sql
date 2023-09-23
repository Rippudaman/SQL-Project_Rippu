
Select *
From PortfolioProject..CovidDeaths
order by 3,4


Select *
From PortfolioProject..CovidVaccinations
order by 3,4


--Selecting data

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2



--Total cases vs total death
--Percentage of dying if got contact with virus in my country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2



--Total Cases vs Population
--Percentage of population that got covid

Select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2	



--Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
group by location, population
order by PercentagePopulationInfected desc



--Countries with Highest Death count per Population

Select location, MAX(CAST(total_deaths as int)) as TotalDeath
From PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeath desc



--Lets Break this by Continent

Select continent, MAX(CAST(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
--where continent = 'Asia'
group by continent
order by HighestDeathCount desc



--Global Numbers

Select date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2	

Select SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2	


--Vaccination table

select * 
from PortfolioProject..CovidVaccinations



--Join

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--With CTE

With POpvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from POpvsVac 



--Temp Table

drop table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated 



--Creating view to store data for later visuals
use PortfolioProject
GO
Create View PercentPopulationVaccinated1 as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



