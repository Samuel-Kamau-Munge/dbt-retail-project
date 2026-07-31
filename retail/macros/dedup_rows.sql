{% macro dedup_rows(source_cte, partition_cols, order_by_expr) %}
{{ source_cte }}_deduped AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
            {% if partition_cols is string %}
                {{ partition_cols }}
            {% else %}
                {% for col in partition_cols %}
                    {{ col }}{% if not loop.last %}, {% endif %}
                {% endfor %}
            {% endif %}
            ORDER BY {{ order_by_expr }}
        ) AS rn
    FROM {{ source_cte }}
)
SELECT *
FROM {{ source_cte }}_deduped
WHERE rn = 1
{% endmacro %}
