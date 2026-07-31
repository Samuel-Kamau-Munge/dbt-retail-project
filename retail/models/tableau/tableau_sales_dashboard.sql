{{ config(materialized='view', schema='retail_analytics') }}

SELECT
    ds.sale_date,
    dd.day_name,
    dd.day_of_week,
    dd.weekend_indr,
    dd.month_name,
    dd.year_actual,
    dd.quarter_name,
    ds.product_category,
    ds.total_orders,
    ds.total_items_sold,
    ds.total_revenue,
    ds.total_freight,
    ds.total_gross_value,
    ds.avg_order_value,
    ds.avg_items_per_order,
    ds.total_products_sold,
    ds.total_unique_customers
FROM {{ ref('daily_sales') }} ds
LEFT JOIN {{ ref('dim_date') }} dd
    ON ds.sale_date = dd.date_actual
