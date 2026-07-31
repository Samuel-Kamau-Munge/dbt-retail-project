{{ config(materialized='table', schema='retail_analytics') }}

with daily_base as (
    select
        d.date_actual as sale_date,
        p.product_category,
        o.order_id,
        o.customer_id,
        oi.product_id,
        oi.quantity,
        oi.line_total,
        oi.line_freight_total,
        oi.line_gross_total
    from {{ ref('fct_order_items') }} oi
    inner join {{ ref('fct_orders') }} o
        on oi.order_id = o.order_id
    inner join {{ ref('dim_date') }} d
        on o.order_date_key = d.date_key
    inner join {{ ref('dim_products') }} p
        on oi.product_key = p.product_key
)

select
    sale_date,
    product_category,
    count(distinct order_id) as total_orders,
    sum(quantity) as total_items_sold,
    sum(line_total) as total_revenue,
    sum(line_freight_total) as total_freight,
    sum(line_gross_total) as total_gross_value,
    sum(line_total)::numeric / nullif(count(distinct order_id), 0) as avg_order_value,
    sum(quantity)::numeric / nullif(count(distinct order_id), 0) as avg_items_per_order,
    count(distinct product_id) as total_products_sold,
    count(distinct customer_id) as total_unique_customers,
    current_timestamp as _loaded_at
from daily_base
group by sale_date, product_category
