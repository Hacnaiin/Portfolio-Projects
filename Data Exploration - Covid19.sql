/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
-- Dataset: https://ourworldindata.org/covid-deaths

--Check what our dataset has

select * from CovidDeaths

	
-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, population, total_cases, total_deaths, (total_cases/population)*100 as Death_Likelihood
from CovidDeaths
where continent is not null
order by total_cases desc

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location, total_cases Total_Cases, population Total_Population, 
(total_cases/population)*100 Infected_Population
from CovidDeaths
where continent is not null
order by location

-- Countries with Highest Infection Rate compared to Population

select location, MAX(total_cases) Highest_Infection_Rate, max((total_cases/population)*100) Infected_Population
from CovidDeaths
where continent is not null
group by location, total_cases, population
order by Infected_Population desc

-- Countries with Highest Death Count per Population

select location, (total_deaths/population)*100 Death_Rate
from CovidDeaths
where continent is not null
order by Death_Rate desc

SELECT location, CAST(total_deaths AS FLOAT) / population AS death_rate
FROM CovidDeaths
ORDER BY death_rate DESC;

-- Total deaths in each country as per population

select location, max(cast (total_deaths as float)) Total_Deaths
from CovidDeaths
where continent is not null and total_deaths is not null
group by location
order by Total_Deaths desc


-- Breakdown on the basis of 'Continent'
-- Showing contintents with the highest death count per population


select continent, max(cast(total_deaths as int)) Total_Deaths
from CovidDeaths
where continent is not null
group by continent
order by Total_Deaths desc


-- GLOBAL NUMBERS
select sum(new_cases) Total_Cases, sum(cast(new_deaths as int)) Total_Deaths,
sum(cast(new_deaths as int))/SUM(new_cases)*100 Death_Percentage
from CovidDeaths
where continent is not null
order by Total_Deaths desc


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select continent, cast(people_vaccinated as int)
from CovidDeaths
where continent is not null AND cast(people_vaccinated as int) is not null
order by continent

-- Selecting the latest entry of each continent where people are vaccinated

select continent, max (cast(people_fully_vaccinated as int)) People_Vaccinated
from CovidDeaths
where continent is not null and people_fully_vaccinated is not null
group by continent
order by 2 desc


-- Using CTE to perform Calculation on Partition By in previous query

with PopVsVac (continent, location, date, population, new_vaccinations, People_Vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) 
as People_Vaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null 
)
select * , (People_Vaccinated/population)*100 as People_Vaccinated_Percentage
from PopVsVac


-- Using Temp table instead of CTE

create table #Vaccniated_People_Percentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
People_Vaccinated numeric
)

insert into #Vaccniated_People_Percentage
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (Partition by dea.Location Order by dea.location, dea.Date) as People_Vaccinated

From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (People_Vaccinated/Population)*100 Percent_Vaccinated_People
From #Vaccniated_People_Percentage
where New_vaccinations is not null
