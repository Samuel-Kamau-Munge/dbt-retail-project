WITH warehouse_count AS (
    SELECT COUNT(DISTINCT customer_key) AS cnt
    FROM {{ ref('dim_customers') }}
    WHERE is_active_flag = TRUE
),
mart_count AS (
    SELECT COUNT(DISTINCT customer_key) AS cnt
    FROM {{ ref('customer_lifetime_value') }}
)
SELECT
    w.cnt AS warehouse_customers,
    m.cnt AS mart_customers,
    (m.cnt::NUMERIC - w.cnt::NUMERIC) / NULLIF(w.cnt, 0) * 100 AS pct_diff
FROM warehouse_count w,
     mart_count m
WHERE m.cnt > w.cnt * 1.05
