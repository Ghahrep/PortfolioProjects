Select *
from [PortfolioProject ]..['CovidDeaths']

SELECT LOCATION,DATE,total_cases, new_cases,total_deaths,population
from [PortfolioProject ]..['CovidDeaths']
order by 1,2


-- Looking at Total Cases vs. Total Deaths 
-- shows the liklihood of dying of you contract COVID in my country 
SELECT LOCATION,DATE,total_cases, total_deaths, (total_deaths/cast(total_cases as numeric))*100 as death_percentage
from [PortfolioProject ]..['CovidDeaths']
where location like '%states%' and continent is not null 
order by 1,2

-- Looking at Total Cases vs. population 
-- Shows what % of pop got covid 
SELECT LOCATION,DATE,population,total_cases, round((total_cases/population)*100,2) as percentage
from [PortfolioProject ]..['CovidDeaths']
--where location like '%states%'
where continent is not null 
order by 1,2

--What countries have highest infection rates comparied to population 
SELECT LOCATION,population, max(cast(total_cases as int)) as HighestInfectionCount, max((total_cases/population))*100
from [PortfolioProject ]..['CovidDeaths']
--where location like '%states%'
where continent is not null 
group by location,population
order by 4 desc 

--LET'S BREAK THINGS DOWN BY CONTINENT 



-- Showing the continent with the highest death count per population per continent 
SELECT continent,MAX(cast(total_deaths as int)) as totaldeathcount
from [PortfolioProject ]..['CovidDeaths']
--where location like '%states%'
where continent is not null 
group by continent
order by 2 desc


-- Showing the  continent with the highest death count
SELECT continent,MAX(cast(total_deaths as int)) as totaldeathcount
from [PortfolioProject ]..['CovidDeaths']
--where location like '%states%'
where continent is not null 
group by continent
order by 2 desc 

-- Global Numbers 
SELECT DATE,sum(new_cases) as Total_cases,sum(new_deaths) as total_deaths, sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as death_percentage
from [PortfolioProject ]..['CovidDeaths']
--where location like '%states%' and
where continent is not null 
group by date
order by 1,2

-- Looking at total pop vs. vax with CTE 
with popvsVac(Continent,Location,Date,Population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as numeric)) over ( partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(/dea.population)*100
from [PortfolioProject ]..['CovidDeaths'] dea
JOIN [PortfolioProject ]..CovidVaccinations vac
on dea.location = vac.location AND dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100
from popvsVac

--  Temp Table 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as numeric)) over ( partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(/dea.population)*100
from [PortfolioProject ]..['CovidDeaths'] dea
JOIN [PortfolioProject ]..CovidVaccinations vac
on dea.location = vac.location AND dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *, (rollingpeoplevaccinated/population)* 100
from #PercentPopulationVaccinated

-- Create View to store data for later visualizations 

Create View PercentPopulationVaccinated as 
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as numeric)) over ( partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(/dea.population)*100
from [PortfolioProject ]..['CovidDeaths'] dea
JOIN [PortfolioProject ]..CovidVaccinations vac
on dea.location = vac.location AND dea.date = vac.date
where dea.continent is not null 
--order by 2,3

