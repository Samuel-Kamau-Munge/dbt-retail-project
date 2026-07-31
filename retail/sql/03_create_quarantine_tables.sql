CREATE TABLE IF NOT EXISTS retail_quarantine.validation_log (
    quarantine_id       SERIAL PRIMARY KEY,
    source_table        VARCHAR(100) NOT NULL,
    target_table        VARCHAR(100) NOT NULL,
    row_data            JSONB NOT NULL,
    validation_type     VARCHAR(50) NOT NULL,
    validation_rule     VARCHAR(200) NOT NULL,
    validation_message  TEXT,
    severity            VARCHAR(20) DEFAULT 'ERROR',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    batch_id            VARCHAR(50),
    _extracted_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS retail_quarantine.quarantine_customers (
    LIKE retail_staging.raw_customers INCLUDING ALL,
    quarantine_reason   TEXT,
    quarantine_rule     VARCHAR(200),
    quarantine_ts       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    batch_id            VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS retail_quarantine.quarantine_orders (
    LIKE retail_staging.raw_orders INCLUDING ALL,
    quarantine_reason   TEXT,
    quarantine_rule     VARCHAR(200),
    quarantine_ts       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    batch_id            VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS retail_quarantine.quarantine_products (
    LIKE retail_staging.raw_products INCLUDING ALL,
    quarantine_reason   TEXT,
    quarantine_rule     VARCHAR(200),
    quarantine_ts       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    batch_id            VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS retail_quarantine.quarantine_order_items (
    LIKE retail_staging.raw_order_items INCLUDING ALL,
    quarantine_reason   TEXT,
    quarantine_rule     VARCHAR(200),
    quarantine_ts       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    batch_id            VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS retail_quarantine.quarantine_payments (
    LIKE retail_staging.raw_payments INCLUDING ALL,
    quarantine_reason   TEXT,
    quarantine_rule     VARCHAR(200),
    quarantine_ts       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    batch_id            VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS retail_quarantine.quarantine_inventory (
    LIKE retail_staging.raw_inventory INCLUDING ALL,
    quarantine_reason   TEXT,
    quarantine_rule     VARCHAR(200),
    quarantine_ts       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    batch_id            VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS retail_quarantine.quarantine_returns (
    LIKE retail_staging.raw_returns INCLUDING ALL,
    quarantine_reason   TEXT,
    quarantine_rule     VARCHAR(200),
    quarantine_ts       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    batch_id            VARCHAR(50)
);

CREATE INDEX IF NOT EXISTS idx_quarantine_log_source ON retail_quarantine.validation_log(source_table);
CREATE INDEX IF NOT EXISTS idx_quarantine_log_created ON retail_quarantine.validation_log(created_at);
CREATE INDEX IF NOT EXISTS idx_quarantine_log_batch ON retail_quarantine.validation_log(batch_id);
