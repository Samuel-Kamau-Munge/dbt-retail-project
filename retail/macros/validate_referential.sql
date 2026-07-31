{% macro validate_referential(source_table, fk_columns, pk_table, pk_columns) %}
SELECT fk.*
FROM {{ source_table }} fk
LEFT JOIN {{ pk_table }} pk
    ON
    {% for i in range(fk_columns | length) %}
        fk.{{ fk_columns[i] }} = pk.{{ pk_columns[i] }}
        {% if not loop.last %} AND {% endif %}
    {% endfor %}
WHERE
    {% for col in pk_columns %}
        pk.{{ col }} IS NULL{% if not loop.last %} AND {% endif %}
    {% endfor %}
{% endmacro %}
