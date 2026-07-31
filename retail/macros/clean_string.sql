{% macro clean_string(column) %}
NULLIF(
    TRIM(
        regexp_replace({{ column }}, '[^[:print:]]', '', 'g')
    ),
    ''
)
{% endmacro %}
