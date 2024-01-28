select *
from PortfolioProject..CovidDeaths
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4

--select Data that I am using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Total Cases Versus Total Deaths

select Location, date, total_cases, total_deaths,  (CAST(total_deaths AS FLOAT)/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--death Percentage

select Location, date, total_cases, total_deaths,  (CAST(total_deaths AS FLOAT)/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Total cases vs Population

select Location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Showing Countries Infection rate
select Location, population, MAX(total_cases) as InfectionCount, MAX((total_cases/population)*100) as InfectionPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, population
order by InfectionPercentage desc


--Showing Countries Death count per population

select Location, MAX(CAST(total_Deaths AS int)) as DeathsCount, MAX((total_deaths/population)*100) as DeathsPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by DeathsCount desc




--CONTINENTS BREAKDOWN


--Total Cases Versus Total Deaths

select continent, date, total_cases, total_deaths,  (CAST(total_deaths AS FLOAT)/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--death Percentage

select continent, date, total_cases, total_deaths,  (CAST(total_deaths AS FLOAT)/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Total cases vs Population

select continent, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Showing Continent Infection rate

select continent, MAX(cast(total_cases as int)) as InfectionCount, MAX((total_cases/population)*100) as InfectionPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by InfectionPercentage desc


--Showing Continent Death count per population

select continent, MAX(CAST(total_Deaths AS int)) as DeathsCount, MAX((total_deaths/population)*100) as DeathsPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by DeathsCount desc




--GLOBAL NUMBERS

 SELECT
    SUM(new_cases) as total_cases,
    SUM(CAST(new_deaths AS INT)) as total_deaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100
    END as DeathPercentage
 From PortfolioProject..CovidDeaths
 where continent is not null
 order by 1,2


--new cases versus death per day

 SELECT
    date,
    SUM(new_cases) as total_cases,
    SUM(CAST(new_deaths AS INT)) as total_deaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100
    END as DeathPercentage
 From PortfolioProject..CovidDeaths
 where continent is not null
 Group by date
 order by 1,2

 

 select *
 From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
order by 2,3



--Looking at Total population vs vaccinations

select dea.continent, dea.location, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--suming the Vaccinated Pop 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location 
order by dea.location,dea.date) as TotalVaccineShot
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--suming of Fully Vaccinated Population

select dea.continent, dea.location, dea.date, dea.population, vac.people_fully_vaccinated
,SUM(convert(float,vac.people_fully_vaccinated)) over (partition by dea.location 
order by dea.location,dea.date) as TotalVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3




--Percentage of Pop fully vacinations using CTE

With VacPop (continent, location, date, population, people_fully_vaccinated, TotalVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.people_fully_vaccinated
,SUM(convert(float,vac.people_fully_vaccinated)) over (partition by dea.location 
order by dea.location,dea.date) as TotalVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (TotalVaccinated/population)*100 as VaccinatedPercentage
from VacPop




--Percentage of Pop vacinations using CTE

With PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccineShot)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location 
order by dea.location, dea.date) as TotalVaccineShot
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (TotalVaccineShot/population)*100 as VaccinationPercentage
from PopvsVac



--Percentage of Pop vacinations using TEMP TABLE
drop table if exists #Vaccinations
Create Table #Vaccinations
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVaccineShot numeric
)
Insert into #Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location 
order by dea.location, dea.date) as TotalVaccineShot
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (TotalVaccineShot/population)*100 as VaccinationPercentage
from #Vaccinations



--creating view for visualisation