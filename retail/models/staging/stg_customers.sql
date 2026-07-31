{{ config(materialized='view', schema='retail_staging') }}

WITH raw AS (
    SELECT * FROM {{ source('retail_raw', 'raw_customers') }}
),

cleaned AS (
    SELECT
        customer_id::INT AS customer_id,
        customer_unique_id,
        customer_zip_code,
        {{ clean_string('customer_city') }} AS customer_city,
        {{ clean_string('customer_state') }} AS customer_state,
        {{ clean_string('customer_segment') }} AS customer_segment,
        {{ clean_date('registration_date', 'YYYY-MM-DD') }} AS registration_date,
        {{ clean_string('first_name') }} AS first_name,
        {{ clean_string('last_name') }} AS last_name,
        {{ clean_string('email') }} AS email,
        {{ clean_string('phone') }} AS phone,
        {{ clean_date('birth_date', 'YYYY-MM-DD') }} AS birth_date,
        {{ clean_string('gender') }} AS gender,
        {{ clean_string('income_bracket') }} AS income_bracket,
        _extracted_at,
        _file_name,
        md5(concat_ws('||', customer_id::TEXT)) AS dbt_scd_id
    FROM raw
),

deduped AS (
    {{ dedup_rows('cleaned', ['customer_id'], '_extracted_at DESC') }}
),

final AS (
    SELECT
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
        _extracted_at,
        _file_name,
        dbt_scd_id
    FROM deduped
)

SELECT * FROM final
