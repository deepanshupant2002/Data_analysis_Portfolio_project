select * from PortfolioProject..covidDeath
order by 3,4



select * from PortfolioProject..covidVaccination
order by 3,4

-- Select the data that we are going to be using
select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..covidDeath
where continent is not null
order by 1,2

--Looking for total cases vs total deaths
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..covidDeath
where location like 'India'
and continent is not null
order by 1,2

-- Total Cases Vs Population 
-- Shows What Percentage of population got Covid
select location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..covidDeath
--where location like 'India'
order by 1,2

--Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as 
PercentPopulationInfected
from PortfolioProject..covidDeath
--where location like 'India'
group by location,population 
order by PercentPopulationInfected desc

--Countries with Highest Death count per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeath
where continent is not null
group by location
order by TotalDeathCount desc

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeath
where continent is null
group by location
order by TotalDeathCount desc

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeath
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int))/sum(new_cases)*100 
as DeathPercent
from PortfolioProject..covidDeath
where continent is not null
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location
,dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeath dea join
PortfolioProject..covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

-- Using CTE to perform Calculation on Partition By in previous query

with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeath as dea
join PortfolioProject..covidVaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100
from popvsvac

-- Using Temp Table to perform Calculation on Partition by in previous Query

Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric,
new_vaccination numeric, RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeath dea
join PortfolioProject..covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating a View to store data for later Visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 