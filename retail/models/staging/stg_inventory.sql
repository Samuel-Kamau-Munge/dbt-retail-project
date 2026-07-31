{{ config(materialized='view', schema='retail_staging') }}

WITH raw AS (
    SELECT * FROM {{ source('retail_raw', 'raw_inventory') }}
),

cleaned AS (
    SELECT
        inventory_id::INT AS inventory_id,
        product_id::INT AS product_id,
        warehouse_id,
        quantity_on_hand::INT AS quantity_on_hand,
        quantity_reserved::INT AS quantity_reserved,
        reorder_point::INT AS reorder_point,
        reorder_quantity::INT AS reorder_quantity,
        {{ clean_date('last_count_date', 'YYYY-MM-DD') }} AS last_count_date,
        _extracted_at,
        _file_name,
        md5(concat_ws('||', inventory_id::TEXT)) AS dbt_scd_id
    FROM raw
),

deduped AS (
    {{ dedup_rows('cleaned', ['inventory_id'], '_extracted_at DESC') }}
),

final AS (
    SELECT
        inventory_id,
        product_id,
        warehouse_id,
        quantity_on_hand,
        quantity_reserved,
        reorder_point,
        reorder_quantity,
        last_count_date,
        _extracted_at,
        _file_name,
        dbt_scd_id
    FROM deduped
)

SELECT * FROM final
