-- ==================================================
-- MASTERPLOP -  04 CASHBACK
-- Campaña Mayo 2024
-- ==================================================
-- Regla de negocio:
-- Tarjetas de crédito chilenas reciben 7% de cashback
-- por compras realizadas fuera de Chile durante mayo 2024.
-- Tope máximo: 50 USD por tarjeta.



-- 1. TRANSACCIONES ELEGIBLES


CREATE OR REPLACE TABLE cashback_eligible_transactions AS
SELECT
    card_id,
    product_name,
    product_type,
    transaction_amount,
    purchase_date,
    purchase_year,
    purchase_month,
    country_card,
    country_merchant,
    merchant_name,
    mcg_id,
    mcg_name,
    is_international,
    is_contactless
FROM 
	stg_transactions
WHERE product_type = 'CREDIT'
  AND country_card = 'CHILE'
  AND country_merchant <> 'CHILE'
  AND purchase_year = 2024
  AND purchase_month = 5
  AND transaction_amount > 0;


-- 2. GASTO ELEGIBLE POR TARJETA

CREATE OR REPLACE TABLE cashback_by_card AS
SELECT
    card_id,
    COUNT(*) AS eligible_transactions,
    SUM(transaction_amount) AS eligible_amount,
    ROUND(SUM(transaction_amount) * 0.07, 2) AS raw_cashback,
    LEAST(
        ROUND(SUM(transaction_amount) * 0.07, 2),
        50
    ) AS final_cashback
FROM 
	cashback_eligible_transactions
GROUP BY 1;



-- 3. RESUMEN FINAL DE CAMPAÑA

CREATE OR REPLACE TABLE cashback_campaign_summary AS
SELECT
    COUNT(*) AS impacted_cards,
    SUM(eligible_transactions) AS eligible_transactions,
    ROUND(SUM(eligible_amount), 2) AS eligible_amount,
    ROUND(SUM(raw_cashback), 2) AS teorico_cashback,
    ROUND(SUM(final_cashback), 2) AS total_cashback_cost,
    ROUND(SUM(raw_cashback) - SUM(final_cashback), 2) AS diff_cashback,
    ROUND(AVG(final_cashback), 2) AS avg_cashback_per_card
FROM 
	cashback_by_card;



-- 4. VALIDACIÓN DE TARJETAS CON TOPE APLICADO

CREATE OR REPLACE TABLE cashback_cap_analysis AS
SELECT
    CASE
        WHEN raw_cashback > 50 THEN 'CAPPED'
        ELSE 'NOT_CAPPED'
    END AS cap_status,
    COUNT(*) AS total_cards,
    SUM(eligible_transactions) AS total_transactions,
    ROUND(SUM(eligible_amount), 2) AS total_eligible_amount,
    ROUND(SUM(raw_cashback), 2) AS theoretical_cashback,
    ROUND(SUM(final_cashback), 2) AS final_cashback
FROM cashback_by_card
GROUP BY 1
ORDER BY 1;


