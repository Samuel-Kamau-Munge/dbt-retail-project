{{ config(materialized='table', schema='retail_analytics') }}

with inventory_snapshots as (
    select
        inv.product_key,
        inv.quantity_on_hand,
        inv.quantity_available,
        inv.is_low_stock,
        inv.reorder_point,
        inv.reorder_quantity,
        inv.snapshot_date,
        last_value(inv.quantity_on_hand) over (
            partition by inv.product_key
            order by inv.snapshot_date
            rows between unbounded preceding and unbounded following
        ) as latest_quantity_on_hand,
        last_value(inv.is_low_stock) over (
            partition by inv.product_key
            order by inv.snapshot_date
            rows between unbounded preceding and unbounded following
        ) as latest_is_low_stock
    from {{ ref('fct_inventory') }} inv
),

units_sold as (
    select
        product_key,
        sum(quantity) as total_units_sold
    from {{ ref('fct_order_items') }}
    group by product_key
)

select
    p.product_key,
    p.product_id,
    p.product_category,
    p.supplier_name,
    p.unit_cost,
    p.unit_price,
    round(avg(iv.quantity_on_hand)::numeric, 2) as avg_quantity_on_hand,
    round(avg(iv.quantity_available)::numeric, 2) as avg_quantity_available,
    coalesce(us.total_units_sold, 0) as total_units_sold,
    case
        when avg(iv.quantity_on_hand) > 0
        then round(coalesce(us.total_units_sold, 0)::numeric / avg(iv.quantity_on_hand), 2)
        else 0
    end as turnover_ratio,
    case
        when (
            case
                when avg(iv.quantity_on_hand) > 0
                then coalesce(us.total_units_sold, 0)::numeric / avg(iv.quantity_on_hand)
                else 0
            end
        ) > 0
        then round(365.0 / (
            case
                when avg(iv.quantity_on_hand) > 0
                then coalesce(us.total_units_sold, 0)::numeric / avg(iv.quantity_on_hand)
                else 0
            end
        ), 1)
    end as turnover_days,
    (
        select latest_quantity_on_hand
        from inventory_snapshots iv2
        where iv2.product_key = p.product_key
        limit 1
    ) * p.unit_cost as current_stock_value,
    (
        select latest_quantity_on_hand
        from inventory_snapshots iv2
        where iv2.product_key = p.product_key
        limit 1
    ) * p.unit_price as current_revenue_value,
    case
        when (
            case
                when (
                    case
                        when avg(iv.quantity_on_hand) > 0
                        then coalesce(us.total_units_sold, 0)::numeric / avg(iv.quantity_on_hand)
                        else 0
                    end
                ) > 0
                then round(365.0 / (
                    case
                        when avg(iv.quantity_on_hand) > 0
                        then coalesce(us.total_units_sold, 0)::numeric / avg(iv.quantity_on_hand)
                        else 0
                    end
                ), 1)
            end
        ) > 90 then true
        when (
            case
                when avg(iv.quantity_on_hand) > 0
                then coalesce(us.total_units_sold, 0)::numeric / avg(iv.quantity_on_hand)
                else 0
            end
        ) < 4 then true
        else false
    end as is_overstocked,
    case
        when (
            select latest_is_low_stock
            from inventory_snapshots iv2
            where iv2.product_key = p.product_key
            limit 1
        ) = true then true
        else false
    end as is_understocked,
    (
        select reorder_point
        from inventory_snapshots iv2
        where iv2.product_key = p.product_key
        order by iv2.snapshot_date desc
        limit 1
    ) as reorder_point,
    (
        select reorder_quantity
        from inventory_snapshots iv2
        where iv2.product_key = p.product_key
        order by iv2.snapshot_date desc
        limit 1
    ) as reorder_quantity,
    current_timestamp as _loaded_at
from {{ ref('dim_products') }} p
inner join inventory_snapshots iv
    on p.product_key = iv.product_key
left join units_sold us
    on p.product_key = us.product_key
group by
    p.product_key,
    p.product_id,
    p.product_category,
    p.supplier_name,
    p.unit_cost,
    p.unit_price,
    us.total_units_sold
