USE covid_19_analysis;
SELECT location,date,total_cases, new_cases, total_deaths, population
FROM covid_deaths;

-- total cases vs total deaths

SELECT location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths
WHERE location = "United States";

-- Total cases vs Population
-- Shows what percentage of population got infected

SELECT location,date,total_cases, population, (total_cases/population)*100  AS death_percentage
FROM covid_deaths
WHERE location = "UNITED STATES";


-- Countries with highest infection rate compared to population
SELECT location, population,MAX(total_cases), MAX(total_cases/population)*100  AS population_infection_percent
FROM covid_deaths
WHERE continent is not NULL
GROUP BY location,population
ORDER BY population_infection_percent DESC ;

-- Showing countries with highest death count per population
SELECT location, population,MAX(total_deaths), MAX(total_deaths/population)*100  AS population_infection_percent
FROM covid_deaths
GROUP BY location,population
ORDER BY population_infection_percent DESC ;

-- Highest Death counts per country
SELECT location,MAX(total_deaths) AS death_counts
FROM covid_deaths
WHERE continent is not NULL
GROUP BY location
ORDER BY death_counts DESC ;

-- Highest Death counts per Continent
SELECT location,MAX(total_deaths) AS death_counts
FROM covid_deaths
WHERE continent is NULL
GROUP BY location
ORDER BY death_counts DESC ;

SELECT continent,MAX(total_deaths) AS death_counts
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY death_counts DESC ;

-- Global Numbers
SELECT SUM(new_cases) AS total_cases,SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY date ASC;

-- Total population vs vaccinations

SELECT t1.continent,t1.location,t1.date,t1.population,t2.new_vaccinations,
SUM(CAST(t2.new_vaccinations AS SIGNED INT)) OVER(PARTITION BY t1.location ORDER BY t1.location,t1.date) AS RollingPeopleVaccinated
FROM covid_deaths t1
JOIN covid_vaccination t2
ON t1.location = t2.location
WHERE t1.continent IS NOT NULL
AND t1.date = t2.date;

WITH popVSvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS(
SELECT t1.continent,t1.location,t1.date,t1.population,t2.new_vaccinations,
SUM(CAST(t2.new_vaccinations AS SIGNED INT)) OVER(PARTITION BY t1.location ORDER BY t1.location,t1.date) AS RollingPeopleVaccinated
FROM covid_deaths t1
JOIN covid_vaccination t2
ON t1.location = t2.location
WHERE t1.continent IS NOT NULL
AND t1.date = t2.date)
SELECT *,(RollingPeopleVaccinated/population)*100 FROM popVSvac;

DROP TABLE IF EXISTS rollingpercentvaccination;

CREATE TABLE rollingpercentvaccination(
continent VARCHAR(255),
location VARCHAR(255),
date DATETIME,
population BIGINT,
new_vaccinations INTEGER,
RollingPeopleVaccinated DECIMAL
);

INSERT INTO rollingpercentvaccination
SELECT t1.continent,t1.location,t1.date,t1.population,t2.new_vaccinations,
SUM(CAST(t2.new_vaccinations AS SIGNED INT)) OVER(PARTITION BY t1.location ORDER BY t1.location,t1.date) AS RollingPeopleVaccinated
FROM covid_deaths t1
JOIN covid_vaccination t2
ON t1.location = t2.location
WHERE t1.continent IS NOT NULL
AND t1.date = t2.date;

SELECT *,(RollingPeopleVaccinated/population)*100 FROM rollingpercentvaccination;

-- Creating views for visualization

-- 1.
CREATE VIEW TABLE1 AS
SELECT SUM(new_cases) AS total_cases,SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL;

-- 2.
CREATE VIEW TABLE2 AS
Select location, SUM(new_deaths) as TotalDeathCount
From covid_deaths
-- Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;

-- 3.
CREATE VIEW TABLE3 AS
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deaths
Group by Location, Population
order by PercentPopulationInfected desc;

-- 4.
CREATE VIEW TABLE4 AS
Select Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deaths
Group by Location, Population,date
order by PercentPopulationInfected desc;


-- 5.
CREATE VIEW POPvsVAC AS
SELECT t1.continent,t1.location,t1.date,t1.population,t2.new_vaccinations,
SUM(CAST(t2.new_vaccinations AS SIGNED INT)) OVER(PARTITION BY t1.location ORDER BY t1.location,t1.date) AS RollingPeopleVaccinated
FROM covid_deaths t1
JOIN covid_vaccination t2
ON t1.location = t2.location
WHERE t1.continent IS NOT NULL
AND t1.date = t2.date;
