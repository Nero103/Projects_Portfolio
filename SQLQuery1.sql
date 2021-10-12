Select
	*
From
	project_portfolio..covid_deaths
Where
	continent IS NOT null
Order By
	3,4

--Select
--	*
--From
--	project_portfolio..covid_vacinations
--Order By
--	3,4

-- Data that I will be using

Select
	location, date, population, total_cases, new_cases, total_deaths
From
	project_portfolio..covid_deaths
Order By
	1,2

--LOOKING AT TOTAL CASES AGAINST TOTAL DEATHS


--Chance of someone dying from covid in their country
Select
	location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
From
	project_portfolio..covid_deaths
Where 
	location Like '%states%'
Order By
	1,2

--LOOKING AT TOTAL CASES AGIANST POPULATION


--Shows percentage of population that was infected by covid
Select
	location, date, population, total_cases, (total_cases/population)*100 AS infected_percentage
From
	project_portfolio..covid_deaths
Where 
	location Like '%states%'
Order By
	1,2

--Looking at countries with highest infection rate compared to population
Select
	location, population, MAX(total_cases) As highest_infection_count, (MAX(total_cases)/population)*100 AS percent_of_population_infected
From
	project_portfolio..covid_deaths
--Where 
	--location Like '%states%'
Group By
	location,
	population
Order By
	percent_of_population_infected DESC

--Looking at countries with highest death count per population
Select
	location, MAX(cast(total_deaths as int)) As highest_death_count
From
	project_portfolio..covid_deaths
--Where 
	--location Like '%states%'
Where
	continent IS NOT null
Group By
	location
Order By
	highest_death_count DESC

--NARROWING THINGS DOWN BY CONTINENT


--Showing continents with highest death count
Select
	continent, MAX(cast(total_deaths as int)) As highest_death_count
From
	project_portfolio..covid_deaths
--Where 
	--location Like '%states%'
Where
	continent IS NOT null
Group By
	continent
Order By
	highest_death_count DESC

--LOOKING AT TOTAL CASES AGAINST TOTAL DEATHS


--Chance of someone dying from covid in their country
Select
	continent, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
From
	project_portfolio..covid_deaths
Where 
	continent Like '%north%'
Order By
	death_percentage DESC

--LOOKING AT TOTAL CASES AGIANST POPULATION


--Shows percentage of population that was infected by covid
Select
	continent, date, population, total_cases, (total_cases/population)*100 AS infected_percentage
From
	project_portfolio..covid_deaths
Where 
	continent Like '%North%'
Order By
	infected_percentage DESC

--Looking at continents with highest infection rate compared to population
Select
	continent, population, MAX(total_cases) As highest_infection_count, (MAX(total_cases)/population)*100 AS percent_of_population_infected
From
	project_portfolio..covid_deaths
--Where 
	--location Like '%states%'
Where
	continent IS NOT null
Group By
	continent,
	population
Order By
	percent_of_population_infected DESC

--Looking at contitnent with highest death count per population
Select
	continent, MAX(cast(total_deaths as int)) As highest_death_count
From
	project_portfolio..covid_deaths
--Where 
	--location Like '%states%'
Where
	continent IS NOT null
Group By
	continent
Order By
	highest_death_count DESC


--GLOBAL NUMBER CALCULATIONS

Select
	date, SUM(new_cases) as sum_new_cases, SUM(cast(new_deaths as INT)) as sum_new_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 AS death_percentage
From
	project_portfolio..covid_deaths
--Where 
	--continent Like '%north%'
WHere
	continent Is NOT null
Group By
	date
Order BY
	1,2

--Total global covid deaths
Select
	SUM(new_cases) as sum_new_cases, SUM(cast(new_deaths as INT)) as sum_new_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 AS death_percentage
From
	project_portfolio..covid_deaths
--Where 
	--continent Like '%north%'
WHere
	continent Is NOT null
--Group By
--	date
Order BY
	1,2


	--TOTAL VACCINATION AGAINST TOTAL POPULATION
Select
	deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations,
	SUM(cast(vacs.new_vaccinations as INT)) OVER 
	(Partition by deaths.location Order by deaths.location, deaths.date) As cumulative_vaccination_count--,
	--(cumulative_vaccination_count/population)*100
From
	project_portfolio..covid_deaths as deaths
	Join project_portfolio..covid_vacinations as vacs
		ON deaths.location = vacs.location
		AND deaths.date = vacs.date
Where
	deaths.continent IS NOT null
Order By
	2,3

--USE CTE

With pop_to_vac (continent, location, date, population, new_vaccination, cumulative_vaccination_count) 
AS
(
Select
	deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations,
	SUM(cast(vacs.new_vaccinations as INT)) OVER 
	(Partition by deaths.location Order by deaths.location, deaths.date) As cumulative_vaccination_count--,
	--Can't be done on its own(cumulative_vaccination_count/population)*100
From
	project_portfolio..covid_deaths as deaths
	Join project_portfolio..covid_vacinations as vacs
		ON deaths.location = vacs.location
		AND deaths.date = vacs.date
Where
	deaths.continent IS NOT null
--Can't use in a CTE Order By
--	2,3
)

Select
	*,
	(cumulative_vaccination_count/population)*100
From
	pop_to_vac

--Temp Table

DROP TABLE IF EXISTS #population_vaccinated_percent
CREATE TABLE #population_vaccinated_percent
(
continent nvarchar(255),
location nvarchar(255),
date DATETIME,
population numeric,
newly_vaccinated numeric,
cumulative_vaccination_count numeric
)

Insert into #population_vaccinated_percent
Select
	deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations,
	SUM(cast(vacs.new_vaccinations as INT)) OVER 
	(Partition by deaths.location Order by deaths.location, deaths.date) As cumulative_vaccination_count--,
	--Can't be done on its own(cumulative_vaccination_count/population)*100
From
	project_portfolio..covid_deaths as deaths
	Join project_portfolio..covid_vacinations as vacs
		ON deaths.location = vacs.location
		AND deaths.date = vacs.date
Where
deaths.continent IS NOT null
AND deaths.date > '2021-06-01'
--Can't use in a CTE Order By
--	2,3

Select
	*,
	(cumulative_vaccination_count/population)*100
From
	#population_vaccinated_percent

--Creating View to store data for later use

Create View population_vaccinated_number AS 
Select
	deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations,
	SUM(cast(vacs.new_vaccinations as INT)) OVER 
	(Partition by deaths.location Order by deaths.location, deaths.date) As cumulative_vaccination_count--,
	--Can't be done on its own(cumulative_vaccination_count/population)*100
From
	project_portfolio..covid_deaths as deaths
	Join project_portfolio..covid_vacinations as vacs
		ON deaths.location = vacs.location
		AND deaths.date = vacs.date
Where
deaths.continent IS NOT null
--AND deaths.date > '2021-06-01'
--Can't use in a CTE Order By
--	2,3
