{{ config(materialized='table', schema='retail_analytics') }}

with customer_first_order as (
    select
        customer_id,
        min(date_trunc('month', order_purchase_ts)) as first_order_month
    from {{ ref('fct_orders') }}
    group by customer_id
),

monthly_base as (
    select
        d.year_actual as year_num,
        d.month_actual as month_num,
        d.month_name,
        date_trunc('month', o.order_purchase_ts) as order_month,
        o.order_id,
        o.customer_id,
        o.order_status,
        o.delivery_time_days,
        case
            when o.order_delivered_customer_ts is not null
                and o.order_estimated_delivery_ts is not null
                and o.order_delivered_customer_ts <= o.order_estimated_delivery_ts
            then 1 else 0
        end as is_on_time,
        p.unit_cost,
        oi.quantity,
        oi.line_total,
        oi.line_freight_total
    from {{ ref('fct_orders') }} o
    inner join {{ ref('fct_order_items') }} oi
        on o.order_id = oi.order_id
    inner join {{ ref('dim_date') }} d
        on o.order_date_key = d.date_key
    inner join {{ ref('dim_products') }} p
        on oi.product_key = p.product_key
    left join customer_first_order cfo
        on o.customer_id = cfo.customer_id
)

select
    year_num,
    month_num,
    month_name,
    sum(line_total) as total_revenue,
    sum(unit_cost * quantity) as total_cost,
    sum(line_total) - sum(unit_cost * quantity) as gross_profit,
    round(
        (sum(line_total) - sum(unit_cost * quantity))::numeric
        / nullif(sum(line_total), 0) * 100, 2
    ) as gross_margin_pct,
    count(distinct order_id) as total_orders,
    sum(quantity) as total_items,
    sum(line_total)::numeric / nullif(count(distinct order_id), 0) as avg_order_value,
    count(distinct customer_id) as total_customers,
    count(distinct case
        when cfo.first_order_month = date_trunc('month', mb.order_month)
        then mb.customer_id
    end) as new_customers,
    round(
        (count(distinct case
            when exists (
                select 1 from {{ ref('fct_orders') }} o2
                where o2.customer_id = mb.customer_id
                and o2.order_purchase_ts between
                    date_trunc('month', mb.order_month) - interval '3 months'
                    and date_trunc('month', mb.order_month) - interval '1 day'
            )
            and not exists (
                select 1 from {{ ref('fct_orders') }} o3
                where o3.customer_id = mb.customer_id
                and o3.order_purchase_ts >= date_trunc('month', mb.order_month)
            )
            then mb.customer_id
        end)::numeric / nullif(count(distinct mb.customer_id), 0) * 100, 2
    ) as customer_churn_rate,
    round(avg(delivery_time_days)::numeric, 2) as avg_delivery_time_days,
    round(
        count(case when order_status = 'delivered' then 1 end)::numeric
        / nullif(count(*), 0) * 100, 2
    ) as delivered_rate,
    round(
        count(case when order_status = 'canceled' then 1 end)::numeric
        / nullif(count(*), 0) * 100, 2
    ) as canceled_rate,
    round(
        sum(is_on_time)::numeric
        / nullif(count(case when order_status = 'delivered' then 1 end), 0) * 100, 2
    ) as on_time_rate,
    sum(line_freight_total) as total_freight_cost,
    current_timestamp as _loaded_at
from monthly_base mb
left join customer_first_order cfo
    on mb.customer_id = cfo.customer_id
group by year_num, month_num, month_name
order by year_num, month_num
