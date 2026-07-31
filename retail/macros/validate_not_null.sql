{% macro validate_not_null(columns, source_table) %}
SELECT *
FROM {{ source_table }}
WHERE
{% for col in columns %}
    {{ col }} IS NULL{% if not loop.last %} OR {% endif %}
{% endfor %}
{% endmacro %}
