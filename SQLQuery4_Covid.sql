--Queires for Project

--1

--Percent of hospital covid patient being in icu by their country

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
Order By
	2,3

--2

--Looking at total of icu patients 

Select
	location, SUM(cast(icu_patients as INT)) AS total_icu_patients
From
	project_portfolio..covid_deaths
Where
	continent IS NOT null 
	AND location NOT IN ('International', 'European Union', 'World')
Group BY
	location
Order BY
	total_icu_patients DESC

--3

--Looking at locations with highest icu patient rate compared to population

Select
	location, population, MAX(cast(icu_patients as INT)) As highest_icu_count, (MAX(cast(icu_patients as INT))/population)*100 AS percent_of_pop_in_icu
From
	project_portfolio..covid_deaths
Where
	continent IS NOT null
Group By
	location,
	population
Order By
	highest_icu_count DESC

--4

--Vacs sessions
Select
	deaths.continent, deaths.date, deaths.population,
	COUNT(vacs.people_fully_vaccinated) OVER (Partition By
	deaths.continent) AS vaccination_session_count
From
	project_portfolio..covid_deaths as deaths
	Join project_portfolio..covid_vacinations as vacs
		ON deaths.location = vacs.location
		AND deaths.date = vacs.date
Where
	deaths.continent IS NOT null
Order By
	vaccination_session_count DESC

--5

--Vacs administered per population
Select
	deaths.continent, deaths.location, deaths.date, deaths.population, vacs.people_fully_vaccinated,
	SUM(cast(vacs.people_fully_vaccinated as INT))/(deaths.population) AS vaccinated_percentage
From
	project_portfolio..covid_deaths as deaths
	Join project_portfolio..covid_vacinations as vacs
		ON deaths.location = vacs.location
		AND deaths.date = vacs.date
Where
	deaths.continent IS NOT null
GROUP BY
	deaths.continent, deaths.location, deaths.date, deaths.population, vacs.people_fully_vaccinated
Order By
	vaccinated_percentage DESC

--6

--Boosters administered over time per location

Select
	deaths.continent, deaths.location, deaths.date, deaths.population, vacs.total_boosters,
	SUM(cast(vacs.total_boosters as INT)) OVER 
	(Partition by deaths.location Order by deaths.location, deaths.date) As cumulative_boosters--,
From
	project_portfolio..covid_deaths as deaths
	Join project_portfolio..covid_vacinations as vacs
		ON deaths.location = vacs.location
		AND deaths.date = vacs.date
Where
	deaths.continent IS NOT null
Order By
	2,3

--OTHER QUERIES TO LOOK INTO LATER

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
Where 
	location Like '%states%'
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

--Looking at continents with highest icu patient rate compared to population
Select
	continent, population, MAX(cast(icu_patients as INT)) As highest_icu_count, (MAX(cast(icu_patients as INT))/population)*100 AS percent_of_population_in_icu
From
	project_portfolio..covid_deaths
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
Where
	continent IS NOT null
Group By
	continent
Order By
	highest_patient_count DESC


--GLOBAL NUMBER CALCULATIONS

Select
	date, SUM(cast(hosp_patients as INT)) as sum_hosp_patients, SUM(cast(icu_patients as INT)) as sum_icu_patients, 
	SUM(cast(new_deaths as INT))as sum_new_deaths, NULLIF(SUM(cast(icu_patients as float)),0)/SUM(cast(new_deaths as float))*100 AS icu_death_percentage
From
	project_portfolio..covid_deaths
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
WHere
	continent Is NOT null
Order BY
	1,2

--TOTAL VACCINATION AGAINST TOTAL POPULATION
Select
	deaths.continent, deaths.location, deaths.date, deaths.population, vacs.total_boosters,
	SUM(cast(vacs.total_boosters as INT)) OVER 
	(Partition by deaths.location Order by deaths.location, deaths.date) As cumulative_boosters--,
From
	project_portfolio..covid_deaths as deaths
	Join project_portfolio..covid_vacinations as vacs
		ON deaths.location = vacs.location
		AND deaths.date = vacs.date
Where
	deaths.continent IS NOT null
Order By
	2,3


