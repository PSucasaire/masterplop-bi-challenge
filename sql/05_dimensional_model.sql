-- ==================================================
-- MASTERPLOP -  05 DIMENSIONAL MODEL
-- Modelo dimensional optimizado para Power BI
-- ==================================================

-- 1 DIM PRODUCT

CREATE OR REPLACE TABLE dim_product AS
SELECT
    ROW_NUMBER() OVER (ORDER BY product_type, product_name) AS product_key,
    product_name,
    product_type
FROM (
    SELECT DISTINCT
        product_name,
        product_type
    FROM stg_transactions
);


-- 2 dim_country_card

CREATE OR REPLACE TABLE dim_country_card AS
SELECT
    ROW_NUMBER() OVER (ORDER BY country_card) AS country_card_key,
    upper(left(country_card,1)) || lower(substr(country_card,2)) as country_card
FROM (
    SELECT DISTINCT country_card
    FROM stg_transactions
)
UNION ALL

SELECT
    -1 AS country_card_key,
    'Otros' AS country_card;





--3 dim_country_merchant

CREATE OR REPLACE TABLE dim_country_merchant AS
SELECT
    ROW_NUMBER() OVER (ORDER BY country_merchant) AS country_merchant_key,
    upper(left(country_merchant,1)) || lower(substr(country_merchant,2)) as country_merchant
FROM (
    SELECT DISTINCT country_merchant
    FROM stg_transactions
)
UNION ALL

SELECT
    -1 AS country_merchant_key,
    'Otros' AS country_merchant;




-- 4 dim_mcg

CREATE OR REPLACE TABLE dim_mcg AS
SELECT
    ROW_NUMBER() OVER (ORDER BY mcg_id) AS mcg_key,
    mcg_id,
    mcg_name
FROM (
    SELECT DISTINCT
        mcg_id,
        mcg_name
    FROM stg_transactions
);


-- 5 dim_date

CREATE OR REPLACE TABLE dim_date AS
SELECT
    CAST(
        CAST(purchase_year AS VARCHAR) ||
        LPAD(CAST(purchase_month AS VARCHAR), 2, '0')
    AS INTEGER) AS date_key,
    purchase_year,
    purchase_month,
    purchase_quarter,
    CONCAT(CAST(purchase_year AS VARCHAR), '-Q', CAST(purchase_quarter AS VARCHAR)) AS year_quarter,
    CONCAT(CAST(purchase_year AS VARCHAR), '-', LPAD(CAST(purchase_month AS VARCHAR), 2, '0')) AS year_month
FROM (
    SELECT DISTINCT
        purchase_year,
        purchase_month,
        purchase_quarter
    FROM stg_transactions
);


-- 6 fact_transaccions

CREATE OR REPLACE TABLE fact_transactions_agg AS
SELECT
    d.date_key,
    p.product_key,
    cc.country_card_key,
    cm.country_merchant_key,
    m.mcg_key,

    s.is_contactless,
    s.is_international,

    COUNT(*) AS total_transactions,
    COUNT(DISTINCT s.card_id) AS unique_cards,
    ROUND(SUM(s.transaction_amount), 2) AS total_amount,
    ROUND(AVG(s.transaction_amount), 2) AS avg_transaction_amount,
    ROUND(MEDIAN(s.transaction_amount), 2) AS median_transaction_amount

FROM 
	stg_transactions s

LEFT JOIN 
	dim_date d
	ON s.purchase_year = d.purchase_year
	AND s.purchase_month = d.purchase_month

LEFT JOIN 
	dim_product p
	ON s.product_name = p.product_name
	AND s.product_type = p.product_type

LEFT JOIN 
	dim_country_card cc
    ON s.country_card = cc.country_card

LEFT JOIN 
	dim_country_merchant cm
    ON s.country_merchant = cm.country_merchant

LEFT JOIN 
	dim_mcg m
    ON s.mcg_id = m.mcg_id
GROUP BY
    d.date_key,
    p.product_key,
    cc.country_card_key,
    cm.country_merchant_key,
    m.mcg_key,
    s.is_contactless,
    s.is_international;




CREATE OR REPLACE TABLE fact_cashback_card AS
WITH eligible AS (
    SELECT
        s.card_id,
        d.date_key,
        p.product_key,
        cc.country_card_key,
        cm.country_merchant_key,
        m.mcg_key,
        CAST(s.transaction_amount AS DOUBLE) AS transaction_amount
    FROM stg_transactions s

    LEFT JOIN dim_date d
        ON s.purchase_year = d.purchase_year
       AND s.purchase_month = d.purchase_month

    LEFT JOIN dim_product p
        ON s.product_name = p.product_name
       AND s.product_type = p.product_type

    LEFT JOIN dim_country_card cc
        ON UPPER(TRIM(s.country_card)) = UPPER(TRIM(cc.country_card))

    LEFT JOIN dim_country_merchant cm
        ON UPPER(TRIM(s.country_merchant)) = UPPER(TRIM(cm.country_merchant))

    LEFT JOIN dim_mcg m
        ON s.mcg_id = m.mcg_id

    WHERE
        s.product_type = 'CREDIT'
        AND UPPER(TRIM(s.country_card)) = 'CHILE'
        AND UPPER(TRIM(s.country_merchant)) <> 'CHILE'
        AND s.purchase_year = 2024
        AND s.purchase_month = 5
        AND s.transaction_amount > 0
),

cashback_by_card AS (
    SELECT
        card_id,
        COUNT(*) AS eligible_transactions_card,
        SUM(transaction_amount) AS eligible_amount_card,
        ROUND(SUM(transaction_amount) * 0.07, 2) AS raw_cashback_card,
        LEAST(ROUND(SUM(transaction_amount) * 0.07, 2), 50) AS final_cashback_card,
        ROUND(
            ROUND(SUM(transaction_amount) * 0.07, 2)
            - LEAST(ROUND(SUM(transaction_amount) * 0.07, 2), 50),
            2
        ) AS savings_due_to_cap_card,
        CASE
            WHEN ROUND(SUM(transaction_amount) * 0.07, 2) > 50
            THEN 'Con Tope Aplicado'
            ELSE 'Dentro del Tope'
        END AS cap_status
    FROM eligible
    GROUP BY card_id
),

card_dim AS (
    SELECT
        card_id,
        date_key,
        product_key,
        country_card_key,
        country_merchant_key,
        mcg_key,
        COUNT(*) AS eligible_transactions,
        SUM(transaction_amount) AS eligible_amount
    FROM eligible
    GROUP BY
        card_id,
        date_key,
        product_key,
        country_card_key,
        country_merchant_key,
        mcg_key
)

SELECT
    cd.card_id,
    cd.date_key,
    cd.product_key,
    cd.country_card_key,
    cd.country_merchant_key,
    cd.mcg_key,

    cd.eligible_transactions,

    ROUND(cd.eligible_amount, 2) AS eligible_amount,

    ROUND(cd.eligible_amount * 0.07, 2) AS theoretical_cashback,

    ROUND(
        (cd.eligible_amount / NULLIF(cbc.eligible_amount_card, 0))
        * cbc.final_cashback_card,
        2
    ) AS final_cashback,

    ROUND(
        (cd.eligible_amount / NULLIF(cbc.eligible_amount_card, 0))
        * cbc.savings_due_to_cap_card,
        2
    ) AS savings_due_to_cap,

    cbc.cap_status

FROM card_dim cd
LEFT JOIN cashback_by_card cbc
    ON cd.card_id = cbc.card_id;


SELECT
    COUNT(DISTINCT card_id) AS tarjetas,
    SUM(eligible_transactions) AS transacciones,
    ROUND(SUM(eligible_amount), 2) AS monto_elegible,
    ROUND(SUM(theoretical_cashback), 2) AS cashback_teorico,
    ROUND(SUM(final_cashback), 2) AS cashback_final,
    ROUND(SUM(savings_due_to_cap), 2) AS ahorro_tope
FROM fact_cashback_card;


SELECT
    cap_status,
    COUNT(DISTINCT card_id) AS tarjetas,
    ROUND(SUM(eligible_amount), 2) AS monto_elegible,
    ROUND(SUM(final_cashback), 2) AS cashback_final,
    ROUND(SUM(savings_due_to_cap), 2) AS ahorro_tope,
    ROUND(SUM(eligible_transactions), 2) AS transacciones,
FROM fact_cashback_card
GROUP BY cap_status;
