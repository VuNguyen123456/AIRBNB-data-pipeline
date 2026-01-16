{% macro tag(col) %}
  CASE 
    WHEN {{ col }} < 100 THEN 'low'
    WHEN {{ col }} < 200 AND {{ col }} < 150 THEN 'mid'
    ELSE 'high'
  END
{% endmacro %}