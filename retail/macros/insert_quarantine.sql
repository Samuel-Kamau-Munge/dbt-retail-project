{% macro insert_quarantine(source_table, target_table, validation_type, validation_rule, validation_message, severity, row_filter) %}
INSERT INTO retail_quarantine.validation_log (
    source_table,
    target_table,
    row_data,
    validation_type,
    validation_rule,
    validation_message,
    severity,
    batch_id
)
SELECT
    '{{ source_table }}' AS source_table,
    '{{ target_table }}' AS target_table,
    to_jsonb(t) AS row_data,
    '{{ validation_type }}' AS validation_type,
    '{{ validation_rule }}' AS validation_rule,
    '{{ validation_message }}' AS validation_message,
    '{{ severity }}' AS severity,
    '{{ var('batch_id') }}'::VARCHAR(50) AS batch_id
FROM {{ source_table }} t
WHERE {{ row_filter }}
{% endmacro %}
