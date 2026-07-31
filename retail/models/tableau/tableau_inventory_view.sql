{{ config(materialized='view', schema='retail_analytics') }}

SELECT
    it.product_key,
    dp.product_id,
    dp.product_category,
    dp.supplier_name,
    dp.unit_cost,
    dp.unit_price,
    dp.profit_margin_pct,
    dp.product_status,
    it.avg_quantity_on_hand,
    it.avg_quantity_available,
    it.total_units_sold,
    it.turnover_ratio,
    it.turnover_days,
    it.current_stock_value,
    it.current_revenue_value,
    it.is_overstocked,
    it.is_understocked,
    it.reorder_point,
    it.reorder_quantity,
    CASE
        WHEN it.is_overstocked THEN 'Overstocked'
        WHEN it.is_understocked THEN 'Understocked'
        ELSE 'Optimal'
    END AS inventory_segment
FROM {{ ref('inventory_turnover') }} it
LEFT JOIN {{ ref('dim_products') }} dp
    ON it.product_key = dp.product_key
