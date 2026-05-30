-- ==================================================
-- MASTERPLOP - STAGING
-- Limpieza 
-- ==================================================

CREATE OR REPLACE TABLE stg_transactions AS

SELECT 
	CAST(card_id AS VARCHAR) AS card_id,
	product_name,
	
	-- NORMALIZAMOS PRODUCTO 
	
	CASE
        WHEN UPPER(TRIM(product_type)) IN ('CRÉDITO', 'CREDITO', 'CREDIT') THEN 'CREDIT'
        WHEN UPPER(TRIM(product_type)) IN ('DÉBITO', 'DEBITO', 'DEBIT')THEN 'DEBIT'
        ELSE UPPER(TRIM(product_type))
    END AS product_type,
    
    --METRICA
    CAST(amt AS double) AS transaction_amount,
    
    --FLAG
    CAST(is_xb AS INTEGER) AS is_international,
    CAST(is_contactless AS INTEGER) AS is_contactless,
    
    --FECHAS
    STRPTIME(REPLACE(prch_date, '-', '/'),'%d/%m/%Y') AS purchase_date,

    CAST (EXTRACT(YEAR FROM STRPTIME(REPLACE(prch_date, '-', '/'),'%d/%m/%Y')) AS INTEGER) AS purchase_year,

    CAST (EXTRACT(MONTH FROM STRPTIME(REPLACE(prch_date, '-', '/'),'%d/%m/%Y')) AS INTEGER) AS purchase_month,

    CAST (EXTRACT(QUARTER FROM STRPTIME(REPLACE(prch_date, '-', '/'),'%d/%m/%Y')) AS INTEGER) AS purchase_quarter,
    
    --UBICACION

    CASE
    	WHEN TRANSLATE(UPPER(TRIM(ctry_card)), 'ÁÉÍÓÚ', 'AEIOU') = 'BRASIL' THEN 'BRAZIL'
    	ELSE TRANSLATE(UPPER(TRIM(ctry_card)), 'ÁÉÍÓÚ', 'AEIOU')
	END AS country_card,
    
    CASE
    	WHEN TRANSLATE(UPPER(TRIM(ctry_mrch)), 'ÁÉÍÓÚ', 'AEIOU') = 'BRASIL' THEN 'BRAZIL'
    	ELSE TRANSLATE(UPPER(TRIM(ctry_mrch)), 'ÁÉÍÓÚ', 'AEIOU')
	END AS country_merchant,
    
    --COMERCIO 
    TRIM(mrch) AS merchant_name,
    mcg_id,
    COALESCE(mcg_name, 'Uncategorized') AS mcg_name,
    
    --FLAG DEL NEGOCIO
    CASE
        WHEN UPPER(TRIM(product_type)) IN ('CRÉDITO', 'CREDITO', 'CREDIT') THEN 1
        ELSE 0
    END AS is_credit_card,
    
    CASE
        WHEN UPPER(TRIM(ctry_card)) = 'CHILE' THEN 1
        ELSE 0
    END AS is_chilean_card,
 FROM read_csv_auto(
 	'C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/data/raw/db_transac.csv'
 )   
 	
 LEFT JOIN read_xlsx(
 	'C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/data/raw/mcg_list.xlsx'
 )
 ON mcg_id = mcg;
 
 
 
 --VALIDAMOS TABLA
SELECT 
	*
FROM 
	stg_transactions
LIMIT 20;

SELECT 
	DISTINCT country_card
FROM 
	stg_transactions
ORDER BY 1;

SELECT 
	DISTINCT country_merchant
FROM 
	stg_transactions
ORDER BY 1;


SELECT
    mcg_name,
    COUNT(*) AS total_transactions
FROM 
	stg_transactions
GROUP BY 1
ORDER BY 2 DESC;


--  EXPORT 

 COPY stg_transactions TO 'C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/data/staging/stg_transactions.csv' (HEADER, DELIMITER ',');