{# This is a macro to multiply two numbers with precision / Function#}
{% macro multiply(x, y, precision) %}
    round({{ x }} * {{ y }}, {{ precision }})
{% endmacro %}