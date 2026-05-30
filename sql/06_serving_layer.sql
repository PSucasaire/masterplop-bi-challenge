-- ==================================================
-- MASTERPLOP - 06 SERVING LAYER
-- Tablas finales disponibles para el Power BI
-- ==================================================

-- 1. VALIDACIÓN DE TABLAS PRINCIPALES

SELECT 'fact_transactions_agg' AS table_name, COUNT(*) AS total_rows
FROM fact_transactions_agg

UNION ALL

SELECT 'dim_date' AS table_name, COUNT(*) AS total_rows
FROM dim_date

UNION ALL

SELECT 'dim_product' AS table_name, COUNT(*) AS total_rows
FROM dim_product

UNION ALL

SELECT 'dim_country_card' AS table_name, COUNT(*) AS total_rows
FROM dim_country_card

UNION ALL

SELECT 'dim_country_merchant' AS table_name, COUNT(*) AS total_rows
FROM dim_country_merchant

UNION ALL

SELECT 'dim_mcg' AS table_name, COUNT(*) AS total_rows
FROM dim_mcg

UNION ALL

SELECT 'cashback_campaign_summary' AS table_name, COUNT(*) AS total_rows
FROM cashback_campaign_summary

UNION ALL

SELECT 'cashback_cap_analysis' AS table_name, COUNT(*) AS total_rows
FROM cashback_cap_analysis;



-- 2. VALIDACIÓN DE MODELO ESTRELLA

SELECT
    SUM(CASE WHEN d.date_key IS NULL THEN 1 ELSE 0 END) AS missing_date_key,
    SUM(CASE WHEN p.product_key IS NULL THEN 1 ELSE 0 END) AS missing_product_key,
    SUM(CASE WHEN cc.country_card_key IS NULL THEN 1 ELSE 0 END) AS missing_country_card_key,
    SUM(CASE WHEN cm.country_merchant_key IS NULL THEN 1 ELSE 0 END) AS missing_country_merchant_key,
    SUM(CASE WHEN m.mcg_key IS NULL THEN 1 ELSE 0 END) AS missing_mcg_key
FROM 
	fact_transactions_agg f
LEFT JOIN 
	dim_date d
    ON f.date_key = d.date_key
LEFT JOIN 
	dim_product p
    ON f.product_key = p.product_key
LEFT JOIN 
	dim_country_card cc
    ON f.country_card_key = cc.country_card_key
LEFT JOIN 
	dim_country_merchant cm
    ON f.country_merchant_key = cm.country_merchant_key
LEFT JOIN 
	dim_mcg m
    ON f.mcg_key = m.mcg_key;


-- 3. VALIDACIÓN DE MÉTRICAS BASE
-- Comparación entre staging y fact agregada.

SELECT
    'stg_transactions' AS source_table,
    COUNT(*) AS total_transactions,
    ROUND(SUM(transaction_amount), 2) AS total_amount
FROM 
	stg_transactions

UNION ALL

SELECT
    'fact_transactions_agg' AS source_table,
    SUM(total_transactions) AS total_transactions,
    ROUND(SUM(total_amount), 2) AS total_amount
FROM 
	fact_transactions_agg;






-- 5. EXPORT OPCIONAL A CSV

 COPY fact_transactions_agg TO 'C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/outputs/exports/fact_transactions_agg.csv' (HEADER, DELIMITER ',');
 COPY dim_date TO 'C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/outputs/exports/dim_date.csv' (HEADER, DELIMITER ',');
 COPY dim_product TO 'C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/outputs/exports/dim_product.csv' (HEADER, DELIMITER ',');
 COPY dim_country_card TO 'C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/outputs/exports/dim_country_card.csv' (HEADER, DELIMITER ',');
 COPY dim_country_merchant TO 'C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/outputs/exports/dim_country_merchant.csv' (HEADER, DELIMITER ',');
 COPY dim_mcg TO 'C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/outputs/exports/dim_mcg.csv' (HEADER, DELIMITER ',');
 COPY cashback_campaign_summary TO 'C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/outputs/exports/cashback_campaign_summary.csv' (HEADER, DELIMITER ',');
 COPY cashback_cap_analysis TO 'C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/outputs/exports/cashback_cap_analysis.csv' (HEADER, DELIMITER ',');
 COPY fact_cashback_card TO 'C:/Users/THINKPAD/Documents/Repositorio/Desafio Analytics Engineer/Masterplop_Challenge/outputs/exports/fact_cashback_card.csv' (HEADER, DELIMITER ',');