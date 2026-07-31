{{ config(materialized='table', schema='retail_warehouse') }}

WITH inventory_source AS (
    SELECT
        inventory_id,
        product_id,
        warehouse_id,
        quantity_on_hand::INT AS quantity_on_hand,
        quantity_reserved::INT AS quantity_reserved,
        reorder_point::INT AS reorder_point,
        reorder_quantity::INT AS reorder_quantity,
        last_count_date::DATE AS last_count_date,
        _extracted_at
    FROM {{ ref('stg_inventory') }}
),

products_dim AS (
    SELECT
        product_key,
        product_id
    FROM {{ ref('dim_products') }}
),

date_dim AS (
    SELECT
        date_key,
        date_actual
    FROM {{ ref('dim_date') }}
),

joined AS (
    SELECT
        i.inventory_id,
        i.product_id,
        i.warehouse_id,
        i.quantity_on_hand,
        i.quantity_reserved,
        i.reorder_point,
        i.reorder_quantity,
        i.last_count_date,
        i._extracted_at,
        p.product_key,
        dd.date_key AS count_date_key
    FROM inventory_source i
    LEFT JOIN products_dim p ON i.product_id = p.product_id
    LEFT JOIN date_dim dd ON i.last_count_date = dd.date_actual
),

transformed AS (
    SELECT
        md5(inventory_id::TEXT) AS inventory_key,
        inventory_id,
        product_key,
        product_id,
        warehouse_id,
        count_date_key,
        quantity_on_hand,
        quantity_reserved,
        (quantity_on_hand - quantity_reserved) AS quantity_available,
        reorder_point,
        reorder_quantity,
        CASE
            WHEN quantity_on_hand <= reorder_point THEN TRUE::BOOLEAN
            ELSE FALSE::BOOLEAN
        END AS is_low_stock,
        last_count_date,
        _extracted_at
    FROM joined
)

SELECT * FROM transformed
