{{ config(materialized='view', schema='retail_staging') }}

WITH raw AS (
    SELECT * FROM {{ source('retail_raw', 'raw_suppliers') }}
),

cleaned AS (
    SELECT
        supplier_id::INT AS supplier_id,
        {{ clean_string('supplier_name') }} AS supplier_name,
        {{ clean_string('supplier_city') }} AS city,
        {{ clean_string('supplier_state') }} AS state,
        {{ clean_string('supplier_zip_code') }} AS zip,
        {{ clean_string('supplier_country') }} AS country,
        {{ clean_string('supplier_contact') }} AS contact,
        {{ clean_string('supplier_email') }} AS email,
        {{ clean_string('supplier_phone') }} AS phone,
        {{ clean_string('supplier_status') }} AS status,
        {{ clean_date('contract_start_date', 'YYYY-MM-DD') }} AS contract_start_date,
        {{ clean_date('contract_end_date', 'YYYY-MM-DD') }} AS contract_end_date,
        _extracted_at,
        _file_name,
        md5(concat_ws('||', supplier_id::TEXT)) AS dbt_scd_id
    FROM raw
),

deduped AS (
    {{ dedup_rows('cleaned', ['supplier_id'], '_extracted_at DESC') }}
),

final AS (
    SELECT
        supplier_id,
        supplier_name,
        city,
        state,
        zip,
        country,
        contact,
        email,
        phone,
        status,
        contract_start_date,
        contract_end_date,
        _extracted_at,
        _file_name,
        dbt_scd_id
    FROM deduped
)

SELECT * FROM final
