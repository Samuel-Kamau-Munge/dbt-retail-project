{{ config(materialized='table', schema='retail_warehouse') }}

WITH products_source AS (
    SELECT
        product_id,
        product_category,
        product_name_length::INT AS product_name_length,
        product_description_len::INT AS product_description_len,
        product_photos_qty::INT AS product_photos_qty,
        product_weight_g::NUMERIC AS product_weight_g,
        product_length_cm::NUMERIC AS product_length_cm,
        product_height_cm::NUMERIC AS product_height_cm,
        product_width_cm::NUMERIC AS product_width_cm,
        product_status,
        supplier_id,
        unit_cost::NUMERIC AS unit_cost,
        unit_price::NUMERIC AS unit_price,
        _extracted_at
    FROM {{ ref('stg_products') }}
),

suppliers_source AS (
    SELECT
        supplier_id,
        supplier_name,
        supplier_city,
        supplier_state,
        supplier_country
    FROM {{ ref('stg_suppliers') }}
),

joined AS (
    SELECT
        p.product_id,
        p.product_category,
        p.product_name_length,
        p.product_description_len,
        p.product_photos_qty,
        p.product_weight_g,
        p.product_length_cm,
        p.product_height_cm,
        p.product_width_cm,
        p.product_status,
        p.supplier_id,
        s.supplier_name,
        s.supplier_city,
        s.supplier_state,
        s.supplier_country,
        p.unit_cost,
        p.unit_price
    FROM products_source p
    LEFT JOIN suppliers_source s ON p.supplier_id = s.supplier_id
),

transformed AS (
    SELECT
        md5(product_id::TEXT) AS product_key,
        product_id,
        product_category,
        product_name_length,
        product_description_len,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm,
        product_status,
        supplier_id,
        supplier_name,
        supplier_city,
        supplier_state,
        supplier_country,
        unit_cost,
        unit_price,
        CASE
            WHEN unit_price > 0
            THEN ROUND((unit_price - unit_cost) / unit_price * 100, 2)
            ELSE 0
        END AS profit_margin_pct,
        CASE
            WHEN product_length_cm IS NOT NULL
                AND product_height_cm IS NOT NULL
                AND product_width_cm IS NOT NULL
            THEN (product_length_cm * product_height_cm * product_width_cm)::NUMERIC
            ELSE NULL
        END AS product_volume_cm3,
        md5(product_id::TEXT) AS dbt_scd_id
    FROM joined
)

SELECT * FROM transformed
