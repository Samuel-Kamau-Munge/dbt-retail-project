SELECT
    order_id,
    customer_id,
    order_purchase_ts,
    order_delivered_customer_ts,
    EXTRACT(EPOCH FROM (order_delivered_customer_ts - order_purchase_ts)) AS delta_seconds
FROM {{ ref('fct_orders') }}
WHERE is_delivered = TRUE
  AND order_delivered_customer_ts IS NOT NULL
  AND order_purchase_ts IS NOT NULL
  AND order_delivered_customer_ts < order_purchase_ts
