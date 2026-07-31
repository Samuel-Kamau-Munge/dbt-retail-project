{{ config(materialized='table', schema='retail_warehouse') }}

WITH source AS (
    SELECT
        supplier_id,
        supplier_name,
        supplier_city,
        supplier_state,
        supplier_zip_code,
        supplier_country,
        supplier_contact,
        supplier_email,
        supplier_phone,
        supplier_status,
        contract_start_date::DATE AS contract_start_date,
        contract_end_date::DATE AS contract_end_date,
        _extracted_at
    FROM {{ ref('stg_suppliers') }}
),

transformed AS (
    SELECT
        md5(supplier_id::TEXT) AS supplier_key,
        supplier_id,
        supplier_name,
        supplier_city,
        supplier_state,
        supplier_zip_code,
        supplier_country,
        supplier_contact,
        supplier_email,
        supplier_phone,
        supplier_status,
        contract_start_date,
        contract_end_date,
        CASE
            WHEN contract_start_date IS NOT NULL AND contract_end_date IS NOT NULL
            THEN (contract_end_date - contract_start_date)::INT
            ELSE NULL
        END AS contract_duration_days,
        CASE
            WHEN supplier_status ILIKE '%active%'
                AND (contract_end_date IS NULL OR contract_end_date >= CURRENT_DATE)
            THEN TRUE::BOOLEAN
            ELSE FALSE::BOOLEAN
        END AS is_active_supplier,
        md5(supplier_id::TEXT) AS dbt_scd_id
    FROM source
)

SELECT * FROM transformed
