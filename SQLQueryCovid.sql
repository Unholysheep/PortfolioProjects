
--���������� ������� ��� ����������� ������������.

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio..c_deaths
ORDER BY 1,2;

--��������� �� ������� ����������.

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as mortality
FROM Portfolio..c_deaths
ORDER BY 1,2;

--��� ������ �������� ���������� � ������ ������ ������������ ��������� �������. ��� ������� ��������� ������ - ���������� � �������� '%%' ����� ����� ������������.  
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as mortality
FROM Portfolio..c_deaths
WHERE location like '%Russia%'
ORDER BY 1,2;

--��������� �� ������� ��������� ����� ����� ���������.
SELECT location, date, total_cases, total_deaths, population, ROUND((total_cases/population)*100,2) as infection_ratio
FROM Portfolio..c_deaths
--WHERE location like '%Russia%'
ORDER BY 1,2;

--��������� �� ������ � ���������� ��������� ��������� � ��������� � ���������.
SELECT Location, population, MAX(total_cases) as highest_inf_count, ROUND(MAX((total_cases/population))*100,2) as infection_ratio
FROM Portfolio..c_deaths
GROUP BY location, population
ORDER BY infection_ratio DESC;

--��������� �� ������ � ���������� ����������� �� ������������. ��� ��� ������� total_deaths � ������ ����� ��������� ��� ������, ����������� ��� � ��������. ��� ��� � ������� � �������� ������������ ����������� �� ����������� � ������ ������, �������� �� ��������� �� �������.  
SELECT location, MAX(CAST(total_deaths as INT)) as highest_death_count
FROM Portfolio..c_deaths
WHERE continent is not null
GROUP BY location
ORDER BY highest_death_count DESC;

--������ �������� � ������� ����������� � ������ ������� ���������.
SELECT location, MAX(CAST(total_deaths as INT)) as highest_death_count
FROM Portfolio..c_deaths
WHERE continent is null
GROUP BY location
ORDER BY highest_death_count DESC;

--��������� �� �������� ��� ���� �����: ����� ��������� ����� ������� � ����� ��������� � ������� ����� ����, ���������� �� ����. 
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, ROUND(SUM(CAST(new_deaths as INT))/SUM(new_cases)*100,2) as deaths_globaly
FROM Portfolio..c_deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1;

--����� ����� ��������� � ������� � ����.
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, ROUND(SUM(CAST(new_deaths as INT))/SUM(new_cases)*100,2) as deaths_globaly
FROM Portfolio..c_deaths
WHERE continent is not null;


-- ��������� �� ���������� ���������. 

-- ���������� CTE. 
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_vac)
AS
(
SELECT dth.continent, dth.location, dth.date, population, new_vaccinations
, SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY dth.location ORDER BY dth.location, dth.date) AS rolling_vac
FROM Portfolio..c_deaths dth
JOIN Portfolio..c_vacs vac
   ON dth.location = vac.location
   and dth.date = vac.date
WHERE dth.continent is not null
)

SELECT *, (rolling_vac/population)*100 as vac_people_percent
FROM PopvsVac
ORDER BY 2,3;
 
 --���������� View, ����� ��������� ������ ��� ����������� ������������. 

CREATE VIEW PercentPeopleVaccinated AS
 SELECT dth.continent, dth.location, dth.date, population, new_vaccinations
, SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY dth.location ORDER BY dth.location, dth.date) AS rolling_vac
FROM Portfolio..c_deaths dth
JOIN Portfolio..c_vacs vac
   ON dth.location = vac.location
   and dth.date = vac.date
WHERE dth.continent is not null
;

CREATE VIEW Mortality AS 
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as mortality
FROM Portfolio..c_deaths
;

CREATE VIEW GlobalCount AS
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, ROUND(SUM(CAST(new_deaths as INT))/SUM(new_cases)*100,2) as deaths_globaly
FROM Portfolio..c_deaths
WHERE continent is not null;

CREATE VIEW HightstDeathCount AS
SELECT location, MAX(CAST(total_deaths as INT)) as highest_death_count
FROM Portfolio..c_deaths
WHERE continent is not null
GROUP BY location
;