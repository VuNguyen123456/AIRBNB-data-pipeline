{# Trim and upper is like built-in functions #}
{% macro trimmer(column_name, node) %}
    {{ column_name | trim | upper}}
{% endmacro %}