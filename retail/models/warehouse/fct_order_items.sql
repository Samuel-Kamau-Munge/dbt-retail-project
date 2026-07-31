{{ config(materialized='table', schema='retail_warehouse') }}

WITH order_items_source AS (
    SELECT
        order_id,
        order_item_id::INT AS order_item_id,
        product_id,
        seller_id,
        shipping_limit_ts::TIMESTAMP AS shipping_limit_ts,
        price::NUMERIC AS price,
        freight_value::NUMERIC AS freight_value,
        quantity::INT AS quantity,
        _extracted_at
    FROM {{ ref('stg_order_items') }}
),

orders_fct AS (
    SELECT
        order_key,
        order_id
    FROM {{ ref('fct_orders') }}
),

products_dim AS (
    SELECT
        product_key,
        product_id
    FROM {{ ref('dim_products') }}
),

date_dim AS (
    SELECT
        date_key,
        date_actual
    FROM {{ ref('dim_date') }}
),

joined AS (
    SELECT
        oi.order_id,
        oi.order_item_id,
        oi.product_id,
        oi.seller_id,
        oi.shipping_limit_ts,
        oi.price,
        oi.freight_value,
        oi.quantity,
        oi._extracted_at,
        o.order_key,
        p.product_key,
        dd.date_key AS ship_date_key
    FROM order_items_source oi
    LEFT JOIN orders_fct o ON oi.order_id = o.order_id
    LEFT JOIN products_dim p ON oi.product_id = p.product_id
    LEFT JOIN date_dim dd ON oi.shipping_limit_ts::DATE = dd.date_actual
),

transformed AS (
    SELECT
        md5(order_id::TEXT || '|' || order_item_id::TEXT || '|' || product_id::TEXT) AS order_item_key,
        order_key,
        order_id,
        order_item_id,
        product_key,
        product_id,
        seller_id,
        shipping_limit_ts,
        ship_date_key,
        price,
        freight_value,
        quantity,
        (price * quantity) AS line_total,
        (freight_value * quantity) AS line_freight_total,
        ((price + freight_value) * quantity) AS line_gross_total,
        _extracted_at
    FROM joined
)

SELECT * FROM transformed
