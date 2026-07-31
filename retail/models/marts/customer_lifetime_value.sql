{{ config(materialized='table', schema='retail_analytics') }}

with customer_orders as (
    select
        c.customer_key,
        c.customer_id,
        c.first_name,
        c.last_name,
        c.customer_segment,
        c.income_bracket,
        c.customer_city,
        c.customer_state,
        o.order_id,
        o.order_purchase_ts,
        oi.quantity,
        oi.line_total,
        oi.line_freight_total
    from {{ ref('fct_orders') }} o
    inner join {{ ref('dim_customers') }} c
        on o.customer_key = c.customer_key
    inner join {{ ref('fct_order_items') }} oi
        on o.order_id = oi.order_id
)

select
    customer_key,
    customer_id,
    first_name || ' ' || last_name as customer_name,
    customer_segment,
    income_bracket,
    customer_city,
    customer_state,
    min(order_purchase_ts::date) as first_order_date,
    max(order_purchase_ts::date) as last_order_date,
    (max(order_purchase_ts::date) - min(order_purchase_ts::date)) as customer_tenure_days,
    count(distinct order_id) as total_orders,
    sum(quantity) as total_items,
    sum(line_total) as total_spent,
    sum(line_freight_total) as total_freight_paid,
    sum(line_total)::numeric / nullif(count(distinct order_id), 0) as avg_order_value,
    case
        when count(distinct order_id) > 1
        then (max(order_purchase_ts::date) - min(order_purchase_ts::date))::numeric
             / (count(distinct order_id) - 1)
    end as avg_days_between_orders,
    case
        when count(distinct order_id) >= 10 then 'VIP'
        when count(distinct order_id) >= 5 then 'Loyal'
        when count(distinct order_id) >= 2 then 'Repeat'
        else 'One-Time'
    end as order_frequency_segment,
    sum(line_total) * (1 + coalesce(0.1 * count(distinct order_id), 0)) as clv_score,
    case
        when max(order_purchase_ts::date) >= current_date - interval '90 days'
        then true else false
    end as is_active_recent,
    current_timestamp as _loaded_at
from customer_orders
group by
    customer_key,
    customer_id,
    first_name,
    last_name,
    customer_segment,
    income_bracket,
    customer_city,
    customer_state
