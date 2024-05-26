--SELECT *
--from SQL_Portfolioi..CovidDeaths$
--order by 3,4


--SELECT *
--from SQL_Portfolioi..CovidVaccinations$
--order by 3,4

-- Death Percent in INDIA

--SELECT location,date, total_cases,total_deaths , (total_deaths/total_cases)*100 as Death_Case_Percentage
--from SQL_Portfolioi..CovidDeaths$
--where location like 'india'
--order by 1,2


-- Population covid case percentage

--SELECT location,date, total_cases,total_deaths , (total_deaths/total_cases)*100 as Death_Case_Percentage, population, (total_cases/population)*100 as Population_Case_Percentage
--from SQL_Portfolioi..CovidDeaths$
----where location like 'india'

--order by 1,2

---- countries with highest population-covid percentage

--SELECT location,population, Max(total_cases) as Max_Case , (Max(total_cases)/population)*100 as Population_Case_Percentage
--from SQL_Portfolioi..CovidDeaths$
----where location like 'india'
--group by location,population
--order by Population_Case_Percentage desc;

-- Sorted according to hihest population location and highest population-covid percentage

--SELECT location,population, Max(total_cases) as Max_Case , (Max(total_cases)/population)*100 as Population_Case_Percentage
--from SQL_Portfolioi..CovidDeaths$
----where location like 'india'
--group by location,population
--ORDER BY  population DESC, Population_Case_Percentage DESC


-- countries with highest population-death percentage

SELECT location,population, Max(total_deaths) as Max_Deaths , (Max(total_deaths)/population)*100 as Population_Death_Percentage
from SQL_Portfolioi..CovidDeaths$
--where location like 'india'
group by location,population
order by Population_Death_Percentage desc;


-- Sorted according to hihest population location and highest population-death percentage

SELECT location,population,Max(total_cases) as Max_cases, Max(total_deaths) as Max_Deaths , (Max(total_deaths)/population)*100 as Population_Death_Percentage, (Max(total_deaths)/Max(total_cases))*100 as Death_Case_Percentage
from SQL_Portfolioi..CovidDeaths$
--where location like '%korea'
group by location,population
order by Max_cases desc,Death_Case_Percentage desc;
--order by Population_Death_Percentage asc, Death_Case_Percentage desc ;


-- Global Numbers / Only Countries data not continents/world

SELECT location,population,new_cases
from SQL_Portfolioi..CovidDeaths$
--where location like '%korea'
where continent is not null
order by location;


-- Population vs Vaccinations

SELECT death.continent,death.location,death.population,death.date, vaccine.new_vaccinations
from SQL_Portfolioi..CovidDeaths$ death
Join SQL_Portfolioi..CovidVaccinations$ vaccine
on death.location = vaccine.location and death.date = vaccine.date
--where location like '%korea'
where death.continent is not null
order by 2,3;


-- total Vaccinations location wise
--with popvsvac (continent, location, population, date,newVaccination,locationTotal_vaccination)

--as
--(
--SELECT death.continent,death.location,death.population,death.date, vaccine.new_vaccinations, sum(cast(vaccine.new_vaccinations as int)) over (Partition by death.location order by death.location, death.date) as location_total_vaccination
--from SQL_Portfolioi..CovidDeaths$ death
--Join SQL_Portfolioi..CovidVaccinations$ vaccine
--on death.location = vaccine.location and death.date = vaccine.date
----where location like '%korea'
--where death.continent is not null
----order by 2,3;
--)
--select continent, location, population, date,newVaccination,locationTotal_vaccination, (max(locationTotal_vaccination)/population*100) over (partition by location) as pop_vs_vac_percent 
--from popvsvac
----group by location 

with popvsvac (continent, location, population, date,newVaccination,locationTotal_vaccination)

as
(
SELECT death.continent,death.location,death.population,death.date, vaccine.new_vaccinations, sum(cast(vaccine.new_vaccinations as int)) over (Partition by death.location order by death.location, death.date) as location_total_vaccination
from SQL_Portfolioi..CovidDeaths$ death
Join SQL_Portfolioi..CovidVaccinations$ vaccine
on death.location = vaccine.location and death.date = vaccine.date
--where location like '%korea'
where death.continent is not null
--order by 2,3;
)
select*, (locationTotal_vaccination)/population*100 as population_tota_vac_percentage
from popvsvac
--group by location 


-- Temp Table
 
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255), Population numeric, Date datetime,NewVaccination numeric, locationTotal numeric
)


-- add data
Insert Into #PercentPopulationVaccinated 


SELECT death.continent,death.location,death.population,death.date, vaccine.new_vaccinations, sum(cast(vaccine.new_vaccinations as int)) over (Partition by death.location order by death.location, death.date) as location_total_vaccination
from SQL_Portfolioi..CovidDeaths$ death
Join SQL_Portfolioi..CovidVaccinations$ vaccine
on death.location = vaccine.location and death.date = vaccine.date
--where location like '%korea'
where death.continent is not null
--order by 2,3;

select*, (locationTotal)/population*100 as population_tota_vac_percentage
from #PercentPopulationVaccinated



select location,date, NewVaccination, locationTotal,population,max(locationTotal) over  (Partition by location), (max(locationTotal) over  (Partition by location))/population*100 
from #PercentPopulationVaccinated



-- Create view to store data for visualizations

create view PercentPopulationVaccinated as
-- either use the below line after removing # as hash is for temporary table, we need to create permanent for view
-- Select * from #PercentPopulationVaccinated
-- or use cte like below directly

SELECT death.continent,death.location,death.population,death.date, vaccine.new_vaccinations, sum(cast(vaccine.new_vaccinations as int)) over (Partition by death.location order by death.location, death.date) as location_total_vaccination
from SQL_Portfolioi..CovidDeaths$ death
Join SQL_Portfolioi..CovidVaccinations$ vaccine
on death.location = vaccine.location and death.date = vaccine.date
--where location like '%korea'
where death.continent is not null