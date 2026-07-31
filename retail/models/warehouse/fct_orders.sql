{{ config(materialized='table', schema='retail_warehouse') }}

WITH orders_source AS (
    SELECT
        order_id,
        customer_id,
        order_status,
        order_purchase_ts::TIMESTAMP AS order_purchase_ts,
        order_approved_ts::TIMESTAMP AS order_approved_ts,
        order_delivered_carrier_ts::TIMESTAMP AS order_delivered_carrier_ts,
        order_delivered_customer_ts::TIMESTAMP AS order_delivered_customer_ts,
        order_estimated_delivery_ts::TIMESTAMP AS order_estimated_delivery_ts,
        payment_type,
        payment_installments::INT AS payment_installments,
        payment_value::NUMERIC AS payment_value,
        freight_value::NUMERIC AS freight_value,
        _extracted_at
    FROM {{ ref('stg_orders') }}
),

customers_dim AS (
    SELECT
        customer_key,
        customer_id
    FROM {{ ref('dim_customers') }}
),

date_dim AS (
    SELECT
        date_key,
        date_actual
    FROM {{ ref('dim_date') }}
),

joined AS (
    SELECT
        o.order_id,
        c.customer_key,
        dd.date_key AS order_date_key,
        o.customer_id,
        o.order_status,
        o.order_purchase_ts,
        o.order_approved_ts,
        o.order_delivered_carrier_ts,
        o.order_delivered_customer_ts,
        o.order_estimated_delivery_ts,
        o.payment_type,
        o.payment_installments,
        o.payment_value,
        o.freight_value,
        o._extracted_at
    FROM orders_source o
    LEFT JOIN customers_dim c ON o.customer_id = c.customer_id
    LEFT JOIN date_dim dd ON o.order_purchase_ts::DATE = dd.date_actual
),

transformed AS (
    SELECT
        md5(order_id::TEXT) AS order_key,
        order_id,
        customer_key,
        order_date_key,
        customer_id,
        order_status,
        order_purchase_ts,
        order_approved_ts,
        order_delivered_carrier_ts,
        order_delivered_customer_ts,
        order_estimated_delivery_ts,
        payment_type,
        payment_installments,
        payment_value,
        freight_value,
        (payment_value + freight_value) AS total_order_value,
        CASE
            WHEN order_delivered_customer_ts IS NOT NULL AND order_purchase_ts IS NOT NULL
            THEN EXTRACT(DAY FROM (order_delivered_customer_ts - order_purchase_ts))::INT
            ELSE NULL
        END AS delivery_time_days,
        CASE
            WHEN order_status ILIKE '%delivered%' THEN TRUE::BOOLEAN
            ELSE FALSE::BOOLEAN
        END AS is_delivered,
        CASE
            WHEN order_status ILIKE '%cancel%' THEN TRUE::BOOLEAN
            ELSE FALSE::BOOLEAN
        END AS is_canceled,
        _extracted_at
    FROM joined
)

SELECT * FROM transformed
