-- Working on the First table

select*
from PortfolioProject..CovidDeath
order by 1,2

select location,continent, total_cases, total_deaths
from PortfolioProject..CovidDeath
where continent is not null
order by 3, 4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeath
where continent is not null
order by 1, 2

-- First Alter The data type for 'total_deaths' and 'total_cases' to decinmal to prevent errors when using division operation
-- because it sees these two fields as 'nvarchar,null'

select*
from PortfolioProject..CovidDeath
alter table CovidDeath
alter column total_cases decimal

select*
from PortfolioProject..CovidDeath
alter table CovidDeath
alter column total_deaths decimal


-- For Total cases vs Total Deaths in percentage 
-- for Percentage Death Rate

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentDeathRate 
from PortfolioProject..CovidDeath
where continent is not null
and total_cases is not null
order by 1,2



-- For Total cases vs Total Deaths in percentage 
-- for Percentage Death Rate to specific location

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentDeathRate 
from PortfolioProject..CovidDeath
where location like '%nigeria'
order by 1, 2



--looking at the total cases vs the population in Nigeria

select location, date, total_cases,population, (total_deaths/population)*100 as PercentDeathRate 
from PortfolioProject..CovidDeath
where location like '%nigeria'
order by 1, 2

--Countries with Highest Infection Rate compared to population
select location, population, Max(total_cases) as HighestIfectionCount, Max((total_cases/population))*100 as InfectionRate
from PortfolioProject..CovidDeath
where continent is not null
group by location, population
order by InfectionRate desc



--Countries with Highest Death Count to Population

select location, population, Max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is not null
group by location, population
order by TotalDeathCount desc


--Continent with Highest Death Count to Population

select continent, Max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is not null
group by continent
order by TotalDeathCount desc



-- To view the World Total Death in Percentage
select sum (total_cases)as WordTotalCases, sum(total_deaths) as WordTotalDeath, sum(total_deaths)/sum(total_cases)*100 As WorldPercentageDeathRate
from PortfolioProject..CovidDeath
where continent is not null


--Daily Global Death Rate

select date, sum(total_cases) DailyTotalCases , sum(total_deaths)as DailyTotalDeaths
, sum(total_deaths)/sum(total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeath
where continent is not null
group by date, new_cases, new_deaths
order by Death_Percentage 


-- Now Working On the Covid Vacination Table
select*
from PortfolioProject..CovidVacination
order by 1,2

-- Joining the tables together for further work
select *
from PortfolioProject..CovidDeath Cdeath
join PortFolioProject..CovidVacination Cvacc
	on Cdeath.location = Cvacc.location
	and Cdeath.date = Cvacc.date


--Total Population vs Vaccination
--first I determine the roll over vaccination to get the total vaccination for a particular location

--to determine the Roll Over vaccination
select Cdeath.continent, Cdeath.location, Cdeath.date, Cdeath.population, Cvacc.new_vaccinations
, sum(cast(Cvacc.new_vaccinations as decimal)) over (partition by Cdeath.location order by Cdeath.location, 
Cdeath.date) as RollOver_Vaccination
from PortfolioProject..CovidDeath Cdeath
join PortFolioProject..CovidVacination Cvacc
	on Cdeath.location = Cvacc.location
	and Cdeath.date = Cvacc.date
where Cdeath.continent is not null
order by 2,3


--total population vs vaccination, using RollOver_vaccination,
--but it is not possible because you can't use an alias as a collumn, to by pass this I use a CTE
--creating CTE
with PopvsVac (Continent, Location, date, Population, New_vaccinations, RollOver_Vaccination)
as
(
select Cdeath.continent, Cdeath.location, Cdeath.date, Cdeath.population, Cvacc.new_vaccinations
, sum(cast(Cvacc.new_vaccinations as decimal)) over (partition by Cdeath.location order by Cdeath.location, 
Cdeath.date) as RollOver_Vaccination
from PortfolioProject..CovidDeath Cdeath
join PortFolioProject..CovidVacination Cvacc
	on Cdeath.location = Cvacc.location
	and Cdeath.date = Cvacc.date
where Cdeath.continent is not null
)
--Percentage of People Vaccinated
select *, (RollOver_Vaccination/Population)*100 as Rate_of_vaccination
from PopvsVac




--Countries with Highest Vaccination Rate to Population

select Cdeath.location, Max(Cvacc.total_vaccinations) as TotalVaccCount
, Max(Cvacc.total_vaccinations)/Cdeath.population as Vaccination_Rate
from PortfolioProject..CovidDeath Cdeath
join PortFolioProject..CovidVacination Cvacc
	on Cdeath.location = Cvacc.location
	and Cdeath.date = Cvacc.date
where Cdeath.continent is not null
group by Cdeath.location, population
order by Vaccination_Rate desc



--Continent with Highest vaccination Count to Population

select continent, Max(total_vaccinations) as TotalVaccCount
from PortfolioProject..CovidVacination
where continent is not null
group by continent
order by TotalVaccCount


--Creating View
create view Higest_Vaccination_Rate as

select continent, Max(total_vaccinations) as TotalVaccCount
from PortfolioProject..CovidVacination
where continent is not null
group by continent
--order by TotalVaccCount






