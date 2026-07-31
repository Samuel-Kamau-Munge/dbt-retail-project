{{ config(materialized='view', schema='retail_staging') }}

WITH raw AS (
    SELECT * FROM {{ source('retail_raw', 'raw_order_items') }}
),

cleaned AS (
    SELECT
        order_id::INT AS order_id,
        order_item_id::INT AS order_item_id,
        product_id::INT AS product_id,
        seller_id::INT AS seller_id,
        {{ clean_timestamp('shipping_limit_ts') }} AS shipping_limit_ts,
        price::NUMERIC(12,2) AS price,
        freight_value::NUMERIC(12,2) AS freight_value,
        quantity::INT AS quantity,
        _extracted_at,
        _file_name,
        md5(concat_ws('||', order_id::TEXT, order_item_id::TEXT, product_id::TEXT)) AS dbt_scd_id
    FROM raw
),

deduped AS (
    {{ dedup_rows('cleaned', ['order_id', 'order_item_id', 'product_id'], '_extracted_at DESC') }}
),

final AS (
    SELECT
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_ts,
        price,
        freight_value,
        quantity,
        _extracted_at,
        _file_name,
        dbt_scd_id
    FROM deduped
)

SELECT * FROM final
