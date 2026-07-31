{% macro validate_unique(columns, source_table) %}
WITH duplicates AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
            {% for col in columns %}
                {{ col }}{% if not loop.last %}, {% endif %}
            {% endfor %}
            ORDER BY (SELECT NULL)
        ) AS rn
    FROM {{ source_table }}
)
SELECT *
FROM duplicates
WHERE rn > 1
{% endmacro %}
