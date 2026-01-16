-- No jinja => This is hardcode not Dynamic

-- Jinja SQL allow parameterization and reusability => dynamic SQL
{# {% set nights_booked = 1%} #}

{# allow if else condition in sql #}
{% set flag = 1%} 


-- This is hardcode not Dynamic
SELECT * FROM {{ ref('bronze_bookings')}}
{# WHERE NIGHTS_BOOKED > {{ nights_booked }} #}
{%if flag == 1%}
    WHERE NIGHTS_BOOKED > 1
{% else %}
    WHERE NIGHTS_BOOKED = 1
{% endif %}