{{ config(materialized='view', schema='retail_staging') }}

WITH raw AS (
    SELECT * FROM {{ source('retail_raw', 'raw_products') }}
),

cleaned AS (
    SELECT
        product_id::INT AS product_id,
        supplier_id::INT AS supplier_id,
        {{ clean_string('product_category') }} AS product_category,
        product_name_length::INT AS product_name_length,
        product_description_len::INT AS product_description_len,
        product_photos_qty::INT AS product_photos_qty,
        product_weight_g::NUMERIC(10,2) AS product_weight_g,
        product_length_cm::NUMERIC(10,2) AS product_length_cm,
        product_height_cm::NUMERIC(10,2) AS product_height_cm,
        product_width_cm::NUMERIC(10,2) AS product_width_cm,
        {{ clean_string('product_status') }} AS product_status,
        unit_cost::NUMERIC(12,2) AS unit_cost,
        unit_price::NUMERIC(12,2) AS unit_price,
        _extracted_at,
        _file_name,
        md5(concat_ws('||', product_id::TEXT)) AS dbt_scd_id
    FROM raw
),

deduped AS (
    {{ dedup_rows('cleaned', ['product_id'], '_extracted_at DESC') }}
),

final AS (
    SELECT
        product_id,
        supplier_id,
        product_category,
        product_name_length,
        product_description_len,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm,
        product_status,
        unit_cost,
        unit_price,
        _extracted_at,
        _file_name,
        dbt_scd_id
    FROM deduped
)

SELECT * FROM final
