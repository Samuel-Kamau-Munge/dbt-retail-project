{{ config(materialized='table', schema='retail_warehouse') }}

WITH source AS (
    SELECT
        customer_id,
        customer_unique_id,
        customer_zip_code,
        customer_city,
        customer_state,
        customer_segment,
        registration_date::DATE AS registration_date,
        first_name,
        last_name,
        email,
        phone,
        birth_date::DATE AS birth_date,
        gender,
        income_bracket,
        _extracted_at
    FROM {{ ref('stg_customers') }}
),

transformed AS (
    SELECT
        md5(customer_id::TEXT || '|' || COALESCE(registration_date::TEXT, '')) AS customer_key,
        customer_id,
        customer_unique_id,
        customer_zip_code,
        customer_city,
        customer_state,
        customer_segment,
        registration_date,
        first_name,
        last_name,
        email,
        phone,
        birth_date,
        gender,
        income_bracket,
        CASE
            WHEN birth_date IS NOT NULL
            THEN EXTRACT(YEAR FROM AGE(birth_date))::INT
            ELSE NULL
        END AS customer_age,
        CASE
            WHEN registration_date IS NOT NULL
            THEN (CURRENT_DATE - registration_date)::INT
            ELSE NULL
        END AS tenure_days,
        TRUE::BOOLEAN AS is_active_flag,
        CURRENT_DATE AS effective_start_date,
        '9999-12-31'::DATE AS effective_end_date,
        md5(customer_id::TEXT || '|' || COALESCE(registration_date::TEXT, '')) AS dbt_scd_id
    FROM source
)

SELECT * FROM transformed
