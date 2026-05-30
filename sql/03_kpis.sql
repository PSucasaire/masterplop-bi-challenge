-- ==================================================
-- MASTERPLOP -  03 KPIS
-- Calculo de indicadores del negocios
-- ==================================================

-- KPI 1: VOLUMEN
-- 	Cantidad de tarjetas por tipo de transacción por trimestre

CREATE OR REPLACE TABLE kpi_volume_quarter AS
SELECT
    purchase_year,
    purchase_quarter,
    product_type,
    COUNT(DISTINCT card_id) AS total_cards,
    COUNT(*) AS total_transactions,
    SUM(transaction_amount) AS total_amount
FROM 
	stg_transactions
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;



	
	

-- KPI 2: TICKET TRIMESTRAL
-- Gasto promedio por tarjeta de crédito por trimestre.

CREATE OR REPLACE TABLE kpi_quarter_ticket AS
SELECT
    purchase_year,
    purchase_quarter,
    COUNT(DISTINCT card_id) AS total_credit_cards,
    COUNT(*) AS total_credit_transactions,
    SUM(transaction_amount) AS total_credit_amount,
    ROUND(
        SUM(transaction_amount) / NULLIF(COUNT(DISTINCT card_id), 0),
        2
    ) AS avg_spend_per_credit_card
FROM 
	stg_transactions
WHERE 
	product_type = 'CREDIT'
GROUP BY 1, 2
ORDER BY 1, 2;




-- KPI 3: TICKET REGIONAL
-- Monto promedio de transacción de tarjetas de crédito  por producto en países de Sudamérica.
-- country_merchant = país donde ocurrre la compra

CREATE OR REPLACE TABLE kpi_regional_ticket AS
SELECT
    country_merchant,
    product_name,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT card_id) AS total_cards,
    SUM(transaction_amount) AS total_amount,
    ROUND(AVG(transaction_amount), 2) AS avg_transaction_amount
FROM 
	stg_transactions
WHERE product_type = 'CREDIT'
  AND country_merchant IN (
      'ARGENTINA',
      'BOLIVIA',
      'BRAZIL',
      'CHILE',
      'COLOMBIA',
      'ECUADOR',
      'PARAGUAY',
      'PERU',
      'URUGUAY'
  )
GROUP BY 1, 2
ORDER BY 1, 2;


-- KPI 4: TOP COMERCIOS / MCG
-- Ranking Top 10 de porcentaje de gasto por nombre de MCG.

CREATE OR REPLACE TABLE kpi_top_mcg AS
WITH mcg_spend AS (
    SELECT
        mcg_name,
        COUNT(*) AS total_transactions,
        COUNT(DISTINCT card_id) AS total_cards,
        SUM(transaction_amount) AS total_amount
    FROM stg_transactions
    GROUP BY 1
),

total_spend AS (
    SELECT
        SUM(transaction_amount) AS grand_total_amount
    FROM 
    	stg_transactions
)

SELECT
    ROW_NUMBER() OVER (ORDER BY m.total_amount DESC) AS ranking,
    m.mcg_name,
    m.total_transactions,
    m.total_cards,
    m.total_amount,
    ROUND(
        100.0 * m.total_amount / NULLIF(t.grand_total_amount, 0),
        2
    ) AS spend_percentage
FROM 
	mcg_spend m
CROSS JOIN 
	total_spend t
ORDER BY ranking
LIMIT 10;




-- KPI 5: ADOPCIÓN TECNOLÓGICA
-- Porcentaje de gasto contactless ordenado por país.
-- country_card = país emisor de la tarjeta.

CREATE OR REPLACE TABLE kpi_contactless_adoption AS
SELECT
    country_card,
    COUNT(*) AS total_transactions,
    SUM(transaction_amount) AS total_amount,
    SUM(CASE WHEN is_contactless = 1 THEN transaction_amount ELSE 0 END) AS contactless_amount,
    ROUND(
        100.0 * SUM(CASE WHEN is_contactless = 1 THEN transaction_amount ELSE 0 END)
        / NULLIF(SUM(transaction_amount), 0),
        2
    ) AS contactless_spend_percentage
FROM 
	stg_transactions
GROUP BY 1
ORDER BY contactless_spend_percentage DESC;

SELECT *
FROM kpi_contactless_adoption