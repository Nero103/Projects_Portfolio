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


--Viewing continents with the highest hospital patient count
Select
	continent, MAX(cast(hosp_patients as int)) As highest_hosp_patient_count
From
	project_portfolio..covid_deaths
Where
	continent IS NOT null
Group By
	continent
Order By
	highest_hosp_patient_count DESC

--LOOKING AT HOSPTIAL PATIENTS AGAINST ICU PATIENT


--Chance of hospital covid patient going into icu by their country
USE project_portfolio
GO
Create View patient_population_icu_percent AS

Select
	continent, date, population, icu_patients, hosp_patients,
	CASE
		WHEN icu_patients >= 0 OR hosp_patients >= 0 THEN NULLIF(cast(icu_patients as FLOAT),0)/NULLIF(cast(hosp_patients as FLOAT),0)*100 
		ELSE (cast(icu_patients as FLOAT)/cast(hosp_patients as FLOAT))*100 
	END AS icu_ratio
From
	project_portfolio..covid_deaths
Where 
	continent IS NOT null
--Order By
--	hosp_patients DESC

--LOOKING AT TOTAL PATIENTS AGIANST POPULATION


--Shows percentage of population that was admitted to hosptials
USE project_portfolio
GO
Create View patient_population_percent_North_America AS

Select
	continent, date, population, hosp_patients, icu_patients, cast(hosp_patients as INT) + cast(icu_patients as INT) AS total_patients,
	(cast(hosp_patients as INT) + cast(icu_patients as INT))/population*100 AS patient_percent_to_pop
From
	project_portfolio..covid_deaths
Where 
	continent Like '%North%'
--Order By
--	patient_percent_to_pop DESC

--Looking at continents with highest icu patient rate compared to population
Select
	continent, population, MAX(cast(icu_patients as INT)) As highest_icu_count, (MAX(cast(icu_patients as INT))/population)*100 AS percent_of_population_in_icu
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
	percent_of_population_in_icu DESC

--Viewing at contitnent with highest patient count per population
Select
	continent, MAX(cast(hosp_patients as int) + cast(icu_patients as INT)) As highest_patient_count
From
	project_portfolio..covid_deaths
--Where 
	--location Like '%states%'
Where
	continent IS NOT null
Group By
	continent
Order By
	highest_patient_count DESC


--GLOBAL NUMBER CALCULATIONS

Select
	date, SUM(cast(hosp_patients as INT)) as sum_hosp_patients, SUM(cast(icu_patients as INT)) as sum_icu_patients, 
	SUM(cast(new_deaths as INT))as sum_new_deaths, NULLIF(SUM(cast(icu_patients as Float)),0)/SUM(cast(new_deaths as float))*100 AS icu_death_percentage
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

--Total global hospital covid deaths 
Select
	SUM(cast(hosp_patients as INT)) as sum_hosp_patients, SUM(cast(new_deaths as INT)) as sum_new_deaths, SUM(cast(new_deaths as FLOAT))/NULLIF(SUM(cast(hosp_patients as FLOAT)),0)*100 AS hosp_death_percentage
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


--TOTAL BOOSTERS ADMINISTERED AGAINST TOTAL POPULATION
Select
	deaths.continent, deaths.location, deaths.date, deaths.population, vacs.total_boosters,
	SUM(cast(vacs.total_boosters as INT)) OVER 
	(Partition by deaths.location Order by deaths.location, deaths.date) As cumulative_boosters--,
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

With pop_to_boosters (continent, location, date, population, total_boosters, cumulative_boosters) 
AS
(
Select
	deaths.continent, deaths.location, deaths.date, deaths.population, vacs.total_boosters,
	SUM(cast(vacs.total_boosters as INT)) OVER 
	(Partition by deaths.location Order by deaths.location, deaths.date) As cumulative_boosters--,
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
	(cumulative_boosters/population)*100 AS received_boosters_percent
From
	pop_to_boosters

--Temp Table

DROP TABLE IF EXISTS #population_received_booster_percent
CREATE TABLE #population_received_booster_percent
(
continent nvarchar(255),
location nvarchar(255),
date DATETIME,
population numeric,
newly_boosted numeric,
cumulative_booster numeric
)

Insert into #population_received_booster_percent
Select
	deaths.continent, deaths.location, deaths.date, deaths.population, vacs.total_boosters,
	SUM(cast(vacs.total_boosters as INT)) OVER 
	(Partition by deaths.location Order by deaths.location, deaths.date) As cumulative_boosters--,
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
	(cumulative_booster/population)*100 AS booster_rate
From
	#population_received_booster_percent

--Creating View to store data for later use

Use project_portfolio
GO
Create View population_received_booster_percents AS 
Select
	deaths.continent, deaths.location, deaths.date, deaths.population, vacs.total_boosters,
	SUM(cast(vacs.total_boosters as INT)) OVER 
	(Partition by deaths.location Order by deaths.location, deaths.date) As cumulative_boosters--,
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



