-- ==================================================
-- MASTERPLOP -  02 DATA QUALITY
-- validación previo a calculo de KPIs
-- ==================================================

--  VOLUMEN 

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT card_id) AS unique_cards
FROM 
	stg_transactions;

-- VALIDACION DE NULOS
SELECT
    SUM(CASE WHEN card_id IS NULL THEN 1 ELSE 0 END) AS null_card_id,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS null_product_name,
    SUM(CASE WHEN product_type IS NULL THEN 1 ELSE 0 END) AS null_product_type,
    SUM(CASE WHEN transaction_amount IS NULL THEN 1 ELSE 0 END) AS null_amount,
    SUM(CASE WHEN purchase_date IS NULL THEN 1 ELSE 0 END) AS null_purchase_date,
    SUM(CASE WHEN country_card IS NULL THEN 1 ELSE 0 END) AS null_country_card,
    SUM(CASE WHEN country_merchant IS NULL THEN 1 ELSE 0 END) AS null_country_merchant,
    SUM(CASE WHEN mcg_id IS NULL THEN 1 ELSE 0 END) AS null_mcg_id,
    SUM(CASE WHEN mcg_name IS NULL THEN 1 ELSE 0 END) AS null_mcg_name
FROM 
	stg_transactions;

-- VALIDACIÓN DE TIPOS DE PRODUCTO
	
SELECT
    product_type,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT card_id) AS unique_cards,
    SUM(transaction_amount) AS total_amount
FROM 
	stg_transactions
GROUP BY 1
ORDER BY 2 DESC;

-- VALIDACIÓN DE FECHAS

SELECT
    MIN(purchase_date) AS min_purchase_date,
    MAX(purchase_date) AS max_purchase_date,
    COUNT(DISTINCT purchase_year) AS total_years,
    COUNT(DISTINCT purchase_month) AS total_months,
    COUNT(DISTINCT purchase_quarter) AS total_quarters
FROM 
	stg_transactions;


SELECT
    purchase_year,
    purchase_month,
    COUNT(*) AS total_transactions,
    SUM(transaction_amount) AS total_amount_usd
FROM 
	stg_transactions
GROUP BY 1, 2
ORDER BY 1, 2;


-- VALIDACIÓN DE PAÍSES

SELECT
    country_card,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT card_id) AS unique_cards,
    SUM(transaction_amount) AS total_amount_usd
FROM 
	stg_transactions
GROUP BY 1
ORDER BY 2 DESC;


SELECT
    country_merchant,
    COUNT(*) AS total_transactions,
    SUM(transaction_amount) AS total_amount_usd
FROM 
	stg_transactions
GROUP BY 1
ORDER BY 2 DESC;

-- VALIDACIÓN DE FLAGS

SELECT
    is_international,
    COUNT(*) AS total_transactions,
    SUM(transaction_amount) AS total_amount_usd
FROM 
	stg_transactions
GROUP BY 1
ORDER BY 1;


SELECT
    is_contactless,
    COUNT(*) AS total_transactions,
    SUM(transaction_amount) AS total_amount_usd
FROM 
	stg_transactions
GROUP BY 1
ORDER BY 1;


-- VALIDACIÓN DE MONTOS

SELECT
    COUNT(*) AS total_rows,
    MIN(transaction_amount) AS min_amount,
    MAX(transaction_amount) AS max_amount,
    AVG(transaction_amount) AS avg_amount,
    MEDIAN(transaction_amount) AS median_amount
FROM 
	stg_transactions;


SELECT
    COUNT(*) AS zero_or_negative_amounts
FROM 
	stg_transactions
WHERE 
	transaction_amount <= 0;


-- VALIDACIÓN DE MCG

SELECT
    mcg_id,
    mcg_name,
    COUNT(*) AS total_transactions,
    SUM(transaction_amount) AS total_amount_usd
FROM 
	stg_transactions
GROUP BY 1, 2
ORDER BY 3 DESC;


SELECT
    COUNT(*) AS unmapped_mcg_rows,
    SUM(transaction_amount) AS unmapped_mcg_amount_usd
FROM 
	stg_transactions
WHERE 
	mcg_name = 'Uncategorized';



-- POSIBLES DUPLICADOS

SELECT
    card_id,
    product_name,
    product_type,
    transaction_amount,
    purchase_date,
    country_card,
    country_merchant,
    merchant_name,
    COUNT(*) AS duplicated_rows
FROM 
	stg_transactions
GROUP BY
    card_id,
    product_name,
    product_type,
    transaction_amount,
    purchase_date,
    country_card,
    country_merchant,
    merchant_name
HAVING COUNT(*) > 1
ORDER BY duplicated_rows DESC;


-- VALIDACIÓN CASHBACK

SELECT
    COUNT(*) AS eligible_transactions,
    COUNT(DISTINCT card_id) AS eligible_cards,
    SUM(transaction_amount) AS eligible_amount_usd
FROM 
	stg_transactions
WHERE 
	product_type = 'CREDIT'
	AND country_card = 'CHILE'
	AND country_merchant <> 'CHILE'
	AND purchase_year = 2024
	AND purchase_month = 5;