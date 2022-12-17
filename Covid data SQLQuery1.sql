SELECT *
FROM PortfolioProject..coviddeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..covidvaccinations
ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..coviddeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..coviddeaths
WHERE location like 'India'
ORDER BY 1,2

-- Looking at Total cases vs Population
--Shows what % population got covid
SELECT location,date,total_cases,population, (total_cases/population)*100 as CovidPercentage
FROM PortfolioProject..coviddeaths
WHERE location like 'India'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location,MAX(total_cases) as HighestInfectionCount,population,MAX((total_cases/population))*100 as CovidPercentage
FROM PortfolioProject..coviddeaths
--WHERE location like 'India'
GROUP BY population,location
ORDER BY CovidPercentage DESC
--showing countries with highest death count per population
SELECT location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..coviddeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--showing continents with highest death count per population

SELECT continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..coviddeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global numbers

SELECT SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..coviddeaths
--WHERE location like 'India'
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2

--looking at total population vs vaccination

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

-- USE CTE

WITH PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 as VaccPerc
FROM PopvsVac

--Temp Table
DROP TABLE if exists VaccPerc
CREATE TABLE VaccPerc
(continent nvarchar(255),location nvarchar(255),date datetime,population numeric,new_vaccinations numeric,RollingPeopleVaccinated numeric)
INSERT into
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
SELECT *
FROM VaccPerc

--CREATE VIEW to store data for later visualizations

CREATE VIEW VaccPerc as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *
FROM VaccPerc







