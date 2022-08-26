
--Сформируем выборку для дальнейшего исследования.

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio..c_deaths
ORDER BY 1,2;

--Посмотрим на процент смертности.

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as mortality
FROM Portfolio..c_deaths
ORDER BY 1,2;

--Для оценки процента смертности в каждой стране используется следующая выборка. Для примера приведена Россия - подставить в значение '%%' можно любую интересующую.  
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as mortality
FROM Portfolio..c_deaths
WHERE location like '%Russia%'
ORDER BY 1,2;

--Посмотрим на процент заражённых среди всего населения.
SELECT location, date, total_cases, total_deaths, population, ROUND((total_cases/population)*100,2) as infection_ratio
FROM Portfolio..c_deaths
--WHERE location like '%Russia%'
ORDER BY 1,2;

--Посмотрим на страны с наибольшим процентом заражённых в отношении к населению.
SELECT Location, population, MAX(total_cases) as highest_inf_count, ROUND(MAX((total_cases/population))*100,2) as infection_ratio
FROM Portfolio..c_deaths
GROUP BY location, population
ORDER BY infection_ratio DESC;

--Посмотрим на страны с наибольшей смертностью от коронавируса. Так как столбец total_deaths в данных имеет строковый тип данных, преобразуем его в числовой. Так как в столбце с локацией присутствует группировка по континентам и уровню дохода, исключим их появление из выборки.  
SELECT location, MAX(CAST(total_deaths as INT)) as highest_death_count
FROM Portfolio..c_deaths
WHERE continent is not null
GROUP BY location
ORDER BY highest_death_count DESC;

--Оценим ситуацию в разрезе континентов и уровня доходов населения.
SELECT location, MAX(CAST(total_deaths as INT)) as highest_death_count
FROM Portfolio..c_deaths
WHERE continent is null
GROUP BY location
ORDER BY highest_death_count DESC;

--Посмотрим на ситуацию под иным углом: общее отношение новых смертей к новым заражённым в разрезе всего мира, разделённое по дням. 
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, ROUND(SUM(CAST(new_deaths as INT))/SUM(new_cases)*100,2) as deaths_globaly
FROM Portfolio..c_deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1;

--Общее число заражённых и умерших в мире.
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, ROUND(SUM(CAST(new_deaths as INT))/SUM(new_cases)*100,2) as deaths_globaly
FROM Portfolio..c_deaths
WHERE continent is not null;


-- Посмотрим на вакцинацию населения. 

-- Используем CTE. 
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
 
 --Используем View, чтобы сохранить данные для последующей визуализации. 

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
