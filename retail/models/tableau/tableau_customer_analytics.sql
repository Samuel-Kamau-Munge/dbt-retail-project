{{ config(materialized='view', schema='retail_analytics') }}

SELECT
    clv.customer_key,
    clv.customer_id,
    clv.customer_name,
    clv.customer_segment,
    clv.income_bracket,
    clv.customer_city,
    clv.customer_state,
    clv.first_order_date,
    clv.last_order_date,
    clv.customer_tenure_days,
    clv.total_orders,
    clv.total_items,
    clv.total_spent,
    clv.total_freight_paid,
    clv.avg_order_value,
    clv.avg_days_between_orders,
    clv.order_frequency_segment,
    clv.clv_score,
    clv.is_active_recent,
    CASE NTILE(4) OVER (ORDER BY clv.clv_score)
        WHEN 4 THEN 'Platinum'
        WHEN 3 THEN 'Gold'
        WHEN 2 THEN 'Silver'
        WHEN 1 THEN 'Bronze'
    END AS clv_segment,
    CASE
        WHEN clv.customer_tenure_days > 365 THEN 'Long-Term'
        WHEN clv.customer_tenure_days > 90 THEN 'Mid-Term'
        ELSE 'New'
    END AS tenure_segment
FROM {{ ref('customer_lifetime_value') }} clv
