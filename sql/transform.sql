----------------Загружаем сырые данные----------------
---Удаляем старые аналитические таблицы перед запуском---
DROP TABLE IF EXISTS race_winners CASCADE;
DROP TABLE IF EXISTS constructor_report CASCADE;
DROP TABLE IF EXISTS pilot_stability CASCADE;
DROP TABLE IF EXISTS laps_efficiency CASCADE;
DROP TABLE IF EXISTS pole_position_stats CASCADE;
DROP TABLE IF EXISTS pilots_top CASCADE;
DROP TABLE IF EXISTS race_points CASCADE;
DROP TABLE IF EXISTS laps_raced_stats_pilots CASCADE;
DROP TABLE IF EXISTS laps_lead_stats_pilots CASCADE;
DROP TABLE IF EXISTS races_result CASCADE;
DROP TABLE IF EXISTS grid_position CASCADE;
DROP TABLE IF EXISTS pilots CASCADE;


---Создаем таблицу с данными о пилотах---
CREATE TABLE IF NOT EXISTS staging_pilots (
	pilot_id SERIAL PRIMARY KEY,
	pilot_name VARCHAR(50),
	chassis VARCHAR(30),
	engine VARCHAR(30),
	best_result VARCHAR(10),
	best_grid_position VARCHAR(10)
);


SELECT * FROM staging_pilots;

---Создаем таблицу с данными о результатах гонок---
CREATE TABLE IF NOT EXISTS staging_races_result (
	report_id SERIAL PRIMARY KEY,
	pilot_name VARCHAR(50),
	brazil VARCHAR(10),
	south_africa VARCHAR(10),
	belgium VARCHAR(10),
	san_marino VARCHAR(10),
	france VARCHAR(10),
	monaco VARCHAR(10),
	canada VARCHAR(10),
	detroit VARCHAR(10),
	dallas VARCHAR(10),
	britain VARCHAR(10),
	deutschland VARCHAR(10),
	austria VARCHAR(10),
	netherlands VARCHAR(10),
	italy VARCHAR(10),
	euro VARCHAR(10),
	portugal VARCHAR(10)
);


SELECT * FROM staging_races_result;

---Создаем таблицу с данными о стартовой позиции пилота---
CREATE TABLE IF NOT EXISTS staging_grid_position (
	report_id SERIAL PRIMARY KEY,
	pilot_name VARCHAR(50),
	brazil VARCHAR(10),
	south_africa VARCHAR(10),
	belgium VARCHAR(10),
	san_marino VARCHAR(10),
	france VARCHAR(10),
	monaco VARCHAR(10),
	canada VARCHAR(10),
	detroit VARCHAR(10),
	dallas VARCHAR(10),
	britain VARCHAR(10),
	deutschland VARCHAR(10),
	austria VARCHAR(10),
	netherlands VARCHAR(10),
	italy VARCHAR(10),
	euro VARCHAR(10),
	portugal VARCHAR(10)
);


SELECT * FROM staging_grid_position;

---Создаем таблицу с данными о количестве кругов лидирования пилотов---
CREATE TABLE IF NOT EXISTS staging_laps_lead_pilots (
	lead_id SERIAL PRIMARY KEY,
	pilot_name VARCHAR(50),
	laps_lead VARCHAR(10)
);


SELECT * FROM staging_laps_lead_pilots;


---Создаем таблицу с данными о количестве пройденных кругов пилотов---
CREATE TABLE IF NOT EXISTS staging_laps_raced_pilots (
	raced_id SERIAL PRIMARY KEY,
	pilot_name VARCHAR(50),
	laps_raced VARCHAR(10),
	percentage VARCHAR(10)
);


SELECT * FROM staging_laps_raced_pilots;



----------------Преобразуем сырые данные----------------

/* Создаем таблицу для преобразованных данных о пилотах, 
   очищаем данные от пропусков 'NaN' в подзапросе и заполняем таблицу чистыми данными */
CREATE TABLE pilots AS
SELECT
	pilot_id,
	(SELECT p.pilot_name
	FROM staging_pilots p
	WHERE p.pilot_id <= s.pilot_id
	AND p.pilot_name != 'NaN'
	ORDER BY p.pilot_id DESC
	LIMIT 1) AS pilot_name,
	s.chassis,
	s.engine,
	s.best_result,
	s.best_grid_position
FROM staging_pilots s
ORDER BY s.pilot_id;


SELECT * FROM pilots;


---Создаем таблицу для преобразованных данных о стартовой позиции пилотов---
CREATE TABLE IF NOT EXISTS grid_position (
	position_id SERIAL PRIMARY KEY,
	pilot_name VARCHAR(50),
	race_name VARCHAR(20),
	starting_position SMALLINT
);

---Очищаем данные от пропусков 'NaN', 'NULL' и заполняем таблицу чистыми данными---
INSERT INTO grid_position (pilot_name, race_name, starting_position)
SELECT pilot_name, 'BRAZIL', CAST(brazil AS SMALLINT)
FROM staging_grid_position
WHERE brazil IS NOT NULL AND brazil != '' AND brazil != 'NaN'
UNION ALL
SELECT pilot_name, 'SOUTH_AFRICA', CAST(south_africa AS SMALLINT)
FROM staging_grid_position
WHERE south_africa IS NOT NULL AND south_africa != '' AND south_africa != 'NaN'
UNION ALL
SELECT pilot_name, 'BELGIUM', CAST(belgium AS SMALLINT)
FROM staging_grid_position
WHERE belgium IS NOT NULL AND belgium != '' AND belgium != 'NaN'
UNION ALL
SELECT pilot_name, 'SAN_MARINO', CAST(san_marino AS SMALLINT)
FROM staging_grid_position
WHERE san_marino IS NOT NULL AND san_marino != '' AND san_marino != 'NaN'
UNION ALL
SELECT pilot_name, 'FRANCE', CAST(france AS SMALLINT)
FROM staging_grid_position
WHERE france IS NOT NULL AND france != '' AND france != 'NaN'
UNION ALL
SELECT pilot_name, 'MONACO', CAST(monaco AS SMALLINT)
FROM staging_grid_position
WHERE monaco IS NOT NULL AND monaco != '' AND monaco != 'NaN'
UNION ALL
SELECT pilot_name, 'CANADA', CAST(canada AS SMALLINT)
FROM staging_grid_position
WHERE canada IS NOT NULL AND canada != '' AND canada != 'NaN'
UNION ALL
SELECT pilot_name, 'DETROIT', CAST(detroit AS SMALLINT)
FROM staging_grid_position
WHERE detroit IS NOT NULL AND detroit != '' AND detroit != 'NaN'
UNION ALL
SELECT pilot_name, 'DALLAS', CAST(dallas AS SMALLINT)
FROM staging_grid_position
WHERE dallas IS NOT NULL AND dallas != '' AND dallas != 'NaN'
UNION ALL
SELECT pilot_name, 'BRITAIN', CAST(britain AS SMALLINT)
FROM staging_grid_position
WHERE britain IS NOT NULL AND britain != '' AND britain != 'NaN'
UNION ALL
SELECT pilot_name, 'DEUTSCHLAND', CAST(deutschland AS SMALLINT)
FROM staging_grid_position
WHERE deutschland IS NOT NULL AND deutschland != '' AND deutschland != 'NaN'
UNION ALL
SELECT pilot_name, 'AUSTRIA', CAST(austria AS SMALLINT)
FROM staging_grid_position
WHERE austria IS NOT NULL AND austria != '' AND austria != 'NaN'
UNION ALL
SELECT pilot_name, 'NETHERLANDS', CAST(netherlands AS SMALLINT)
FROM staging_grid_position
WHERE netherlands IS NOT NULL AND netherlands != '' AND netherlands != 'NaN'
UNION ALL
SELECT pilot_name, 'ITALY', CAST(italy AS SMALLINT)
FROM staging_grid_position
WHERE italy IS NOT NULL AND italy != '' AND italy != 'NaN'
UNION ALL
SELECT pilot_name, 'EURO', CAST(euro AS SMALLINT)
FROM staging_grid_position
WHERE euro IS NOT NULL AND euro != '' AND euro != 'NaN'
UNION ALL
SELECT pilot_name, 'PORTUGAL', CAST(portugal AS SMALLINT)
FROM staging_grid_position
WHERE portugal IS NOT NULL AND portugal != '' AND portugal != 'NaN';


SELECT * FROM grid_position;


---Создаем таблицу для преобразованных данных о результатах гонки---
CREATE TABLE IF NOT EXISTS races_result (
    result_id SERIAL PRIMARY KEY,
    pilot_name VARCHAR(50),
    race_name VARCHAR(20),
    finish_position VARCHAR(10),
    half_points BOOLEAN DEFAULT FALSE
);

---Очищаем данные от пропусков 'NaN', 'NULL' и заполняем таблицу чистыми данными---
INSERT INTO races_result (pilot_name, race_name, finish_position)
SELECT pilot_name, 'BRAZIL', brazil
FROM staging_races_result
WHERE brazil IS NOT NULL AND brazil != '' AND brazil != 'NaN'
UNION ALL
SELECT pilot_name, 'SOUTH_AFRICA', south_africa
FROM staging_races_result
WHERE south_africa IS NOT NULL AND south_africa != '' AND south_africa != 'NaN'
UNION ALL
SELECT pilot_name, 'BELGIUM', belgium
FROM staging_races_result
WHERE belgium IS NOT NULL AND belgium != '' AND belgium != 'NaN'
UNION ALL
SELECT pilot_name, 'SAN_MARINO', san_marino
FROM staging_races_result
WHERE san_marino IS NOT NULL AND san_marino != '' AND san_marino != 'NaN'
UNION ALL
SELECT pilot_name, 'FRANCE', france
FROM staging_races_result
WHERE france IS NOT NULL AND france != '' AND france != 'NaN'
UNION ALL
SELECT pilot_name, 'MONACO', monaco
FROM staging_races_result
WHERE monaco IS NOT NULL AND monaco != '' AND monaco != 'NaN'
UNION ALL
SELECT pilot_name, 'CANADA', canada
FROM staging_races_result
WHERE canada IS NOT NULL AND canada != '' AND canada != 'NaN'
UNION ALL
SELECT pilot_name, 'DETROIT', detroit
FROM staging_races_result
WHERE detroit IS NOT NULL AND detroit != '' AND detroit != 'NaN'
UNION ALL
SELECT pilot_name, 'DALLAS', dallas
FROM staging_races_result
WHERE dallas IS NOT NULL AND dallas != '' AND dallas != 'NaN'
UNION ALL
SELECT pilot_name, 'BRITAIN', britain
FROM staging_races_result
WHERE britain IS NOT NULL AND britain != '' AND britain != 'NaN'
UNION ALL
SELECT pilot_name, 'DEUTSCHLAND', deutschland
FROM staging_races_result
WHERE deutschland IS NOT NULL AND deutschland != '' AND deutschland != 'NaN'
UNION ALL
SELECT pilot_name, 'AUSTRIA', austria
FROM staging_races_result
WHERE austria IS NOT NULL AND austria != '' AND austria != 'NaN'
UNION ALL
SELECT pilot_name, 'NETHERLANDS', netherlands
FROM staging_races_result
WHERE netherlands IS NOT NULL AND netherlands != '' AND netherlands != 'NaN'
UNION ALL
SELECT pilot_name, 'ITALY', italy
FROM staging_races_result
WHERE italy IS NOT NULL AND italy != '' AND italy != 'NaN'
UNION ALL
SELECT pilot_name, 'EURO', euro
FROM staging_races_result
WHERE euro IS NOT NULL AND euro != '' AND euro != 'NaN'
UNION ALL
SELECT pilot_name, 'PORTUGAL', portugal
FROM staging_races_result
WHERE portugal IS NOT NULL AND portugal != '' AND portugal != 'NaN';


/* Из-за непрекращающегося дождя гонка в Монако была остановлена раньше времени,
   в связи с этим количество заработанных очков уменьшилось вдвое
   (вместо 9 заработано 4.5, вместо 6 заработано 3 и т.п.) */
UPDATE races_result
SET half_points = TRUE
WHERE race_name = 'MONACO';


SELECT * FROM races_result;

---Создаем таблицу для преобразованных данных о количестве кругов лидирования пилотов---
CREATE TABLE IF NOT EXISTS laps_lead_stats_pilots (
	stat_id SERIAL PRIMARY KEY,
	pilot_name VARCHAR(50),
	laps_lead DECIMAL(10, 2)
);


INSERT INTO laps_lead_stats_pilots (pilot_name, laps_lead)
SELECT
	pilot_name,
	CAST(laps_lead AS DECIMAL(10, 2)) AS laps_lead
FROM staging_laps_lead_pilots
WHERE pilot_name IS NOT NULL AND pilot_name != 'NaN'
ORDER BY laps_lead DESC;


SELECT * FROM laps_lead_stats_pilots;

---Создаем таблицу для преобразованных данных о количестве пройденных кругов пилотов---
CREATE TABLE IF NOT EXISTS laps_raced_stats_pilots (
	stat_id SERIAL PRIMARY KEY,
	pilot_name VARCHAR(50),
	laps_raced DECIMAL(10, 2),
	percentage DECIMAL(5, 2)
);


INSERT INTO laps_raced_stats_pilots (pilot_name, laps_raced, percentage)
SELECT
	pilot_name,
	CAST(laps_raced AS DECIMAL(10, 2)),
	CAST(REPLACE(percentage, '%', '') AS DECIMAL(5, 2))
FROM staging_laps_raced_pilots
WHERE pilot_name IS NOT NULL AND pilot_name != 'NaN'
ORDER BY laps_raced DESC;


SELECT * FROM laps_raced_stats_pilots;


---Создаем таблицу о количестве заработанных очков за каждую гонку---
CREATE TABLE IF NOT EXISTS race_points (
	point_id SERIAL PRIMARY KEY,
	pilot_name VARCHAR(50),
	race_name VARCHAR(50),
	finish_position VARCHAR(10),
	points SMALLINT
);

/* Преобразуем занятое место пилота на финише в количество заработанных им очков.
   Заполняем таблицу преобразованными данными */
INSERT INTO race_points (pilot_name, race_name, finish_position, points)
SELECT
	pilot_name,
	race_name,
	finish_position,
	CASE
		WHEN finish_position = '1' THEN 9
		WHEN finish_position = '2' THEN 6
		WHEN finish_position = '3' THEN 4
		WHEN finish_position = '4' THEN 3
		WHEN finish_position = '5' THEN 2
		WHEN finish_position = '6' THEN 1
		ELSE 0
	END AS points
FROM races_result;


SELECT * FROM race_points;

----------------Аналитические таблицы----------------

---Данные о рейтинге пилотов в финальном зачете чемпионата---

CREATE TABLE pilots_top (
    win_id SERIAL PRIMARY KEY,
    pilot_name VARCHAR(50),
    total_points DECIMAL(5,2),
    wins_count INT,
    podiums INT
);

/* Наполняем таблицу суммой заработанных очков пилота, количеством побед,
   количеством подиумов(1 или 2 или 3 места) */
INSERT INTO pilots_top (pilot_name, total_points, wins_count, podiums)
SELECT 
    pilot_name,
    SUM(
        CASE 
            WHEN finish_position = '1' AND half_points = TRUE THEN 4.5
            WHEN finish_position = '1' THEN 9
            WHEN finish_position = '2' AND half_points = TRUE THEN 3
            WHEN finish_position = '2' THEN 6
            WHEN finish_position = '3' AND half_points = TRUE THEN 2
            WHEN finish_position = '3' THEN 4
            WHEN finish_position = '4' AND half_points = TRUE THEN 1.5
            WHEN finish_position = '4' THEN 3
            WHEN finish_position = '5' AND half_points = TRUE THEN 1
            WHEN finish_position = '5' THEN 2
            WHEN finish_position = '6' AND half_points = TRUE THEN 0.5
            WHEN finish_position = '6' THEN 1
            ELSE 0
        END
    ) AS total_points,
    COUNT(CASE WHEN finish_position = '1' THEN 1 END) AS wins_count,
    COUNT(CASE WHEN finish_position IN ('1', '2', '3') THEN 1 END) AS podiums
FROM races_result
GROUP BY pilot_name
ORDER BY 
	total_points DESC,
	wins_count DESC,
	podiums DESC;

/* Решающее значение имеет количество заработанных очков пилота, чем их больше - тем пилот выше в рейтинге.
   В случае если количество очков двух или более гонщиков совпадает - 
   их позиции в финальном зачете определяется сравнением занятых мест.
   Например, если обратить внимание на гонщиков №9 и №10 - количество очков одинаково,
   победы у обоих гонщиков отсутствуют, однако гонщик №9 в Монако заработал 3 очка за второе место. */
SELECT * FROM pilots_top
LIMIT 10;



---Статистика поулов(старт с первой позиции) и подсчет среднего значения стартовой позиции---

CREATE TABLE IF NOT EXISTS pole_position_stats (
    stat_id SERIAL PRIMARY KEY,
    pilot_name VARCHAR(100),
    pole_count INT,
    avg_starting_position DECIMAL(5,2)
);

INSERT INTO pole_position_stats (pilot_name, pole_count, avg_starting_position)
SELECT 
    pilot_name,
    COUNT(CASE WHEN starting_position = 1 THEN 1 END) AS pole_count,
    ROUND(AVG(CAST(starting_position AS DECIMAL)), 1) AS avg_starting_position
FROM grid_position
GROUP BY pilot_name
HAVING COUNT(CASE WHEN starting_position = 1 THEN 1 END) > 0
ORDER BY pole_count DESC, avg_starting_position ASC;


SELECT * FROM pole_position_stats;


---Процент кругов лидирования от общего числа пройденных---

CREATE TABLE IF NOT EXISTS laps_efficiency (
    efficiency_id SERIAL PRIMARY KEY,
    pilot_name VARCHAR(100),
    laps_led INT,
    laps_raced DECIMAL(10,2),
    led_percentage DECIMAL(5,2)  -- процент кругов лидирования
);

INSERT INTO laps_efficiency (pilot_name, laps_led, laps_raced, led_percentage)
SELECT 
    ll.pilot_name,
    ll.laps_lead,
    lr.laps_raced,
    ROUND((ll.laps_lead / lr.laps_raced) * 100) AS led_percentage
FROM laps_lead_stats_pilots ll
JOIN laps_raced_stats_pilots lr ON ll.pilot_name = lr.pilot_name
ORDER BY led_percentage DESC;


SELECT * FROM laps_efficiency;



---Стабильность пилота (среднее место на финише, среднее место на старте, средний прогресс, количество гонок)
CREATE TABLE IF NOT EXISTS pilot_stability (
    stability_id SERIAL PRIMARY KEY,
    pilot_name VARCHAR(100),
    avg_finish_position DECIMAL(5,2),
    avg_start_position DECIMAL(5,2),
    avg_progress DECIMAL(5,2),
    races_count INT
);

INSERT INTO pilot_stability (pilot_name, avg_finish_position, avg_start_position, avg_progress, races_count)
SELECT 
    rr.pilot_name,
    AVG(CAST(rr.finish_position AS DECIMAL)),
    AVG(CAST(gp.starting_position AS DECIMAL)),
    AVG(gp.starting_position - CAST(rr.finish_position AS INT)),
    COUNT(*)
FROM races_result rr
JOIN grid_position gp ON rr.pilot_name = gp.pilot_name AND rr.race_name = gp.race_name
WHERE finish_position IN ('1', '2', '3', '4', '5', '6', '7', '8', '9', '10',
                           '11', '12', '13', '14', '15', '16', '17', '18', '19', '20')
  AND finish_position IS NOT NULL
GROUP BY rr.pilot_name
ORDER BY AVG(CAST(rr.finish_position AS DECIMAL)) ASC;  -- ← Используем полное выражение

-- Проверяем
SELECT * FROM pilot_stability LIMIT 10;


-------Топ-5 команд-----
CREATE TABLE IF NOT EXISTS constructor_report (
    report_id SERIAL PRIMARY KEY,
    constructor_name VARCHAR(100),
    total_points DECIMAL(5,2),
    wins_count INT,
    poles_count INT,
    avg_finish_position DECIMAL(5,2),
    avg_start_position DECIMAL(5,2)
);

INSERT INTO constructor_report (
    constructor_name, 
    total_points, 
    wins_count, 
    poles_count,
    avg_finish_position, 
    avg_start_position
)
SELECT 
    p.chassis,
    SUM(pt.total_points) AS total_points,
    SUM(pt.wins_count) AS wins_count,
    SUM(pps.pole_count) AS poles_count,
    AVG(ps.avg_finish_position) AS avg_finish_position,
    AVG(ps.avg_start_position) AS avg_start_position
FROM pilots p
LEFT JOIN pilots_top pt ON p.pilot_name = pt.pilot_name
LEFT JOIN pole_position_stats pps ON p.pilot_name = pps.pilot_name
LEFT JOIN pilot_stability ps ON p.pilot_name = ps.pilot_name
GROUP BY p.chassis
ORDER BY total_points DESC
LIMIT 5;

-- Проверяем
SELECT * FROM constructor_report;


-- Создаём таблицу победителей каждой гонки
CREATE TABLE IF NOT EXISTS race_winners (
    race_id SERIAL PRIMARY KEY,
    race_name VARCHAR(50),
    winner_name VARCHAR(100),
    team VARCHAR(100)
);

INSERT INTO race_winners (race_name, winner_name, team)
SELECT 
    rr.race_name,
    rr.pilot_name AS winner_name,
    p.chassis AS team
FROM races_result rr
JOIN pilots p ON rr.pilot_name = p.pilot_name
WHERE rr.finish_position = '1'
ORDER BY rr.result_id;

-- Проверяем
SELECT * FROM race_winners;
