-- ==================================================
-- MASTERPLOP - 00 PROFILING
-- ==================================================

SELECT *
FROM read_csv_auto('C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/data/raw/db_transac.csv')
LIMIT 20;


DESCRIBE
SELECT *
FROM read_csv_auto('C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/data/raw/db_transac.csv');


-- FECHAS

SELECT
    prch_date,
    COUNT(*) AS total_rows
FROM 
	read_csv_auto('C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/data/raw/db_transac.csv')
GROUP BY 1
ORDER BY 1
LIMIT 50;


SELECT
    CASE
        WHEN prch_date LIKE '%/%' THEN 'slash_format'
        WHEN prch_date LIKE '%-%' THEN 'dash_format'
        ELSE 'other_format'
    END AS date_format_detected,
    COUNT(*) AS total_rows
FROM 
	read_csv_auto('C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/data/raw/db_transac.csv')
GROUP BY 1
ORDER BY 2 DESC;


-- VALIDACIÓN DE PRODUCT_TYPE RAW
SELECT
    product_type,
    COUNT(*) AS total_rows
FROM 
	read_csv_auto('C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/data/raw/db_transac.csv')
GROUP BY 1
ORDER BY 2 DESC;

--VALIDACIÓN DE PAÍSES RAW

SELECT
    ctry_card,
    COUNT(*) AS total_rows
FROM 
	read_csv_auto('C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/data/raw/db_transac.csv')
GROUP BY 1
ORDER BY 1;


SELECT
    ctry_mrch,
    COUNT(*) AS total_rows
FROM 
	read_csv_auto('C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/data/raw/db_transac.csv')
GROUP BY 1
ORDER BY 1;

-- VALIDACIÓN DE FLAGS RAW

SELECT
    is_xb,
    COUNT(*) AS total_rows
FROM 
	read_csv_auto('C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/data/raw/db_transac.csv')
GROUP BY 1
ORDER BY 1;


SELECT
    is_contactless,
    COUNT(*) AS total_rows
FROM 
	read_csv_auto('C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/data/raw/db_transac.csv')
GROUP BY 1
ORDER BY 1;


-- VALIDACIÓN DE MONTOS RAW

SELECT
    COUNT(*) AS total_rows,
    MIN(amt) AS min_amount,
    MAX(amt) AS max_amount,
    AVG(amt) AS avg_amount
FROM 
	read_csv_auto('C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/data/raw/db_transac.csv');

-- VALIDACIÓN DE MCG RAW

SELECT
    mcg_id,
    COUNT(*) AS total_rows
FROM read_csv_auto('C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/data/raw/db_transac.csv')
GROUP BY 1
ORDER BY 1;


-- MUESTRA DEL MAESTRO MCG
SELECT *
FROM read_xlsx('C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/data/raw/mcg_list.xlsx')
LIMIT 20;

DESCRIBE
SELECT *
FROM read_xlsx('C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/data/raw/mcg_list.xlsx');
