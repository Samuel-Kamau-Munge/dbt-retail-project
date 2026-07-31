SELECT
    inventory_id,
    product_id,
    warehouse_id,
    quantity_on_hand,
    quantity_reserved,
    quantity_available,
    reorder_point,
    is_low_stock
FROM {{ ref('fct_inventory') }}
WHERE quantity_reserved > quantity_on_hand
