CREATE TABLE IF NOT EXISTS retail_staging.raw_customers (
    customer_id         TEXT,
    customer_unique_id  TEXT,
    customer_zip_code   TEXT,
    customer_city       TEXT,
    customer_state      TEXT,
    customer_segment    TEXT,
    registration_date   TEXT,
    first_name          TEXT,
    last_name           TEXT,
    email               TEXT,
    phone               TEXT,
    birth_date          TEXT,
    gender              TEXT,
    income_bracket      TEXT,
    _extracted_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _file_name          TEXT,
    _row_id             SERIAL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS retail_staging.raw_products (
    product_id              TEXT,
    product_category        TEXT,
    product_name_length     TEXT,
    product_description_len TEXT,
    product_photos_qty      TEXT,
    product_weight_g        TEXT,
    product_length_cm       TEXT,
    product_height_cm       TEXT,
    product_width_cm        TEXT,
    product_status          TEXT,
    supplier_id             TEXT,
    unit_cost               TEXT,
    unit_price              TEXT,
    _extracted_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _file_name              TEXT,
    _row_id                 SERIAL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS retail_staging.raw_orders (
    order_id            TEXT,
    customer_id         TEXT,
    order_status        TEXT,
    order_purchase_ts   TEXT,
    order_approved_ts   TEXT,
    order_delivered_carrier_ts TEXT,
    order_delivered_customer_ts TEXT,
    order_estimated_delivery_ts TEXT,
    payment_type        TEXT,
    payment_installments TEXT,
    payment_value       TEXT,
    freight_value       TEXT,
    _extracted_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _file_name          TEXT,
    _row_id             SERIAL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS retail_staging.raw_order_items (
    order_id            TEXT,
    order_item_id       TEXT,
    product_id          TEXT,
    seller_id           TEXT,
    shipping_limit_ts   TEXT,
    price               TEXT,
    freight_value       TEXT,
    quantity            TEXT,
    _extracted_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _file_name          TEXT,
    _row_id             SERIAL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS retail_staging.raw_payments (
    payment_id          TEXT,
    order_id            TEXT,
    payment_sequential  TEXT,
    payment_type        TEXT,
    payment_installments TEXT,
    payment_value       TEXT,
    payment_status      TEXT,
    payment_date        TEXT,
    _extracted_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _file_name          TEXT,
    _row_id             SERIAL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS retail_staging.raw_inventory (
    inventory_id        TEXT,
    product_id          TEXT,
    warehouse_id        TEXT,
    quantity_on_hand    TEXT,
    quantity_reserved   TEXT,
    reorder_point       TEXT,
    reorder_quantity    TEXT,
    last_count_date     TEXT,
    _extracted_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _file_name          TEXT,
    _row_id             SERIAL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS retail_staging.raw_suppliers (
    supplier_id         TEXT,
    supplier_name       TEXT,
    supplier_city       TEXT,
    supplier_state      TEXT,
    supplier_zip_code   TEXT,
    supplier_country    TEXT,
    supplier_contact    TEXT,
    supplier_email      TEXT,
    supplier_phone      TEXT,
    supplier_status     TEXT,
    contract_start_date TEXT,
    contract_end_date   TEXT,
    _extracted_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _file_name          TEXT,
    _row_id             SERIAL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS retail_staging.raw_returns (
    return_id           TEXT,
    order_id            TEXT,
    product_id          TEXT,
    customer_id         TEXT,
    return_date         TEXT,
    return_reason       TEXT,
    return_quantity     TEXT,
    refund_amount       TEXT,
    return_status       TEXT,
    _extracted_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _file_name          TEXT,
    _row_id             SERIAL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS retail_staging.raw_reviews (
    review_id           TEXT,
    order_id            TEXT,
    review_score        TEXT,
    review_comment_title TEXT,
    review_comment_msg  TEXT,
    review_creation_ts  TEXT,
    review_answer_ts    TEXT,
    _extracted_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _file_name          TEXT,
    _row_id             SERIAL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS retail_staging.raw_sellers (
    seller_id           TEXT,
    seller_zip_code     TEXT,
    seller_city         TEXT,
    seller_state        TEXT,
    seller_segment      TEXT,
    seller_name         TEXT,
    seller_email        TEXT,
    seller_phone        TEXT,
    _extracted_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _file_name          TEXT,
    _row_id             SERIAL PRIMARY KEY
);

CREATE INDEX IF NOT EXISTS idx_raw_orders_customer ON retail_staging.raw_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_raw_order_items_order ON retail_staging.raw_order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_raw_order_items_product ON retail_staging.raw_order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_raw_payments_order ON retail_staging.raw_payments(order_id);
CREATE INDEX IF NOT EXISTS idx_raw_returns_order ON retail_staging.raw_returns(order_id);
CREATE INDEX IF NOT EXISTS idx_raw_inventory_product ON retail_staging.raw_inventory(product_id);
