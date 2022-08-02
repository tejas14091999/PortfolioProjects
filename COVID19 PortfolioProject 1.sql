/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


--select * from portfolioProject1.CovidDeaths order by 3,4
--select * from portfolioProject1.CovidVaccinations order by 3,4

--Select the data to be used
select location, date, total_cases, new_cases, total_deaths, population
from portfolioProject1.CovidDeaths
where continent not like 'null'
order by 1,2



-- Total Cases per  vs Total Deaths
--Percentage of people who died among the once who were diagnosed = likelihood of dying off covid
select location, date, total_cases, total_deaths, (nullif(total_deaths,0)/nullif(total_cases,0)) * 100 as DeathPercentage 
from portfolioProject1.CovidDeaths
where location like 'India' and  continent not like 'null'
order by 1,2



--Total cases vs Total population
--Shows what percentage of population who got COVID
select location, date, total_cases, population , (nullif(total_cases,0)/nullif(population,0)) * 100 as COVID_AffectedPercentage 
from portfolioProject1.CovidDeaths
where location like 'India' and  continent not like 'null'
order by 1,2



--Looking at Countries with the Highest Infection Rates compared to the Population 
select location, population, MAX(total_cases) as Highest_Infection_Count , MAX((nullif(total_cases,0)/nullif(population,0)))* 100 as Percentage_Population_Infected
from portfolioProject1.CovidDeaths
--where location like 'India'
where continent not like 'null'
group by location, population
order by Percentage_Population_Infected DESC



--Countries with Highest Death Count per Population
select location, MAX(total_deaths) as Total_Death_Count
from portfolioProject1.CovidDeaths
--where location like 'India'
where continent not like 'null'
group by location
order by Total_Death_Count DESC



--Continent with Highest Death Count pe Population
select location, MAX(total_deaths) as Total_Death_Count
from portfolioProject1.CovidDeaths
where continent like 'null'
group by location
order by Total_Death_Count DESC



--GLOBAL Death Percentage
select 
--date, 
sum(cast(new_cases as int)) as total_cases,--sum of all new cases over all dates gives the TOTAL CASES
sum(cast(new_deaths as int)) as total_deaths, --sum of all new deaths over all dates gives the TOTAL DEATHS
nullif(sum(cast(new_deaths as float)),0) / nullif(sum(cast(new_cases as float)),0) as Global_Death_Percentage
from portfolioProject1.CovidDeaths
where continent not like 'null'
--group by date
order by 2


--Total Population vs Vaccinations
--Total people in the world who are vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject1.CovidDeaths AS dea
JOIN PortfolioProject1.CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent not like 'NULL' 
order by 1,2,3



--TEMP TABLE  and CTE 
--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--SUM(Cast( vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date  ) as Rolling_People_Vaccinated
----,(Rolling_People_Vaccinated/population)*100 --Cannot be done coz just column is formed above, thus use cte or temp table
--from PortfolioProject1.CovidDeaths AS dea
--JOIN PortfolioProject1.CovidVaccinations AS vac
--	ON dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent not like 'NULL'
--order by 2,3



--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent varchar(max),--add nvarchar(50) this in main area, pt not note is that jo table main data type hai vohi data type hona chahiye
Location varchar(max),
Date varchar(max),
Population varchar(max),
New_Vaccines varchar(max),
Rolling_People_Vaccinated varchar(max)
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast( vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date  ) as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100 --Cannot be done coz just column is formed above, thus use cte or temp table
from PortfolioProject1.CovidDeaths AS dea
JOIN PortfolioProject1.CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent not like 'NULL'
order by 2,3
select * , (nullif(cast(Rolling_People_Vaccinated as float),0)/nullif(cast(Population as float),0) )* 100 
from #PercentPopulationVaccinated




--CTE(Common table expression = temporary named result set that you can reference within a select, insert, update or delete statement, also can be used to create a view)

with PopvsVac (Continent, location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated )
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast( vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date  ) as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100 --Cannot be done coz just column is formed above, thus use cte or temp table
--Rolling - col se cumulative sum nikal rha hai, into the new columsn - give example 
from PortfolioProject1.CovidDeaths AS dea
JOIN PortfolioProject1.CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent not like 'NULL'
--order by 2,3 --ERROR - The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified.
)
select * , (nullif(Rolling_People_Vaccinated,0)/nullif(Population,0) )* 100 
from PopvsVac




--VIEW for storing data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast( vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date  ) as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100 --Cannot be done coz just column is formed above, thus use cte or temp table
from PortfolioProject1.CovidDeaths AS dea
JOIN PortfolioProject1.CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent not like 'NULL'

 
--select * from PercentPopulationVaccinated

--drop view if exists PercentPopulationVaccinated


