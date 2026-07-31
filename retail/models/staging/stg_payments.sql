{{ config(materialized='view', schema='retail_staging') }}

WITH raw AS (
    SELECT * FROM {{ source('retail_raw', 'raw_payments') }}
),

cleaned AS (
    SELECT
        payment_id::INT AS payment_id,
        order_id::INT AS order_id,
        payment_sequential::INT AS payment_sequential,
        {{ clean_string('payment_type') }} AS payment_type,
        payment_installments::INT AS payment_installments,
        payment_value::NUMERIC(12,2) AS payment_value,
        {{ clean_string('payment_status') }} AS payment_status,
        {{ clean_timestamp('payment_date') }} AS payment_date,
        _extracted_at,
        _file_name,
        md5(concat_ws('||', payment_id::TEXT)) AS dbt_scd_id
    FROM raw
),

deduped AS (
    {{ dedup_rows('cleaned', ['payment_id'], '_extracted_at DESC') }}
),

final AS (
    SELECT
        payment_id,
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value,
        payment_status,
        payment_date,
        _extracted_at,
        _file_name,
        dbt_scd_id
    FROM deduped
)

SELECT * FROM final
