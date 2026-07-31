{% macro validate_domain(column, allowed_values) %}
{{ column }} NOT IN (
    {% for val in allowed_values %}
        {% if val is number %}
            {{ val }}
        {% else %}
            '{{ val }}'
        {% endif %}
        {% if not loop.last %}, {% endif %}
    {% endfor %}
)
{% endmacro %}
