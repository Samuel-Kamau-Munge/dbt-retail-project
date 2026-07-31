{{ config(materialized='view', schema='retail_staging') }}

WITH raw AS (
    SELECT * FROM {{ source('retail_raw', 'raw_returns') }}
),

cleaned AS (
    SELECT
        return_id::INT AS return_id,
        order_id::INT AS order_id,
        product_id::INT AS product_id,
        customer_id::INT AS customer_id,
        {{ clean_date('return_date', 'YYYY-MM-DD HH24:MI:SS') }} AS return_date,
        {{ clean_string('return_reason') }} AS return_reason,
        return_quantity::INT AS return_quantity,
        refund_amount::NUMERIC(12,2) AS refund_amount,
        {{ clean_string('return_status') }} AS return_status,
        _extracted_at,
        _file_name,
        md5(concat_ws('||', return_id::TEXT)) AS dbt_scd_id
    FROM raw
),

deduped AS (
    {{ dedup_rows('cleaned', ['return_id'], '_extracted_at DESC') }}
),

final AS (
    SELECT
        return_id,
        order_id,
        product_id,
        customer_id,
        return_date,
        return_reason,
        return_quantity,
        refund_amount,
        return_status,
        _extracted_at,
        _file_name,
        dbt_scd_id
    FROM deduped
)

SELECT * FROM final
