select * from CovidDeaths
where continent is null
order by location 




--Showing Continents with Highest Infection Rate Compared to Population
select continent, population, max(total_cases) MaxInfection, (max(total_cases/population)*100) as InfectionPercentage from dbo.CovidDeaths
group by continent, population
order by 4 desc

--Showing Countires with Highest Infection Rate Compared to Population
select location, population, max(total_cases) MaxInfection, (max(total_cases/population)*100) as InfectedPercentage from dbo.CovidDeaths
group by location, population
order by 4 desc




--Showing Continents with Highest Death Count
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
group by continent
order by TotalDeathCount desc

--Showing Countires with Highest Death Count
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
group by location
order by TotalDeathCount desc




--Showing Countries with Highest Death Count within Asia
select location, max(cast(total_deaths as int)) as TotalDeathCountWithinAsia
from CovidDeaths
where continent = 'Asia'
group by location
order by TotalDeathCountWithinAsia desc

--Showing Countries with Highest Death Count within Europe
select location, max(cast(total_deaths as int)) as TotalDeathCountWithinEurope
from CovidDeaths
where continent = 'Europe'
group by location
order by TotalDeathCountWithinEurope desc




--Comparing Covid Death Counts with Total Cases in the World
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases)) as total_death_percentage
from CovidDeaths
where continent is not null




--Comparing Vaccination Count with Population in the World
select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where vac.continent is not null 
and vac.new_vaccinations is not null
order by 1,2,3




--Comparing Vaccination Count with Population in Iran
select vac.continent, vac.location, vac.date, vac.population, vac.new_vaccinations, sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where vac.location = 'Iran'
and vac.new_vaccinations is not null
order by 1,2,3



--Looking at Total Population vs Total Vaccination in the World
select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccination 
from CovidDeaths dea
join CovidVaccinations vac
	on vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
order by 2,3

--Looking at Total Population vs Total Vaccination in Iran
select vac.continent, vac.location, vac.population, sum(cast(vac.new_vaccinations as int)) as TotalVaccination
from CovidDeaths dea
join CovidVaccinations vac
on vac.location = dea.location
and vac.date = dea.date
where vac.location = 'Iran'
--and vac.new_vaccinations is not null
group by vac.continent, vac.location, vac.population




--CTE
with PopvsVac (continent, location, date, population, new_vaccination, TotalVaccination)
as 
(
select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccination 
from CovidDeaths dea
join CovidVaccinations vac
	on vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
)
select *, (TotalVaccination/population)*100 as TotalVaccinationPercentag
from PopvsVac





--Temp Table
drop table if exists #TotalVaccinationPercentag
create table #TotalVaccinationPercentag
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVaccination numeric
)
insert into #TotalVaccinationPercentag
select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccination 
from CovidDeaths dea
join CovidVaccinations vac
	on vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null

select  *, (TotalVaccination/population)*100 as TotalVaccinationPercentag
from #TotalVaccinationPercentag