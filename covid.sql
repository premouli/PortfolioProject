SELECT location,date,total_cases,new_cases,total_deaths,population
FROM `covid_Project.death_rate`
Order by 1,2

------looking at total cases vs total deaths

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM `covid_Project.death_rate`
Where location = 'United States'AND total_cases IS NOT NULL
Order by 1,2

-----looking at total cases Vs population

SELECT location,date,population,total_cases,(total_cases/population)*100 AS percentage_population_infected
FROM `covid_Project.death_rate`
Where location = 'United States'AND total_cases IS NOT NULL
Order by 1,2

---looking at the countries with highest infection rate compared to the population

SELECT location,population,MAX(total_cases) AS Highest_infection,MAX((total_cases/population))*100 AS highest_percentage_population_infected
FROM `covid_Project.death_rate`
WHERE continent is not null
GROUP BY location,population
Order by highest_percentage_population_infected desc

--showing countries with highest death count per population

SELECT location,MAX(total_deaths) AS TotalDeathCount
FROM `covid_Project.death_rate`
WHERE continent is not null
GROUP BY location
Order by TotalDeathCount desc



---Showing continents with highest death count per population
SELECT continent,MAX(total_deaths) AS TotalDeathCount
FROM `covid_Project.death_rate`
WHERE continent is NOT null
GROUP BY continent
Order by TotalDeathCount desc

---Global Percent

SELECT sum(new_cases)as total_new_cases,SUM(new_deaths) As total_new_death,SUM(new_deaths)/SUM(new_cases)*100 AS globalpercent
FROM `covid_Project.death_rate`
Where continent IS NOT NULL
Order by 1,2

---Looking at total population vs vaccination

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeoplevaccinated
FROM `covid_Project.death_rate`dea JOIN`covid_Project.vaccination_list`vac
      ON dea.location=vac.location and dea.date=vac.date
Where dea.continent IS NOT NULL
Order By 1,2,3  

----Use CTE or tem table

WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeoplevaccinated
FROM `covid_Project.death_rate`dea JOIN`covid_Project.vaccination_list`vac
      ON dea.location=vac.location and dea.date=vac.date
Where dea.continent IS NOT NULL)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM  PopvsVac 

---create a temp table
Drop Table if exists PercentPeopleVaccinated
Create Table PercentPeopleVaccinated
(
  continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
INSERT INTO PercentPeopleVaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeoplevaccinated
FROM `covid_Project.death_rate`dea JOIN`covid_Project.vaccination_list`vac
      ON dea.location=vac.location and dea.date=vac.date
Where dea.continent IS NOT NULL
SELECT *,(RollingPeopleVaccinated/population)*100
FROM  PercentPeopleVaccinated


--Creating view to store data for later visualizations

create view PercentPeopleVaccinated as 
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeoplevaccinated
FROM `covid_Project.death_rate`dea JOIN`covid_Project.vaccination_list`vac
      ON dea.location=vac.location and dea.date=vac.date
Where dea.continent IS NOT NULL
