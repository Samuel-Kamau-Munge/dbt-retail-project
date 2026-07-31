{{ config(materialized='view', schema='retail_analytics') }}

SELECT
    mk.year_num,
    mk.month_num,
    mk.month_name,
    to_char(make_date(mk.year_num, mk.month_num, 1), 'MMYYYY') AS mmyyyy,
    make_date(mk.year_num, mk.month_num, 1) AS month_start_date,
    mk.total_revenue,
    mk.total_cost,
    mk.gross_profit,
    mk.gross_margin_pct,
    mk.total_orders,
    mk.total_items,
    mk.avg_order_value,
    mk.total_customers,
    mk.new_customers,
    mk.avg_delivery_time_days,
    mk.delivered_rate,
    mk.canceled_rate,
    mk.on_time_rate,
    mk.total_freight_cost
FROM {{ ref('monthly_kpi') }} mk
ORDER BY mk.year_num, mk.month_num
