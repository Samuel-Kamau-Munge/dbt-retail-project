SELECT
    MIN(date_actual) AS min_date,
    MAX(date_actual) AS max_date,
    COUNT(*) AS total_rows
FROM {{ ref('dim_date') }}
HAVING MIN(date_actual) > '2016-01-01'::DATE
    OR MAX(date_actual) < '2030-12-31'::DATE
    OR COUNT(*) < 5000
