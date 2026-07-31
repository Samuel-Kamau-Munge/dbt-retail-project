{{ config(materialized='table', schema='retail_warehouse') }}

WITH date_series AS (
    SELECT d::DATE
    FROM generate_series(
        '2016-01-01'::DATE,
        '2030-12-31'::DATE,
        '1 day'::INTERVAL
    ) AS g(d)
),

date_components AS (
    SELECT
        d,
        EXTRACT(EPOCH FROM d)::BIGINT AS epoch,
        EXTRACT(ISODOW FROM d)::INT AS day_of_week,
        EXTRACT(DAY FROM d)::INT AS day_of_month,
        EXTRACT(DOY FROM d)::INT AS day_of_year,
        EXTRACT(WEEK FROM d)::INT AS week_of_year,
        TO_CHAR(d, 'IYYY-IW') AS week_of_year_iso,
        EXTRACT(MONTH FROM d)::INT AS month_actual,
        TO_CHAR(d, 'FMMonth') AS month_name,
        TO_CHAR(d, 'Mon') AS month_name_abbreviated,
        EXTRACT(QUARTER FROM d)::INT AS quarter_actual,
        EXTRACT(YEAR FROM d)::INT AS year_actual,
        EXTRACT(DOW FROM d)::INT AS dow
    FROM date_series
),

calculated AS (
    SELECT
        d,
        epoch,
        day_of_week,
        day_of_month,
        ((d - DATE_TRUNC('quarter', d)::DATE) + 1)::INT AS day_of_quarter,
        day_of_year,
        ((day_of_month - 1) / 7 + 1)::INT AS week_of_month,
        week_of_year,
        week_of_year_iso,
        month_actual,
        month_name,
        month_name_abbreviated,
        quarter_actual,
        CASE quarter_actual
            WHEN 1 THEN 'First'
            WHEN 2 THEN 'Second'
            WHEN 3 THEN 'Third'
            WHEN 4 THEN 'Fourth'
        END AS quarter_name,
        year_actual,
        DATE_TRUNC('week', d)::DATE AS first_day_of_week,
        DATE_TRUNC('month', d)::DATE AS first_day_of_month,
        DATE_TRUNC('quarter', d)::DATE AS first_day_of_quarter,
        DATE_TRUNC('year', d)::DATE AS first_day_of_year,
        (DATE_TRUNC('week', d) + INTERVAL '6 days')::DATE AS last_day_of_week,
        (DATE_TRUNC('month', d) + INTERVAL '1 month' - INTERVAL '1 day')::DATE AS last_day_of_month,
        (DATE_TRUNC('quarter', d) + INTERVAL '3 months' - INTERVAL '1 day')::DATE AS last_day_of_quarter,
        (DATE_TRUNC('year', d) + INTERVAL '1 year' - INTERVAL '1 day')::DATE AS last_day_of_year,
        TO_CHAR(d, 'MMYYYY') AS mmyyyy,
        TO_CHAR(d, 'MMDDYYYY') AS mmddyyyy,
        day_of_month AS day_suffix_num,
        dow
    FROM date_components
),

day_suffix_calc AS (
    SELECT
        d,
        epoch,
        CASE
            WHEN day_suffix_num IN (11, 12, 13) THEN day_suffix_num::TEXT || 'th'
            WHEN day_suffix_num % 10 = 1 THEN day_suffix_num::TEXT || 'st'
            WHEN day_suffix_num % 10 = 2 THEN day_suffix_num::TEXT || 'nd'
            WHEN day_suffix_num % 10 = 3 THEN day_suffix_num::TEXT || 'rd'
            ELSE day_suffix_num::TEXT || 'th'
        END AS day_suffix,
        TO_CHAR(d, 'FMDay') AS day_name,
        day_of_week,
        day_of_month,
        day_of_quarter,
        day_of_year,
        week_of_month,
        week_of_year,
        week_of_year_iso,
        month_actual,
        month_name,
        month_name_abbreviated,
        quarter_actual,
        quarter_name,
        year_actual,
        first_day_of_week,
        first_day_of_month,
        first_day_of_quarter,
        first_day_of_year,
        last_day_of_week,
        last_day_of_month,
        last_day_of_quarter,
        last_day_of_year,
        mmyyyy,
        mmddyyyy,
        CASE
            WHEN dow IN (0, 6, 7) THEN TRUE::BOOLEAN
            ELSE FALSE::BOOLEAN
        END AS weekend_indr
    FROM calculated
)

SELECT
    TO_CHAR(d, 'YYYYMMDD')::INT AS date_key,
    d AS date_actual,
    epoch,
    day_suffix,
    day_name,
    day_of_week,
    day_of_month,
    day_of_quarter,
    day_of_year,
    week_of_month,
    week_of_year,
    week_of_year_iso,
    month_actual,
    month_name,
    month_name_abbreviated,
    quarter_actual,
    quarter_name,
    year_actual,
    first_day_of_week,
    first_day_of_month,
    first_day_of_quarter,
    first_day_of_year,
    last_day_of_week,
    last_day_of_month,
    last_day_of_quarter,
    last_day_of_year,
    mmyyyy,
    mmddyyyy,
    weekend_indr
FROM day_suffix_calc
