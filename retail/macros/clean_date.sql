{% macro clean_date(column, format) %}
CASE
    WHEN {{ column }} IS NULL OR TRIM({{ column }}) = '' THEN NULL
    WHEN {{ column }} ~ '^\d{4}-\d{2}-\d{2}[ T]?\d{2}:\d{2}:\d{2}'
        THEN TO_TIMESTAMP({{ column }}, 'YYYY-MM-DD HH24:MI:SS')::DATE
    WHEN {{ column }} ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE({{ column }}, 'YYYY-MM-DD')
    WHEN {{ column }} ~ '^\d{8}$' THEN TO_DATE({{ column }}, 'YYYYMMDD')
    ELSE NULL
END
{% endmacro %}

{% macro clean_timestamp(column) %}
CASE
    WHEN {{ column }} IS NULL OR TRIM({{ column }}) = '' THEN NULL
    WHEN {{ column }} ~ '^\d{4}-\d{2}-\d{2}[ T]?\d{2}:\d{2}:\d{2}'
        THEN TO_TIMESTAMP({{ column }}, 'YYYY-MM-DD HH24:MI:SS')
    WHEN {{ column }} ~ '^\d{4}-\d{2}-\d{2}$'
        THEN TO_DATE({{ column }}, 'YYYY-MM-DD')::TIMESTAMP
    ELSE NULL
END
{% endmacro %}
