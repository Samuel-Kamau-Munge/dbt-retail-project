WITH order_totals AS (
    SELECT
        order_id,
        SUM(line_gross_total) AS order_gross_total
    FROM {{ ref('fct_order_items') }}
    GROUP BY order_id
)
SELECT
    r.return_id,
    r.order_id,
    r.product_id,
    r.return_quantity,
    r.refund_amount,
    o.order_gross_total
FROM {{ ref('stg_returns') }} r
JOIN order_totals o ON r.order_id = o.order_id
WHERE r.refund_amount > o.order_gross_total
  AND r.refund_amount IS NOT NULL
  AND o.order_gross_total > 0
