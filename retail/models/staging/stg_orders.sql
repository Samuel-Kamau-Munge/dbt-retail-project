{{ config(materialized='view', schema='retail_staging') }}

WITH raw AS (
    SELECT * FROM {{ source('retail_raw', 'raw_orders') }}
),

cleaned AS (
    SELECT
        order_id::INT AS order_id,
        customer_id::INT AS customer_id,
        {{ clean_string('order_status') }} AS order_status,
        {{ clean_timestamp('order_purchase_ts') }} AS order_purchase_ts,
        {{ clean_timestamp('order_approved_ts') }} AS order_approved_ts,
        {{ clean_timestamp('order_delivered_carrier_ts') }} AS order_delivered_carrier_ts,
        {{ clean_timestamp('order_delivered_customer_ts') }} AS order_delivered_customer_ts,
        {{ clean_timestamp('order_estimated_delivery_ts') }} AS order_estimated_delivery_ts,
        {{ clean_string('payment_type') }} AS payment_type,
        payment_installments::INT AS payment_installments,
        payment_value::NUMERIC(12,2) AS payment_value,
        freight_value::NUMERIC(12,2) AS freight_value,
        _extracted_at,
        _file_name,
        md5(concat_ws('||', order_id::TEXT)) AS dbt_scd_id
    FROM raw
),

deduped AS (
    {{ dedup_rows('cleaned', ['order_id'], '_extracted_at DESC') }}
),

final AS (
    SELECT
        order_id,
        customer_id,
        order_status,
        order_purchase_ts,
        order_approved_ts,
        order_delivered_carrier_ts,
        order_delivered_customer_ts,
        order_estimated_delivery_ts,
        payment_type,
        payment_installments,
        payment_value,
        freight_value,
        _extracted_at,
        _file_name,
        dbt_scd_id
    FROM deduped
)

SELECT * FROM final
