WITH order_item_totals AS (
    SELECT
        order_id,
        SUM(line_total) AS items_total,
        SUM(line_freight_total) AS items_freight_total,
        SUM(line_gross_total) AS items_gross_total,
        COUNT(*) AS num_items
    FROM {{ ref('fct_order_items') }}
    GROUP BY order_id
),
order_header AS (
    SELECT
        order_id,
        payment_value,
        freight_value,
        total_order_value
    FROM {{ ref('fct_orders') }}
    WHERE payment_value IS NOT NULL
)
SELECT
    o.order_id,
    h.payment_value,
    o.items_total,
    ABS(h.payment_value - o.items_total) AS diff_amount,
    CASE WHEN h.payment_value > 0
         THEN ABS(h.payment_value - o.items_total) / h.payment_value * 100
         ELSE 999 END AS diff_pct
FROM order_item_totals o
JOIN order_header h ON o.order_id = h.order_id
WHERE ABS(h.payment_value - o.items_total) > GREATEST(h.payment_value * 0.05, 1.00)
  AND h.payment_value > 0
