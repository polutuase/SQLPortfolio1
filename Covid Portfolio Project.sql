--select * 
--from CovidDeaths
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
order by 1,2

-- Change the data type in total_deaths
ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths FLOAT;

-- Change the data type in total_cases
ALTER TABLE CovidDeaths
ALTER COLUMN total_cases FLOAT;

-- Looking at total cases vs total deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
order by 1,2

-- shows likelihood of dying if you contract covid in Nigeria
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%igeria'
order by 1,2

-- looking at the total cases versus the population
-- shows what percentage of the population has gotten Covid
Select Location, date, total_cases, Population, (total_cases/Population)*100 as PercentagewithCovid
from CovidDeaths
where location like '%igeria'
order by 1,2

-- looking at countries with highest infection rate compared to population
Select Location, Population, max(total_cases) as HighestCases, Max((total_cases/Population))*100 as PercentageInfected
from CovidDeaths
--where location like '%igeria'
Group by location, Population
order by PercentageInfected desc

-- Showing Countries with highest death count
Select Location, max(total_deaths) as TotalDeaths
from CovidDeaths
--where location like '%igeria'
Where continent is not null
Group by location 
order by TotalDeaths desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
Select continent, max(total_deaths) as TotalDeaths
from CovidDeaths
--where location like '%igeria'
Where continent is not null
Group by continent 
order by TotalDeaths desc

--- showing continents withthe highest death counts per population
Select continent, max(total_deaths) as TotalDeaths
from CovidDeaths
--where location like '%igeria'
Where continent is not null
Group by continent 
order by TotalDeaths desc

--- GLOBAL NUMBERS
Select date, sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(cast(new_cases as int))*100 --total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
-- where location like '%igeria'
where continent is not null and (new_cases) is not null
Group by date
order by 1,2

-- Refined Code
SELECT
    date,
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0) * 100 AS DeathPercentage
FROM
    CovidDeaths
WHERE
    continent IS NOT NULL
GROUP BY
    date
HAVING
    SUM(new_cases) <> 0
ORDER BY
    1,2;

-- Another refined code
SELECT
    date,
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    CASE
        WHEN SUM(new_cases) <> 0 THEN
            SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100
        ELSE
            0 -- or any other default value you want
    END AS DeathPercentage
FROM
    CovidDeaths
WHERE
    continent IS NOT NULL
GROUP BY
    date
ORDER BY
    1,2;

select * from 
CovidDeaths dea
join
CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

-- Total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths dea
join
CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null and dea.location = 'Nigeria'
order by 1,2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join
CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
with PopsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join
CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100
From PopsVac

-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NEw_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join
CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating View to STore Data for Later Visualisation

Create view PercentPopulationVaccinated1 as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join
CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * from PercentPopulationVaccinated1